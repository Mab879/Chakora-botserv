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
	'SAVE' => {
		handler => \&raw_save,
	},
	'ENCAP' => {
		handler => \&raw_encap,
	},
	'KICK' => {
		handler => \&raw_kick,
	},
	'TOPIC' => {
		handler => \&raw_topic,
	},
);
%Chakora::PROTO_SETTINGS = (
	name => 'Charybdis IRCd',
	op => 'o',
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
		if (config('services', 'updatets')) {
			foreach my $key (keys %Chakora::DB_chan) {
				$Chakora::channel{$key}{'ts'} = $Chakora::DB_chan{$key}{ts};
			}
		}
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
	} elsif ($section == 9) {
		return $Chakora::uid{$ruid}{'account'};
	} elsif ($section == 10) {
		return $Chakora::uid{$ruid}{'chans'};
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
	foreach my $key (keys %Chakora::uid) {
		if (lc($Chakora::uid{$key}{'nick'}) eq lc($nick)) {
			return $Chakora::uid{$key}{'uid'};
		}
	}
}

# Check if a user is on a channel
sub isonchan {
	my ($user, $chan) = @_;
	$chan = lc($chan);
	$user = uc($user);
	my $i = 0;
	my @members = split(' ', $Chakora::channel{$chan}{'members'});
    foreach my $member (@members) {
		if ($member eq $user) {
			$i = 1;
		}
	}
	return $i;
}

######### Sending data #########

# Send raw data to server in full compliance with the API
sub serv_ {
	my ($svs, $data) = @_;
	send_sock(":".svsUID($svs)." $data");
}

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
	$Chakora::svsnick{$svs} = $nick;
	send_sock(":".svsUID('chakora::server')." EUID ".$nick." 0 ".time()." ".$modes." ".$user." ".$host." 0.0.0.0 ".$ruid." ".config('me', 'name')." * :".$real);
	if ($Chakora::synced) { serv_join($svs, config('log', 'logchan')); }
}

# Handle client deletion
sub serv_del {
	my ($svs) = @_;
	if (defined $Chakora::svsuid{lc($svs)}) {
		logchan('operserv', "\002!!!\002 Deleting service: \002$svs\002");
		serv_quit(lc($svs), "Service unloaded");
		delete $Chakora::svsuid{lc($svs)};
		delete $Chakora::svsnick{lc($svs)};
	}
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
        # If a channel has no ts, we're obviously creating that channel, set TS to current time --Matthew
	if (!$Chakora::channel{lc($chan)}{'ts'}) {
		$Chakora::channel{lc($chan)}{'ts'} = time();
	}
	my $modes = '+';
	if (defined $Chakora::DB_chan{lc($chan)}{mlock}) {
		$modes = $Chakora::DB_chan{lc($chan)}{mlock};
	}
	send_sock(":".svsUID('chakora::server')." SJOIN ".$Chakora::channel{lc($chan)}{'ts'}." ".$chan." $modes :@".svsUID($svs));
}

# Handle TMODE
sub serv_mode {
	my ($svs, $target, $modes) = @_;
	# This should never happen, but just in case, have a check. --Matthew
        if (!$Chakora::channel{lc($target)}{'ts'}) {
                $Chakora::channel{lc($target)}{'ts'} = time();
        }
	send_sock(":".svsUID($svs)." TMODE ".$Chakora::channel{lc($target)}{'ts'}." ".$target." ".$modes);
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

# Handle nick enforcement
sub serv_enforce {
        my ($user, $newnick) = @_;
        if (defined $Chakora::uid{$user}{'nick'}) {
                send_sock(":".svsUID('chakora::server')." ENCAP ".sidInfo($Chakora::uid{$user}{'server'}, 1)." RSFNC ".$user." ".$newnick." ".$Chakora::uid{$user}{'ts'}." ".time());
        }
}

######### Receiving data #########

# Our Bursting
sub raw_bursting {
	serv_add('global', config('global', 'user'), config('global', 'nick'), config('global', 'host'), '+ioS', config('global', 'real'));
	serv_add('nickserv', config('nickserv', 'user'), config('nickserv', 'nick'), config('nickserv', 'host'), '+ioS', config('nickserv', 'real'));
	serv_add('operserv', config('operserv', 'user'), config('operserv', 'nick'), config('operserv', 'host'), '+ioS', config('operserv', 'real'));
	create_cmdtree("nickserv");
	create_cmdtree("operserv");
	event_pds();
}	

# Handle END SYNC
sub raw_endsync {
	unless ($Chakora::synced) {
		foreach my $key (sort keys %Chakora::svsuid) {
			serv_join($key, config('log', 'logchan'));
		}
		$Chakora::synced = 1;
		event_eos();
	}
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
	$Chakora::uid{$ruid}{'ts'} = $rex[4];
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
	if (!defined($Chakora::channel{lc($chan)}{'ts'})) {
		$Chakora::channel{lc($chan)}{'ts'} = $rex[2];
	}
    my ($args, $i, @users, $juser, $rjuser);
    for ($i = 5; $i < count(@rex); $i++) { $args .= $rex[$i].' '; }
    @users = split(' ', $args);
    foreach $juser (@users) {
        $rjuser = substr($juser, length($juser) - 9, 9);
        $Chakora::channel{lc($chan)}{'members'} .= ' '.$rjuser;
        $Chakora::uid{$rjuser}{'chans'} .= ' '.lc($chan);
        event_join($rjuser, $chan);
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
	my @chns = split(' ', $Chakora::uid{$ruid}{'chans'});
	foreach my $chn (@chns) {
		my @members = split(' ', $Chakora::channel{$chn}{'members'});
		my ($newmem);
		foreach my $member (@members) {
			unless ($member eq $ruid) {
				$newmem .= ' '.$member;
			}
		}
		$Chakora::channel{$chn}{'members'} = $newmem;
	}
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
	$Chakora::channel{lc($rex[3])}{'members'} .= ' '.substr($rex[0], 1);
	$Chakora::uid{substr($rex[0], 1)}{'chans'} .= ' '.lc($rex[3]);
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
    my @members = split(' ', $Chakora::channel{lc($rex[2])}{'members'});
    my ($newmem);
    foreach my $member (@members) {
		unless ($member eq $user) {
			$newmem .= ' '.$member;
		}
	}
	$Chakora::channel{lc($rex[2])}{'members'} = $newmem;
	my @chns = split(' ', $Chakora::uid{$user}{'chans'});
	my ($newchns);
	foreach my $chn (@chns) {
		unless ($chn eq lc($rex[2])) {
			$newchns .= ' '.$chn;
		}
	}
	$Chakora::uid{$user}{'chans'} = $newchns;
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
	$Chakora::uid{$ruid}{'ts'} = substr($rex[3], 1);
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
	foreach my $key (keys %Chakora::uid) {
  		if ($Chakora::uid{$key}{'server'} eq $server) {
    			delete $Chakora::uid{$key};
  		}
	}
	delete $Chakora::sid{$server};
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
	my @chns = split(' ', $Chakora::uid{$user}{'chans'});
	foreach my $chn (@chns) {
		my @members = split(' ', $Chakora::channel{$chn}{'members'});
		my ($newmem);
		foreach my $member (@members) {
			unless ($member eq $user) {
				$newmem .= ' '.$member;
			}
		}
		$Chakora::channel{$chn}{'members'} = $newmem;
	}
	event_kill($user, $target, $args);
	if (defined $Chakora::uid{$user}) {
		undef $Chakora::uid{$user};
	}
}

# Handle SAVE
sub raw_save {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $i = 0;
	foreach my $key (keys %Chakora::svsuid) {
		if ($rex[2] eq $Chakora::svsuid{$key}) {
			$Chakora::svsnick{lc($key)} = $rex[2];
			$i = 1;
		}
	}
	if ($i == 0) {
		$Chakora::uid{$rex[2]}{'nick'} = $rex[2];
	}
}

# Handle TOPIC
sub raw_topic {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	my $chan = $rex[2];
        my $args = substr($rex[3], 1);
        my ($i);
        for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	event_topic($user, $chan, $args);
}

# Handle KICK
sub raw_kick {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $user = substr($rex[0], 1);
        my $chan = $rex[2];
	my $target = $rex[3];
        my $args = substr($rex[4], 1);
        my ($i);
        for ($i = 5; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
    my @members = split( ' ', $Chakora::channel{ lc( $chan ) }{'members'} );
    my ($newmem);
    foreach my $member (@members) {
        unless ( $member eq $target ) {
            $newmem .= ' ' . $member;
        }
    }
    my @chns = split( ' ', $Chakora::uid{$target}{'chans'} );
    my ($newchns);
    foreach my $chn (@chns) {
        unless ( $chn eq lc( $chan ) ) {
            $newchns .= ' ' . $chn;
        }
    }
    $Chakora::uid{$user}{'chans'} = $newchns;
    $Chakora::channel{ lc( $chan ) }{'members'} = $newmem;
	event_kick($user, $chan, $target, $args);
}

# Handle ENCAP
sub raw_encap {

}

1;
