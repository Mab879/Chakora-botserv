# protocol/charybdis by The Chakora Project. Link with Charybdis.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;
use MIME::Base64;
use lib "../lib";

######### Core #########
our %rawcmds = (
	'NICK' => {
		handler => \&raw_nick,
	},
	'SJOIN' => {
		handler => \&raw_sjoin,
	},
	'EOS' => {
		handler => \&raw_eos,
	},
	'PING' => {
		handler => \&raw_ping,
	},
	'QUIT' => {
		handler => \&raw_quit,
	},
	'JOIN' => {
		handler => \&raw_join,
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
	'PART' => {
		handler => \&raw_part,
	},
);
our %PROTO_SETTINGS = (
	name => 'Unreal IRCd 3.2.x',
	owner => 'q',
	admin => 'a',
	op => 'o',
	halfop => 'h',
	voice => 'v',
	mute => '+b ~q',
	bexecpt => 'e',
	iexcept => 'I',
);
my (%svsuid, %uid, $uid, %channel, $channel);
$svsuid{'cs'} = config('chanserv', 'nick');
$svsuid{'hs'} = config('hostserv', 'nick');
$svsuid{'ms'} = config('memoserv', 'nick');
$svsuid{'ns'} = config('nickserv', 'nick');
$svsuid{'os'} = config('operserv', 'nick');
$svsuid{'g'} = config('global', 'nick');

sub irc_connect {
		send_sock("PASS :".config('server', 'password'));
		send_sock("PROTOCTL NICKv2 NICKIP UMODE2 SJOIN SJOIN2 SJ3 NOQUIT TKLEXT");
		send_sock("SERVER ".config('me', 'name')." 1 :".config('me', 'info'));
		raw_bursting();
}

# Get service UID
sub svsUID {
	my ($svs) = @_;
	if (lc($svs) eq 'chakora::server') {
		return config('me', 'name');
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
	my (undef, $user, $nick, $host, $modes, $real) = @_;
	send_sock("NICK ".$nick." 1 ".time()." ".$user." ".$host." ".svsUID('chakora::server')." * ".$modes." ".$host." :".$real);
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
	send_sock(":".svsUID('chakora::server')." SJOIN ".$channel{$chan}{'ts'}." ".$chan." + :@".svsUID($svs));
}

# Handle MODE
sub serv_mode {
	my ($svs, $chan, $modes) = @_;
	send_sock(":".svsUID('chakora::server')." MODE ".$chan." ".$modes);
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
	send_sock(":".svsUID('chakora::server')." ENCAP * SU ".$user." ".$name);
}

# Handle when a user logs out of nickserv
sub serv_logout {
	my ($user) = @_;
	send_sock(":".svsUID('chakora::server')." ENCAP * SU ".$user);
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
	send_sock(":".svsUID('os')." SQUIT ".$server." :".$reason);
	send_sock(":".svsUID('chakora::server')." SERVER ".$server." 2 :(JUPED) ".$reason);
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
	send_sock("EOS");
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

# Handle EOS
sub raw_eos {
	$Chakora::synced = 1;
	raw_endsync();
}

# Handle NICK
sub raw_nick {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	if ($rex[5]) {
	# [IRC] NICK lol2 1 1282320638 MattB localhost dev.matt-tech.info 0 +iowghaAxNt lol fwAAAQ== :Matthew - Laptop
		my $ruid = $rex[1];
		$uid{$ruid}{'nick'} = $rex[1];
		$uid{$ruid}{'user'} = $rex[4];
		$uid{$ruid}{'mask'} = $rex[9];
		$uid{$ruid}{'ip'} = decode_base64($rex[10]);
		$uid{$ruid}{'uid'} = '';
		$uid{$ruid}{'host'} = $rex[5];
		$uid{$ruid}{'pnick'} = 0;
		event_uid($ruid, $rex[1], $rex[4], $rex[5], $rex[9], decode_base64($rex[10]));
		if ($Chakora::IN_DEBUG) { serv_notice('g', $ruid, "Services are in debug mode - be careful when sending messages to services."); }
	}
	else {
		my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $ruid = substr($rex[0], 1);
	    $uid{$ruid}{'pnick'} = uidInfo($ruid, 1);
        $uid{$ruid}{'nick'} = $rex[2];
        event_nick($ruid, $rex[2]);
	}
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

# Handle SJOIN
sub raw_sjoin {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	#[IRC] :dev.matt-tech.info SJOIN 1282321194 #services :@lol2 
	my $chan = $rex[3];
	$channel{$chan}{'ts'} = $rex[2];
	if ($Chakora::synced) { 
		my $user = substr($rex[5], 1);
        $user =~ s/[@+]//;
		event_join($user, $rex[3]);
	}
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
	send_sock(":".svsUID("chakora::server")." PONG ".$rex[1]);
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



1;