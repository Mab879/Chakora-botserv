# protocol/charybdis by The Chakora Project. Link with Charybdis.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

# This is a cheap hack, but it'll work --Matthew
$Chakora::MODULE{protocol}{name} = 'protocol/charybdis';
$Chakora::MODULE{protocol}{version} = '0.8';
$Chakora::MODULE{protocol}{author} = 'The Chakora Project'; 

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
	'PART' => {
		handler => \&raw_part,
	},
	'MODE' => {
		handler => \&raw_mode,
	},
	'SID' => {
		handler => \&raw_sid,
	},
	'SQUIT' => {
		handler => \&raw_squit,
	},
	'AWAY' => {
		handler => \&raw_away,
	},
	'KILL' => {
		handler => \&raw_kill,
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
our (%uid, %channel, %sid, $hub);
my $lastid = 0;

sub irc_connect {
	if (length(config('me', 'sid')) != 3) {
		error('chakora', 'Services SID have to be 3 characters');
	}
	else {
		send_sock("PASS ".config('server', 'password')." TS 6 ".config('me', 'sid'));
		# Some of these may not be needed, but let's keep them for now just in case --Matthew
		send_sock("CAPAB :QS KLN UNKLN ENCAP EX CHW IE KNOCK SAVE EUID SERVICES RSFNC MLOCK");
		send_sock("SERVER ".config('me', 'name')." 0 :".config('me', 'info'));
		send_sock("SVINFO 6 6 0 ".time());
		raw_bursting();
	}
}

# Get service UID
sub svsUID {
	my ($svs) = @_;
	if (lc($svs) eq 'chakora::server') {
		return config('me', 'sid');
	} else {
		return $Chakora::svsuid{$svs};
	}
}

# Get UID info
sub uidInfo {
	my ($ruid, $section) = @_;
	if ($section == 1) {
		return $Chakora::uid{$ruid}{'nick'};
	} elsif ($section == 2) {
		return $Chakora::uid{$ruid}{'user'};
	} elsif ($section == 3) {
		return $Chakora::uid{$ruid}{'host'};
	} elsif ($section == 4) {
		return $Chakora::uid{$ruid}{'mask'};
	} elsif ($section == 5) {
		return $Chakora::uid{$ruid}{'ip'};
	} elsif ($section == 6) {
		return $Chakora::uid{$ruid}{'pnick'};
	} elsif ($section == 7) {
		return $Chakora::uid{$ruid}{'oper'};
	} elsif ($section == 8) {
		return $Chakora::uid{$ruid}{'server'};
	} else {
		return 0;
	}
}

# Get SID info 
sub sidInfo {
	my ($id, $section) = @_;
	if ($section == 1) {
		return $Chakora::sid{$id}{'name'};
	} elsif ($section == 2) {
		return $Chakora::sid{$id}{'info'};
	} elsif ($section == 3) {
		return $Chakora::sid{$id}{'sid'};
	} elsif ($section == 4) {
		return $Chakora::sid{$id}{'hub'};
	} else {
		return 0;
	}
}

# Find UID by nick
sub nickUID {
	my ($nick) = @_;
	foreach (%uid) {
		if (lc($Chakora::uid{'nick'}) eq lc($nick)) {
			return $Chakora::uid{'uid'};
		}
	}
}

######### Sending data #########

# Handle client creation
sub serv_add {
	my ($svs, $user, $nick, $host, $modes, $real) = @_;
	$svs = lc($svs);
	$lastid += 1;
	my $calc = 6 - length($lastid);
	my ($ap);
	while ($calc != 0) {
		$ap .= '0';
		$calc -= 1;
	}
	$Chakora::svsuid{$svs} = config('me', 'sid').$ap.$lastid;
	my $ruid = config('me', 'sid').$ap.$lastid;
	send_sock(":".svsUID('chakora::server')." EUID ".$nick." 0 ".time()." ".$modes." ".$user." ".$host." 0.0.0.0 ".$ruid." ".config('me', 'name')." * :".$real);
	if ($Chakora::synced) { serv_join($svs, config('log', 'logchan')); }
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
        # If a channel has no ts, we're obviously creating that channel, set ts to current time --Matthew
	if (!$Chakora::channel{$chan}{'ts'}) {
		$Chakora::channel{$chan}{'ts'} = time();
	}
	send_sock(":".svsUID('chakora::server')." SJOIN ".$Chakora::channel{$chan}{'ts'}." ".$chan." +nt :@".svsUID($svs));
}

# Handle TMODE
sub serv_mode {
	my ($svs, $target, $modes) = @_;
	# This should never happen, but just in case, have a check. --Matthew
        if (!$Chakora::channel{$target}{'ts'}) {
                $Chakora::channel{$target}{'ts'} = time();
        }
	send_sock(":".svsUID($svs)." TMODE ".$Chakora::channel{$target}{'ts'}." ".$target." ".$modes);
}

# Handle Client MODE (This is basically only used for user mode changes in Charybdis --Matthew)
sub serv_cmode {
	my ($svs, $target, $modes) = @_;
	send_sock(":".svsUID($svs)." MODE ".$target." ".$modes);
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

# Handle SQUIT
sub serv_squit {
	my ($server, $reason) = @_;
	send_sock(":".svsUID("chakora::server")." SQUIT $server :$reason");
}

# Handle setting vHosts
sub serv_sethost {
	my ($user, $host) = @_;
        send_sock(":".svsUID("chakora::server")." CHGHOST ".$user." ".$host);
}

# Send global messages
sub send_global {
        my ($msg) = @_;
        foreach my $key (keys %uid) {
                serv_notice("global", $Chakora::uid{$key}{'uid'}, $msg);
        }
}

######### Receiving data #########

# Our Bursting
sub raw_bursting {
	serv_add('global', config('global', 'user'), config('global', 'nick'), config('global', 'host'), '+ioS', config('global', 'real'));
	serv_add('chanserv', config('chanserv', 'user'), config('chanserv', 'nick'), config('chanserv', 'host'), '+ioS', config('chanserv', 'real'));
	serv_add('nickserv', config('nickserv', 'user'), config('nickserv', 'nick'), config('nickserv', 'host'), '+ioS', config('nickserv', 'real'));
	serv_add('operserv', config('operserv', 'user'), config('operserv', 'nick'), config('operserv', 'host'), '+ioS', config('operserv', 'real'));
}	

# Handle END SYNC
sub raw_endsync {
	foreach my $key (sort keys %Chakora::svsuid) {
		serv_join($key, config('log', 'logchan'));
	}
	$Chakora::synced = 1;
	event_eos();
}

# Handle EUID
sub raw_euid {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = $rex[9];
	$Chakora::uid{$ruid}{'nick'} = $rex[2];
	$Chakora::uid{$ruid}{'user'} = $rex[6];
	$Chakora::uid{$ruid}{'mask'} = $rex[7];
	$Chakora::uid{$ruid}{'ip'} = $rex[8];
	$Chakora::uid{$ruid}{'uid'} = $rex[9];
	$Chakora::uid{$ruid}{'host'} = $rex[10];
	$Chakora::uid{$ruid}{'server'} = substr($rex[0], 1);
	$Chakora::uid{$ruid}{'pnick'} = 0;
	$Chakora::uid{$ruid}{'away'} = 0;
	if ($rex[5] =~ m/o/) {
		$Chakora::uid{$ruid}{'oper'} = 1;
		event_oper($ruid);
	}
	event_uid($ruid, $rex[2], $rex[6], $rex[10], $rex[7], $rex[8], substr($rex[0], 1));
	if ($Chakora::IN_DEBUG) { serv_notice('global', $ruid, "Services are in debug mode, be careful when sending messages to services."); }
}

# Handle SJOIN
sub raw_sjoin {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] :48X SJOIN 1280086561 #services +nt :@48XAAAAAB
	my $chan = $rex[3];
	$Chakora::channel{$chan}{'ts'} = $rex[2];
	my $user = substr($rex[5], 1);
	$user =~ s/[@+]//;
	event_join($user, $rex[3]);
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
	undef $Chakora::uid{$ruid};
}

# Handle MODE
sub raw_mode {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	if ($Chakora::uid{$rex[2]}{'oper'} and parse_mode($rex[3], '-', 'o')) {
		undef $Chakora::uid{$rex[2]}{'oper'};
		event_deoper($rex[2]);
	}
	if (parse_mode($rex[3], '+', 'o')) {
		$Chakora::uid{$rex[2]}{'oper'} = 1;
		event_oper($rex[2]);
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
	send_sock(":".svsUID("chakora::server")." PONG :".$rex[2]);
}

# Handle NICK
sub raw_nick {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $ruid = substr($rex[0], 1);
	$Chakora::uid{$ruid}{'pnick'} = uidInfo($ruid, 1);
        $Chakora::uid{$ruid}{'nick'} = $rex[2];
        event_nick($ruid, $rex[2]);
}

# Handle CHGHOST
sub raw_chghost {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = $rex[1];
	$Chakora::uid{$ruid}{'mask'} = $rex[2];
}

# Handle ERROR without a source server
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

# Handle SID
sub raw_sid {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] :48X SID dev.server 2 42X :Development server
	$Chakora::sid{$rex[4]}{'name'} = $rex[2];
	$Chakora::sid{$rex[4]}{'sid'} = $rex[4];
	$Chakora::sid{$rex[4]}{'hub'} = substr($rex[0], 1);
        my $args = substr($rex[5], 1);
        my ($i);
        for ($i = 6; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        $Chakora::sid{$rex[4]}{'info'} = $args;
	event_sid($rex[2], $args);
}

# Handle PASS
sub raw_pass {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] PASS linkage TS 6 :48X
	$hub = substr($rex[4], 1);
	$Chakora::sid{$hub}{'sid'} = $hub;
}

# Handle SERVER 
sub raw_server {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] SERVER lol.server 1 :lolserver
	$Chakora::sid{$hub}{'name'} = $rex[1];
	$Chakora::sid{$hub}{'hub'} = 0;
	my $args = substr($rex[3], 1);
        my ($i);
        for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        $Chakora::sid{$hub}{'info'} = $args;
	event_sid($rex[1], $args);
}

# Handle remote SQUIT
sub raw_squit {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] :48X SQUIT 42X :by MattB_: lol
	my $args = substr($rex[3], 1);
        my ($i);
        for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	netsplit($rex[2], $args, substr($rex[0], 1));
}

# Handle local SQUIT
sub raw_lsquit {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        # [IRC] SQUIT 42X :by MattB_: lol
        my $args = substr($rex[2], 1);
        my ($i);
        for ($i = 3; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        netsplit($rex[1], $args, $hub);
}

# Handle netsplits
sub netsplit {
	my ($server, $reason, $source) = @_;
	event_netsplit($server, $reason, $source);
	foreach my $key (keys %uid) {
  		if ($Chakora::uid{$key}{'server'} eq $server) {
			#logchan("os", "Deleting user ".uidInfo($Chakora::uid{$key}{'uid'}, 1)." due to ".sidInfo($server, 1)." splitting from ".sidInfo($source, 1));
    			undef $Chakora::uid{$key};
  		}
	}
	undef $Chakora::sid{$server};
}

# Handle AWAY
sub raw_away {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	# Going away: [IRC] :42XAAAAAC AWAY :bbiab
	if ($rex[2]) {
		my $args = substr($rex[2], 1);
        	my ($i);
        	for ($i = 3; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
		$Chakora::uid{$user}{'away'} = 1; # We don't want someone to return away 500 times and log flood --Matthew
		event_away($user, $args);
	}
	else {
		# Returning [IRC] :42XAAAAAC AWAY
		if ($Chakora::uid{$user}{'away'}) {
			event_back($user);
			$Chakora::uid{$user}{'away'} = 0;
		}
	}
}

# Handle KILL
sub raw_kill {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
 	my $user = substr($rex[0], 1);
	my $target = $rex[2];
        my ($i, $args);
        for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	event_kill($user, $target, $args);
}

1;
