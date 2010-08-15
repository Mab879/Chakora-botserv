# protocol/charybdis by The Chakora Project. Link with Charybdis.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;
use lib "../lib";

######### Core #########
our %rawcmds = (
	'EUID' => {
		handler => \&raw_euid,
	},
	'PING' => {
		handler => \&raw_ping,
	},
	'SJOIN' => {
		handler => \&raw_sjoin,
	},
	'QUIT' => {
		handler => \&raw_quit,
	},
	'JOIN' => {
		handler => \&raw_join,
	},
	'NICK' => {
		handler => \&raw_nick,
	},
	'CHGHOST' => {
		handler => \&raw_chghost,
	},
	'ERROR' => {
		handler => \&raw_error,
	},
	'PRIVMSG' => {
		handler => \&raw_privmsg,
	},
	'NOTICE' => {
		handler => \&raw_notice,
	},
);
our %PROTO_SETTINGS = (
	name => 'Charybdis IRCd',
	owner => '-',
	admin => '-',
	op => 'o',
	halfop => '-',
	voice => 'v',
	mute => 'q',
	bexecpt => 'e',
	iexcept => 'I',
);
my (%svsuid, %uid, $uid, %channel, $channel);
$svsuid{'cs'} = config('me', 'sid')."AAAAAA";
$svsuid{'hs'} = config('me', 'sid')."AAAAAB";
$svsuid{'ms'} = config('me', 'sid')."AAAAAC";
$svsuid{'ns'} = config('me', 'sid')."AAAAAD";
$svsuid{'os'} = config('me', 'sid')."AAAAAE";
$svsuid{'g'} = config('me', 'sid')."AAAAAF";

sub irc_connect {
	send_sock("PASS ".config('server', 'password')." TS 6 ".config('me', 'sid'));
	send_sock("CAPAB QS KLN UNKLN ENCAP EX CHW IE KNOCK SAVE EUID SERVICES RSFNC");
	send_sock("SERVER ".config('me', 'name')." 0 :".config('me', 'info'));
	send_sock("SVINFO 6 6 0 ".time());
	raw_endsync();
}

# Get service UID
sub svsUID {
	my ($svs) = @_;
	if (lc($svs) eq 'chakora::server') {
		return config('me', 'sid');
	} else {
		return $svsuid{$svs};
	}
}

# Get UID info
sub uidInfo {
	my ($ruid, $section) = @_;
	if ($section == 1) {
		return $uid{$ruid}{'nick'};
	} elsif ($section == 2) {
		return $uid{$ruid}{'user'};
	} elsif ($section == 3) {
		return $uid{$ruid}{'host'};
	} elsif ($section == 4) {
		return $uid{$ruid}{'mask'};
	} elsif ($section == 5) {
		return $uid{$ruid}{'ip'};
	} else {
		return 0;
	}
}

# Get a data from a UID or nick


# Find UID by nick
sub nickUID {
	my ($nick) = @_;
	foreach (%uid) {
		if (lc($uid{'nick'}) eq lc($nick)) {
			return $uid{'uid'};
		}
	}
}

######### Sending data #########

# Handle client creation
sub serv_add {
	my ($ruid, $user, $nick, $host, $modes, $real) = @_;
	send_sock(":".svsUID('chakora::server')." EUID ".$nick." 0 ".time()." ".$modes." ".$user." ".$host." 0.0.0.0 ".$ruid." ".config('me', 'name')." * :".$real);
}

# Handle PRIVMSG
sub serv_privmsg {
	my ($svs, $target, $msg) = @_;
	send_sock(":".svsUID($svs)." PRIVMSG ".$target." :".$msg);
}

# Handle NOTICE
sub serv_notice {
	my ($svs, $target, $msg) = @_;
	send_sock(":".svsUID($svs)." NOTICE ".$target." :".$msg);
}

# Handle JOIN
sub serv_join {
	my ($svs, $chan) = @_;
	if (!$channel{$chan}{'ts'}) {
		$channel{$chan}{'ts'} = time();
	}
	send_sock(":".svsUID('chakora::server')." SJOIN ".$channel{$chan}{'ts'}." ".$chan." +nt :@".svsUID($svs));
}

# Handle TMODE
sub serv_mode {
	my ($svs, $chan, $modes) = @_;
	send_sock(":".svsUID($svs)." TMODE ".$channel{$chan}{'ts'}." ".$chan." ".$modes);
}

# Handle ERROR
sub serv_error {
	my $error = @_;
	send_sock(":".svsUID('chakora::server')." ERROR :".$error);
}

# Handle INVITE
sub serv_invite {
	my ($svs, $target, $chan);
	send_sock(":".svsUID($svs)." INVITE ".$target." ".$chan);
}

# Handle KICK
sub serv_kick {
	my ($svs, $chan, $user, $msg) = @_;
	send_sock(":".svsUID($svs)." KICK ".$chan." ".$user." :".$msg);
}

# Handle PART
sub serv_part {
	my ($svs, $chan, $msg) = @_;
	send_sock(":".svsUID($svs)." PART ".$chan." :".$msg);
}

# Handle QUIT
sub serv_quit {
	my ($svs, $msg) = @_;
	send_sock(":".svsUID($svs)." QUIT :".$msg);
}

# Handle WALLOPS
sub serv_wallops {
	my ($msg) = @_;
	send_sock(":".svsUID('chakora::server')." WALLOPS :".$msg);
}

######### Receiving data #########

# Handle END SYNC
sub raw_endsync {
	serv_add(svsUID('g'), config('global', 'user'), config('global', 'nick'), config('global', 'host'), "+oS", config('global', 'real'));
	serv_add(svsUID('cs'), config('chanserv', 'user'), config('chanserv', 'nick'), config('chanserv', 'host'), "+oS", config('chanserv', 'real'));
	serv_add(svsUID('hs'), config('hostserv', 'user'), config('hostserv', 'nick'), config('hostserv', 'host'), "+oS", config('hostserv', 'real'));
	serv_add(svsUID('ms'), config('memoserv', 'user'), config('memoserv', 'nick'), config('memoserv', 'host'), "+oS", config('memoserv', 'real'));
	serv_add(svsUID('ns'), config('nickserv', 'user'), config('nickserv', 'nick'), config('nickserv', 'host'), "+oS", config('nickserv', 'real'));
	serv_add(svsUID('os'), config('operserv', 'user'), config('operserv', 'nick'), config('operserv', 'host'), "+oS", config('operserv', 'real'));
	serv_join('g', config('log', 'logchan'));
	serv_join('cs', config('log', 'logchan'));
	serv_join('hs', config('log', 'logchan'));
	serv_join('ms', config('log', 'logchan'));
	serv_join('ns', config('log', 'logchan'));
	serv_join('os', config('log', 'logchan'));
	if ($Chakora::IN_DEBUG) { serv_wallops("Services are in debug mode - be careful when sending messages to services."); }
}

# Handle EUID
sub raw_euid {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = $rex[9];
	$uid{$ruid}{'nick'} = $rex[2];
	$uid{$ruid}{'user'} = $rex[6];
	$uid{$ruid}{'mask'} = $rex[7];
	$uid{$ruid}{'ip'} = $rex[8];
	$uid{$ruid}{'uid'} = $rex[9];
	$uid{$ruid}{'host'} = $rex[10];
	if ($Chakora::IN_DEBUG) { serv_notice('g', $ruid, "Services are in debug mode - be careful when sending messages to services."); }
}

# Handle SJOIN
sub raw_sjoin {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] :48X SJOIN 1280086561 #services +nt :@48XAAAAAB
	my $chan = $rex[3];
	$channel{$chan}{'ts'} = $rex[2];
	my $user = substr($rex[5], 1);
	$user =~ s/[@+]//;
	event_join($user, $rex[3]);
}

# Handle QUIT
sub raw_quit {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = substr($rex[0], 1);
	undef $uid{$ruid};
}

# Handle JOIN
sub raw_join {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	event_join(substr($rex[0], 1), $rex[3]);
}

# Handle PING
sub raw_ping {
	my ($raw) = @_;
	my (@rex);
	@rex = split(' ', $raw);
	send_sock(":".svsUID("chakora::server")." PONG ".$rex[1]);
}

# Handle NICK
sub raw_nick {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $ruid = substr($rex[0], 1);
        $uid{$ruid}{'nick'} = $rex[2];
        event_nick($ruid, $rex[2]);
}

# Handle CHGHOST
sub raw_chghost {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = $rex[1];
	$uid{$ruid}{'mask'} = $rex[2];
}

# Handle ERROR without a soruce server
sub raw_nosrcerror {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $args = substr($rex[1], 1);
	my $i;
        for ($i = 2; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	svsflog("chakora", "[Server Error] ".$args);
}

# Handle ERROR with a source server
sub raw_error {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $args = substr($rex[2], 1);
        my $i;
        for ($i = 3; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        svsflog("chakora", "[Server Error] ".$args);
}


# Handle PRIVMSG
sub raw_privmsg {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $args = substr($rex[3], 1);
        my ($i);
    for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        event_privmsg(substr($rex[0], 1), $rex[2], $args);
}

# Handle NOTICE
sub raw_notice {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $args = substr($rex[3], 1);
        my ($i);
    for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        event_notice(substr($rex[0], 1), $rex[2], $args);
}



1;
