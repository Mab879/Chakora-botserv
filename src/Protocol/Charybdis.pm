# protocol/charybdis by The Chakora Project. Link with Charybdis.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
package Protocol;
use strict;
use warnings;

# This is a cheap hack, but it'll work --Matthew
$Chakora::MODULE{protocol}{name} = 'protocol/Charybdis';
$Chakora::MODULE{protocol}{version} = '0.7';
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
our (%svsuid, %uid, $uid, %channel, $channel, %sid, $sid, $hub);
$svsuid{'cs'} = config('me', 'sid')."AAAAAA";
$svsuid{'hs'} = config('me', 'sid')."AAAAAB";
$svsuid{'ms'} = config('me', 'sid')."AAAAAC";
$svsuid{'ns'} = config('me', 'sid')."AAAAAD";
$svsuid{'os'} = config('me', 'sid')."AAAAAE";
$svsuid{'g'} = config('me', 'sid')."AAAAAF";

sub irc_connect {
	if (length(config('me', 'sid')) != 3) {
		error('chakora', 'Services SID have to be 3 characters');
	}
	else {
		Chakora::send_sock("PASS ".config('server', 'password')." TS 6 ".config('me', 'sid'));
		# Some of these may not be needed, but let's keep them for now just in case --Matthew
		Chakora::send_sock("CAPAB :QS KLN UNKLN ENCAP EX CHW IE KNOCK SAVE EUID SERVICES RSFNC MLOCK");
		Chakora::send_sock("SERVER ".config('me', 'name')." 0 :".config('me', 'info'));
		Chakora::send_sock("SVINFO 6 6 0 ".time());
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
	} elsif ($section == 7) {
		return $uid{$ruid}{'oper'};
	} elsif ($section == 8) {
		return $uid{$ruid}{'server'};
	} else {
		return 0;
	}
}

# Get SID info 
sub sidInfo {
	my ($id, $section) = @_;
	if ($section == 1) {
		return $sid{$id}{'name'};
	} elsif ($section == 2) {
		return $sid{$id}{'info'};
	} elsif ($section == 3) {
		return $sid{$id}{'sid'};
	} elsif ($section == 4) {
		return $sid{$id}{'hub'};
	} else {
		return 0;
	}
}

# Find UID by nick
sub nickUID {
	my ($nick) = @_;
	foreach (%uid) {
		if (lc($uid{'nick'}) eq lc($nick)) {
			return $uid{'uid'};
		}
	}
}

# Send global messages
sub send_global {
	my ($msg) = @_;
	foreach my $key (keys %uid) {
		serv_notice("g", $uid{$key}{'uid'}, $msg);
	}
}

######### Sending data #########

# Handle client creation
sub serv_add {
	my ($ruid, $user, $nick, $host, $modes, $real) = @_;
	Chakora::send_sock(":".svsUID('chakora::server')." EUID ".$nick." 0 ".time()." ".$modes." ".$user." ".$host." 0.0.0.0 ".$ruid." ".config('me', 'name')." * :".$real);
}

# Handle PRIVMSG
sub serv_privmsg {
	my ($svs, $target, $msg) = @_;
	Chakora::send_sock(":".svsUID($svs)." PRIVMSG ".$target." :".$msg);
}

# Handle NOTICE
sub serv_notice {
	my ($svs, $target, $msg) = @_;
	Chakora::send_sock(":".svsUID($svs)." NOTICE ".$target." :".$msg);
}

# Handle JOIN
sub serv_join {
	my ($svs, $chan) = @_;
        # If a channel has no ts, we're obviously creating that channel, set ts to current time --Matthew
	if (!$channel{$chan}{'ts'}) {
		$channel{$chan}{'ts'} = time();
	}
	Chakora::send_sock(":".svsUID('chakora::server')." SJOIN ".$channel{$chan}{'ts'}." ".$chan." +nt :@".svsUID($svs));
}

# Handle TMODE
sub serv_mode {
	my ($svs, $target, $modes) = @_;
	# This should never happen, but just in case, have a check. --Matthew
        if (!$channel{$target}{'ts'}) {
                $channel{$target}{'ts'} = time();
        }
	Chakora::send_sock(":".svsUID($svs)." TMODE ".$channel{$target}{'ts'}." ".$target." ".$modes);
}

# Handle Client MODE (This is basically only used for user mode changes in Charybdis --Matthew)
sub serv_cmode {
	my ($svs, $target, $modes) = @_;
	Chakora::send_sock(":".svsUID($svs)." MODE ".$target." ".$modes);
}

# Handle ERROR
sub serv_error {
	my $error = @_;
	Chakora::send_sock(":".svsUID('chakora::server')." ERROR :".$error);
}

# Handle INVITE
sub serv_invite {
	my ($svs, $target, $chan);
	Chakora::send_sock(":".svsUID($svs)." INVITE ".$target." ".$chan);
}

# Handle KICK 
sub serv_kick {
	my ($svs, $chan, $user, $msg) = @_;
	Chakora::send_sock(":".svsUID($svs)." KICK ".$chan." ".$user." :".$msg);
}

# Handle PART
sub serv_part {
	my ($svs, $chan, $msg) = @_;
	Chakora::send_sock(":".svsUID($svs)." PART ".$chan." :".$msg);
}

# Handle QUIT
sub serv_quit {
	my ($svs, $msg) = @_;
	Chakora::send_sock(":".svsUID($svs)." QUIT :".$msg);
}

# Handle WALLOPS
sub serv_wallops {
	my ($msg) = @_;
	Chakora::send_sock(":".svsUID('chakora::server')." WALLOPS :".$msg);
}

# Set account name
sub serv_accountname {
	my ($user, $name) = @_;
	Chakora::send_sock(":".svsUID('chakora::server')." ENCAP * SU ".$user." ".$name);
}

# Handle when a user logs out of nickserv
sub serv_logout {
	my ($user) = @_;
	Chakora::send_sock(":".svsUID('chakora::server')." ENCAP * SU ".$user);
}

# Handle KILL
sub serv_kill {
	my ($svs, $user, $reason) = @_; 
	if (length($reason) == 0) {
		Chakora::send_sock(":".svsUID($svs)." KILL ".$user);
	}
	else {
		Chakora::send_sock(".".svsUID($svs)." KILL ".$user." :".$reason);
	}
}

# Handle jupes
sub serv_jupe {
	my ($server, $reason) = @_;
	Chakora::send_sock(":".svsUID('os')." SQUIT ".$server." :".$reason);
	Chakora::send_sock(":".svsUID('chakora::server')." SERVER ".$server." 2 :(JUPED) ".$reason);
}

######### Receiving data #########

# Our Bursting
sub raw_bursting {
	serv_add(svsUID('g'), config('global', 'user'), config('global', 'nick'), config('global', 'host'), "+ioS", config('global', 'real'));
	serv_add(svsUID('cs'), config('chanserv', 'user'), config('chanserv', 'nick'), config('chanserv', 'host'), "+ioS", config('chanserv', 'real'));
	serv_add(svsUID('hs'), config('hostserv', 'user'), config('hostserv', 'nick'), config('hostserv', 'host'), "+ioS", config('hostserv', 'real'));
	serv_add(svsUID('ms'), config('memoserv', 'user'), config('memoserv', 'nick'), config('memoserv', 'host'), "+ioS", config('memoserv', 'real'));
	serv_add(svsUID('ns'), config('nickserv', 'user'), config('nickserv', 'nick'), config('nickserv', 'host'), "+ioS", config('nickserv', 'real'));
	serv_add(svsUID('os'), config('operserv', 'user'), config('operserv', 'nick'), config('operserv', 'host'), "+ioS", config('operserv', 'real'));
}	

# Handle END SYNC
sub raw_endsync {
	serv_join('g', config('log', 'logchan'));
	serv_join('cs', config('log', 'logchan'));
	serv_join('hs', config('log', 'logchan'));
	serv_join('ms', config('log', 'logchan'));
	serv_join('ns', config('log', 'logchan'));
	serv_join('os', config('log', 'logchan'));
	$Chakora::synced = 1;
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
	$uid{$ruid}{'server'} = substr($rex[0], 1);
	$uid{$ruid}{'pnick'} = 0;
	$uid{$ruid}{'away'} = 0;
	if ($rex[5] =~ m/o/) {
		$uid{$ruid}{'oper'} = 1;
		event_oper($ruid);
	}
	event_uid($ruid, $rex[2], $rex[6], $rex[10], $rex[7], $rex[8], substr($rex[0], 1));
	if ($Chakora::IN_DEBUG) { serv_notice('g', $ruid, "Services are in debug mode, be careful when sending messages to services."); }
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
        my ($i);
        my $args = substr($rex[2], 1);
        for ($i = 3; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	event_quit($ruid, $args);
	undef $uid{$ruid};
}

# Handle MODE
sub raw_mode {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	if ($uid{$rex[2]}{'oper'} and parse_mode($rex[3], '-', 'o')) {
		undef $uid{$rex[2]}{'oper'};
		event_deoper($rex[2]);
	}
	if (parse_mode($rex[3], '+', 'o')) {
		$uid{$rex[2]}{'oper'} = 1;
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
	Chakora::send_sock(":".svsUID("chakora::server")." PONG :".$rex[2]);
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

# Handle CHGHOST
sub raw_chghost {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = $rex[1];
	$uid{$ruid}{'mask'} = $rex[2];
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
	$sid{$rex[4]}{'name'} = $rex[2];
	$sid{$rex[4]}{'sid'} = $rex[4];
	$sid{$rex[4]}{'hub'} = substr($rex[0], 1);
        my $args = substr($rex[5], 1);
        my ($i);
        for ($i = 6; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        $sid{$rex[4]}{'info'} = $args;
	event_sid($rex[2], $args);
}

# Handle PASS
sub raw_pass {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] PASS linkage TS 6 :48X
	$hub = substr($rex[4], 1);
	$sid{$hub}{'sid'} = $hub;
}

# Handle SERVER 
sub raw_server {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] SERVER lol.server 1 :lolserver
	$sid{$hub}{'name'} = $rex[1];
	$sid{$hub}{'hub'} = 0;
	my $args = substr($rex[3], 1);
        my ($i);
        for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        $sid{$hub}{'info'} = $args;
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
  		if ($uid{$key}{'server'} eq $server) {
			#logchan("os", "Deleting user ".uidInfo($uid{$key}{'uid'}, 1)." due to ".sidInfo($server, 1)." splitting from ".sidInfo($source, 1));
    			undef $uid{$key};
  		}
	}
	undef $sid{$server};
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
		$uid{$user}{'away'} = 1; # We don't want someone to return away 500 times and log flood --Matthew
		event_away($user, $args);
	}
	else {
		# Returning [IRC] :42XAAAAAC AWAY
		if ($uid{$user}{'away'}) {
			event_back($user);
			$uid{$user}{'away'} = 0;
		}
	}
}

1;
