# protocol/charybdis by The Chakora Project. Link with Charybdis.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;
use lib "../lib";

######### Core #########
our %rawcmds = (
	'UNICK' => {
		handler => \&raw_unick,
	},
	'PING' => {
		handler => \&raw_ping,
	},
	'NJOIN' => {
		handler => \&raw_njoin,
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
	'ERROR' => {
		handler => \&raw_error,
	},
	'PRIVMSG' => {
		handler => \&raw_privmsg,
	},
	'NOTICE' => {
		handler => \&raw_notice,
	},
	'PART' => {
		handler => \&raw_part,
	},
	'EOB' => {
		handler => \&raw_eob,
	},
);
our %PROTO_SETTINGS = (
	name => 'IRCd 2.11',
	owner => '-',
	admin => '-',
	op => 'o',
	halfop => '-',
	voice => 'v',
	mute => '-',
	bexecpt => 'e',
	iexcept => 'I',
);
my (%svsuid, %uid, $uid, %channel, $channel);
$svsuid{'cs'} = config('me', 'sid')."AAAAA";
$svsuid{'hs'} = config('me', 'sid')."AAAAB";
$svsuid{'ms'} = config('me', 'sid')."AAAAC";
$svsuid{'ns'} = config('me', 'sid')."AAAAD";
$svsuid{'os'} = config('me', 'sid')."AAAAE";
$svsuid{'g'} = config('me', 'sid')."AAAAF";

# A cheap hack for jupes
my $jupe = 999;

sub get_flags {
	my $flags = 'aEFJKMQRsTu';
	if ($Chakora::IN_DEBUG) {
		$flags .= 'D';
	}
	return $flags;
}

sub irc_connect {
	if (length(config('me', 'sid')) != 4) {
		error('chakora', 'Services SID have to be 4 characters');
	}
	else {
		send_sock("PASS ".config('server', 'password')." 0211 IRC|".get_flags());
		send_sock("SERVER ".config('me', 'name')." 1 ".config('me', 'sid')." :".config('me', 'info'));
		raw_bursting();
	}
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
	} elsif ($section == 6) {
		return $uid{$ruid}{'pnick'};
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
	send_sock(":".svsUID('chakora::server')." UNICK ".$nick." ".$ruid." ".$user." ".$host." 0.0.0.0 ".$modes." :".$real);
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
	send_sock(":".svsUID('chakora::server')." NJOIN ".$chan." :@".svsUID($svs));
}

# Handle TMODE
sub serv_mode {
	my ($svs, $chan, $modes) = @_;
	send_sock(":".svsUID($svs)." MODE ".$chan." ".$modes);
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

# Set account name
sub serv_accountname {
	my ($user, $name) = @_;
}

# Handle when a user logs out of nickserv
sub serv_logout {
	my ($user) = @_;
}

# Handle KILL
sub serv_kill {
	my ($svs, $user, $reason) = @_; 
	if (length($reason) == 0) {
		send_sock(":".svsUID($svs)." KILL ".$user);
	}
	else {
		send_sock(".".svsUID($svs)." KILL ".$user." :".$reason);
	}
}

# Handle jupes
sub serv_jupe {
	my ($server, $reason) = @_;
	$jupe++;
	send_sock(":".svsUID('os')." SQUIT ".$server." :".$reason);
	send_sock(":".svsUID('chakora::server')." SERVER ".$server." 2 ".$jupe." 0211 :(JUPED) ".$reason);
}

######### Receiving data #########

# Our Bursting
sub raw_bursting {
	serv_add(svsUID('g'), config('global', 'user'), config('global', 'nick'), config('global', 'host'), "+oS", config('global', 'real'));
	serv_add(svsUID('cs'), config('chanserv', 'user'), config('chanserv', 'nick'), config('chanserv', 'host'), "+oS", config('chanserv', 'real'));
	serv_add(svsUID('hs'), config('hostserv', 'user'), config('hostserv', 'nick'), config('hostserv', 'host'), "+oS", config('hostserv', 'real'));
	serv_add(svsUID('ms'), config('memoserv', 'user'), config('memoserv', 'nick'), config('memoserv', 'host'), "+oS", config('memoserv', 'real'));
	serv_add(svsUID('ns'), config('nickserv', 'user'), config('nickserv', 'nick'), config('nickserv', 'host'), "+oS", config('nickserv', 'real'));
	serv_add(svsUID('os'), config('operserv', 'user'), config('operserv', 'nick'), config('operserv', 'host'), "+oS", config('operserv', 'real'));
	send_sock(":".svsUID('chakora::server')." EOB");
}	

# Handle END SYNC
sub raw_endsync {
	serv_join('g', config('log', 'logchan'));
	serv_join('cs', config('log', 'logchan'));
	serv_join('hs', config('log', 'logchan'));
	serv_join('ms', config('log', 'logchan'));
	serv_join('ns', config('log', 'logchan'));
	serv_join('os', config('log', 'logchan'));
}

# Handle UNICK
sub raw_unick {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = $rex[2];
	$uid{$ruid}{'nick'} = $rex[2];
	$uid{$ruid}{'user'} = $rex[4];
	$uid{$ruid}{'mask'} = $rex[5];
	$uid{$ruid}{'ip'} = $rex[6];
	$uid{$ruid}{'uid'} = $rex[3];
	$uid{$ruid}{'host'} = $rex[5];
	$uid{$ruid}{'pnick'} = 0;
	event_uid($ruid, $rex[2], $rex[4], $rex[5], $rex[5], $rex[6]);
	if ($Chakora::IN_DEBUG) { serv_notice('g', $ruid, "Services are in debug mode - be careful when sending messages to services."); }
}

# Handle NJOIN
sub raw_njoin {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] :000A NJOIN #services :@48XAAAAAB
	my $chan = $rex[2];
	my $user = substr($rex[3], 1);
	$user =~ s/[@+]//;
	event_join($user, $rex[2]);
}

# Handle QUIT
sub raw_quit {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = substr($rex[0], 1);
        my ($i);
        my $args = substr($rex[2], 1);
        for ($i = 3; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	event_quit($ruid, $args);
	undef $uid{$ruid};
}

# Handle JOIN
sub raw_join {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	event_join(substr($rex[0], 1), $rex[3]);
}

# Handle PART
sub raw_part {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $user = substr($rex[0], 1);
	my $args = 0;
	if ($rex[3]) {
        	my $args = substr($rex[3], 1);
        	my ($i);
    		for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	}
    	event_part($user, $rex[2], $args);
}

# Handle PING
sub raw_ping {
	my ($raw) = @_;
	my (@rex);
	@rex = split(' ', $raw);
	send_sock(":".svsUID("chakora::server")." PONG ".config('me', 'name')." ".substr($rex[1], 1));
}

# Handle NICK
sub raw_nick {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $ruid = substr($rex[0], 1);
	$uid{$ruid}{'pnick'} = uidInfo($ruid, 1);
        $uid{$ruid}{'nick'} = $rex[2];
        event_nick($ruid, $rex[2]);
}

# Handle ERROR without a soruce server
sub raw_nosrcerror {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $args = substr($rex[1], 1);
	my ($i);
        for ($i = 2; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	error("chakora", "[Server Error] ".$args);
}

# Handle ERROR with a source server
sub raw_error {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $args = substr($rex[2], 1);
        my ($i);
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

# Handle EOB
sub raw_eob {
        serv_join('g', config('log', 'logchan'));
        serv_join('cs', config('log', 'logchan'));
        serv_join('hs', config('log', 'logchan'));
        serv_join('ms', config('log', 'logchan'));
        serv_join('ns', config('log', 'logchan'));
        serv_join('os', config('log', 'logchan'));
	send_sock(":".svsUID('chakora::server')." EOBACK");
	$Chakora::synced = 1;
}

1;
