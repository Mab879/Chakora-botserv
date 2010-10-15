# protocol/charybdis by The Chakora Project. Link with Charybdis.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

# This is a cheap hack, but it'll work --Matthew
$Chakora::MODULE{protocol}{name} = 'protocol/charybdis';
$Chakora::MODULE{protocol}{version} = '0.8';
$Chakora::MODULE{protocol}{author} = 'The Chakora Project'; 

######### Core #########
our %rawcmds = (
	'EUID'       => { handler => \&raw_euid, },
	'PING'       => { handler => \&raw_ping, },
	'SJOIN'      => { handler => \&raw_sjoin, },
	'QUIT'       => { handler => \&raw_quit, },
	'JOIN'       => { handler => \&raw_join, },
	'NICK'       => { handler => \&raw_nick, },
	'CHGHOST'    => { handler => \&raw_chghost, },
	'ERROR'      => { handler => \&raw_error, },
	'PRIVMSG'    => { handler => \&raw_privmsg, },
	'NOTICE'     => { handler => \&raw_notice, },
	'PART'       => { handler => \&raw_part, },
	'MODE'       => { handler => \&raw_mode, },
	'SID'        => { handler => \&raw_sid, },
	'SQUIT'      => { handler => \&raw_squit, },
	'AWAY'       => { handler => \&raw_away, },
	'KILL'       => { handler => \&raw_kill, },
	'SAVE'       => { handler => \&raw_save, },
	'ENCAP'      => { handler => \&raw_encap, },
	'KICK'       => { handler => \&raw_kick, },
	'TOPIC'      => { handler => \&raw_topic, },
	'TB'         => { handler => \&raw_tb, },
	'MOTD'       => { handler => \&raw_motd, },
	'ADMIN'      => { handler => \&raw_admin, },
	'TMODE'      => { handler => \&raw_tmode, },
	'MLOCK'      => { handler => \&raw_mlock, },
);

%Chakora::PROTO_SETTINGS = (
	name => 'Charybdis IRCd',
	op => 'o',
	voice => 'v',
	mute => 'q',
	bexcept => 'e',
	iexcept => 'I',
	god => 'S',
	cmodes => {
		'b' => 2,
		'q' => 2,
		'e' => 2,
		'I' => 2,
		'j' => 2,
		'l' => 2,
		'k' => 2,
		'f' => 2,
		'n' => 1,
		't' => 1,
		'i' => 1,
		'P' => 1,
		'L' => 1,
		'Q' => 1,
		's' => 1,
		'C' => 1,
		'F' => 1,
		'z' => 1,
		'g' => 1,
		'c' => 1,
		'm' => 1,
		'p' => 1,
		'r' => 1,
	},
);

our (%uid, %channel, %sid, $hub);
my $lastid = 0;

sub irc_connect {
	if (length(config('me', 'sid')) != 3) {
		error('chakora', 'Services SID have to be 3 characters');
	}
	else {
        	$Chakora::sid{config('me', 'sid')}{'name'} = config('me', 'name');
        	$Chakora::sid{config('me', 'sid')}{'info'} = config('me', 'info');
        	$Chakora::sid{config('me', 'sid')}{'sid'} = config('me', 'sid');
		if (config('services', 'updatets')) {
			foreach my $key (keys %Chakora::DB_chan) {
				$Chakora::channel{$key}{'ts'} = $Chakora::DB_chan{$key}{ts};
			}
		}
		send_sock("PASS ".config('server', 'password')." TS 6 ".config('me', 'sid'));
		# Some of these may not be needed, but let's keep them for now just in case --Matthew
		send_sock("CAPAB :QS KLN UNKLN ENCAP EX CHW IE KNOCK SAVE EUID SERVICES RSFNC MLOCK TB EOPMOD BAN");
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
	return 0;
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

# Handle TOPIC 
sub serv_topic {
        my ( $svs, $chan, $topic ) = @_;
        send_sock(":".svsUID($svs)." TOPIC ".$chan." :".$topic);
}

# Handle MLOCK
# -- This is a Chary only thing --Matthew
sub serv_mlock {
	my ($chan, $mlock) = @_;
	if (!$Chakora::channel{lc($chan)}{'ts'}) {
		$Chakora::channel{lc($chan)}{'ts'} = time();
	}
	send_sock(":".svsUID('chakora::server')." MLOCK ".$Chakora::channel{lc($chan)}{'ts'}." ".$chan." ".$mlock);
	$Chakora::channel{lc($chan)}{'mlock'} = $mlock;
	$Chakora::DB_chan{lc($chan)}{mlock} = $mlock;
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
	# This is a cheap hack, but it'll work for now --Matthew
        raw_tmode(":".svsUID($svs)." TMODE ".$Chakora::channel{lc($target)}{'ts'}." ".$target." ".$modes);

}

# Handle Client MODE (This is basically only used for user mode changes in Charybdis --Matthew)
sub serv_cmode {
	my ($svs, $target, $modes) = @_;
	send_sock(":".svsUID($svs)." MODE ".$target." ".$modes);
}

# Handle ERROR
sub serv_error {
	my ($error) = @_;
	send_sock(":".svsUID('chakora::server')." ERROR :".$error);
}

# Handle INVITE
sub serv_invite {
	my ($svs, $target, $chan) = @_;
        if (!$Chakora::channel{lc($chan)}{'ts'}) {
                $Chakora::channel{lc($chan)}{'ts'} = time();
        }
	send_sock(":".svsUID($svs)." INVITE ".$target." ".$chan." ".$Chakora::channel{lc($chan)}{'ts'});
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
	$Chakora::uid{$user}{'account'} = $name;
}

# Handle when a user logs out of NickServ
sub serv_logout {
	my ($user) = @_;
	send_sock(":".svsUID('chakora::server')." ENCAP * SU ".$user);
	delete $Chakora::uid{$user}{'account'};
}

# Handle KILL
sub serv_kill {
	my ($svs, $user, $reason) = @_; 
	if (length($reason) == 0) {
		send_sock(":".svsUID($svs)." KILL ".$user);
	}
	else {
		send_sock(":".svsUID($svs)." KILL ".$user." :".$reason);
	}
	delete $Chakora::uid{$user};
}

# Handle jupes
sub serv_jupe {
	my ($server, $reason) = @_;
	send_sock(":".svsUID('os')." SQUIT ".$server." :".$reason);
	my ($ssid);
	foreach my $key (keys %Chakora::sid) {
		if ($Chakora::sid{$key}{'name'} eq $server) {
			$ssid = $key;
		}
	}
	send_sock(":".svsUID('chakora::server')." SERVER ".$server." 2 :(JUPED) ".$reason);
	$Chakora::sid{$ssid}{'sid'} = 2;
	$Chakora::sid{$ssid}{'name'} = $server;
	$Chakora::sid{$ssid}{'hub'} = config('me', 'sid');	
	$Chakora::sid{$ssid}{'info'} = "(JUPED) ".$reason;
	foreach my $key (keys %Chakora::uid) {
		if ($Chakora::uid{$key}{'server'} eq $ssid) {
			delete $Chakora::uid{$key};
		}
	}
}

# Handle SQUIT
sub serv_squit {
	my ($server, $reason) = @_;
	send_sock(":".svsUID("chakora::server")." SQUIT $server :$reason");
    if ($server eq config('me', 'sid')) {
		return;
	}
    my ($ssid);
	foreach my $key (keys %Chakora::sid) {
		if ($Chakora::sid{$key}{'name'} eq $server) {
			delete $Chakora::sid{$key};
			$ssid = $key;
		}
	}
	foreach my $key (keys %Chakora::uid) {
		if ($Chakora::uid{$key}{'server'} eq $ssid) {
			delete $Chakora::uid{$key};
		}
	}
}

# Handle CHGHOST
sub serv_chghost {
	my ($user, $newhost) = @_;
	send_sock(":".svsUID("chakora::server")." CHGHOST ".$user." ".$newhost);
}

# Handle GLOBAL
sub serv_global {
 	my ($svs, $msg) = @_;
 	foreach my $key ( keys %uid ) {
        	serv_notice($svs, $Chakora::uid{$key}{'uid'}, $msg);
    	}
}

# Send global messages
sub send_global {
    my ($msg) = @_;
    my $svs = 'operserv';
    if (module_exists("global/main")) {
        $svs = 'global';
    }
    foreach my $key ( keys %uid ) {
        serv_notice($svs, $Chakora::uid{$key}{'uid'}, $msg);
    }
}


# Handle nick enforcement
sub serv_enforce {
        my ($user, $newnick) = @_;
        if (defined $Chakora::uid{$user}{'nick'}) {
                send_sock(":".svsUID('chakora::server')." ENCAP ".sidInfo($Chakora::uid{$user}{'server'}, 1)." RSFNC ".$user." ".$newnick." ".$Chakora::uid{$user}{'ts'}." ".time());
        }
}

# Handle network bans
sub serv_netban {
	my ($user, $host, $duration, $reason) = @_;
	send_sock(":".svsUID("operserv")." ENCAP * KLINE $duration $user $host $reason");
}

######### Receiving data #########

# Handle CAPAB
sub raw_capab {
	
}

# Our Bursting
sub raw_bursting {
	serv_add('operserv', config('operserv', 'user'), config('operserv', 'nick'), config('operserv', 'host'), '+ioS', config('operserv', 'real'));
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
	if ($rex[10] ne '*') {
		$Chakora::uid{$ruid}{'host'} = $rex[10];
	}
	else {
		$Chakora::uid{$ruid}{'host'} = $rex[7];
	}
	$Chakora::uid{$ruid}{'ts'} = $rex[4];
	$Chakora::uid{$ruid}{'server'} = substr($rex[0], 1);
	$Chakora::uid{$ruid}{'pnick'} = 0;
	$Chakora::uid{$ruid}{'away'} = 0;
	if ($rex[5] =~ m/o/) {
		$Chakora::uid{$ruid}{'oper'} = 1;
		event_oper($ruid);
	}
	event_uid($ruid, $rex[2], $rex[6], $rex[10], $rex[7], $rex[8], substr($rex[0], 1));
    	my $svs = 'operserv';
    	if (module_exists("global/main")) {
        	$svs = 'global';
    	}
	if ($Chakora::IN_DEBUG) { serv_notice($svs, $ruid, "Services are in debug mode, be careful when sending messages to services."); }
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
	
	my $bmodes = $rex[4];
	my @smodes = split(//, $bmodes);
	my ($cargs, $modes);
	my $margs = 0;
	foreach my $r (@smodes) {
		if (defined $Chakora::PROTO_SETTINGS{cmodes}{$r}) {
			if ($Chakora::PROTO_SETTINGS{cmodes}{$r} > 1) {
				$margs += $Chakora::PROTO_SETTINGS{cmodes}{$r} - 1;
				$cargs .= ' '.$r.'|'.$Chakora::PROTO_SETTINGS{cmodes}{$r};
			}
			else {
				$modes .= $r;
			}	
		}
	}
	my ($as);
	if (defined $cargs) {
		my (@sargs);
		my $calc = $margs;
		while ($calc > 0) {
			$sargs[$calc] = $rex[$calc+4];
			$calc -= 1;
		}
		my @ms = split(' ', $cargs);
		my $c = 1;
		foreach my $m (@ms) {
			my @t = split('\|', $m);
			$modes .= $t[0];
			$as .= ' '.$sargs[$c];
			$c += 1;
		}
	}
	my ($cmodes);
	if (defined $as) {
		$cmodes = $modes.$as;
	} else {
		$cmodes = $modes;
	}
	$Chakora::channel{lc($chan)}{modes} = $cmodes;
	
    my ($args, $i, @users, $juser, $rjuser);
    for ($i = $margs + 5; $i < count(@rex); $i++) { $args .= $rex[$i].' '; }
    @users = split(' ', $args);
    foreach $juser (@users) {
        $rjuser = substr($juser, length($juser) - 9, 9);
        $Chakora::channel{lc($chan)}{'members'} .= ' '.$rjuser;
        $Chakora::uid{$rjuser}{'chans'} .= ' '.lc($chan);
        event_join($rjuser, $chan);
    }
}

# Handle TMODE
sub raw_tmode {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    
	my $chan = $rex[3];
	my $bmodes = $rex[4];
	my @smodes = split(//, $bmodes);
	my ($cargs, $modes);
	my $margs = 0;
	my $op = 0;
	my (@nomo);
	foreach my $r (@smodes) {
		if ($r eq '+') {
			$op = 1;
		}
		if ($r eq '-') {
			$op = 0;
		}
		if (defined $Chakora::PROTO_SETTINGS{cmodes}{$r} and $op) {
			if ($Chakora::PROTO_SETTINGS{cmodes}{$r} > 1) {
				$margs += $Chakora::PROTO_SETTINGS{cmodes}{$r} - 1;
				$cargs .= ' '.$r.'|'.$Chakora::PROTO_SETTINGS{cmodes}{$r};
			}
			else {
				$modes .= $r;
			}	
		}
		elsif (defined $Chakora::PROTO_SETTINGS{cmodes}{$r} and $op == 0) {
			$nomo[count(@nomo) + 1] = $r;
		}
	}
	my ($as);
	if (defined $cargs) {
		my (@sargs);
		my $calc = $margs;
		while ($calc > 0) {
			$sargs[$calc] = $rex[$calc+4];
			$calc -= 1;
		}
		my @ms = split(' ', $cargs);
		my $c = 1;
		foreach my $m (@ms) {
			my @t = split('\|', $m);
			$modes .= $t[0];
			$as .= ' '.$sargs[$c];
			$c += 1;
		}
	}
	my @curmo = split(' ', $Chakora::channel{lc($chan)}{modes});
	my ($acs);
	my $curmos = $curmo[0];
	foreach my $xc (@nomo) {
		if (defined $xc) {
			if ($curmos =~ m/($xc)/) {
				if ($Chakora::PROTO_SETTINGS{cmodes}{$xc} > 1) {
					my @cmta = split(//, $curmos);
					my $cmtb = 0;
					my $cmtd = 1;
					foreach my $cmtc (@cmta) {
						if ($cmtc eq $xc) {
							$cmtd = 0;
						}
						elsif ($Chakora::PROTO_SETTINGS{cmodes}{$cmtc} > 1 and $cmtd != 0) {
							$cmtb += $Chakora::PROTO_SETTINGS{cmodes}{$cmtc};
						}
					}
					undef $curmo[$cmtb + 1];
				}
				$curmos =~ s/($xc)//g;
			}
			if (defined $modes) {
				if ($modes =~ m/($xc)/) {
					if ($Chakora::PROTO_SETTINGS{cmodes}{$xc} > 1) {
						my @cmtx = split(' ', $as);
						my @cmta = split(//, $curmos);
						my $cmtb = 0;
						my $cmtd = 1;
						foreach my $cmtc (@cmta) {
							if ($cmtc eq $xc) {
								$cmtd = 0;
							}
							elsif ($Chakora::PROTO_SETTINGS{cmodes}{$cmtc} > 1 and $cmtd != 0) {
								$cmtb += $Chakora::PROTO_SETTINGS{cmodes}{$cmtc};
							}	
						}
						undef $cmtx[$cmtb + 1];
						undef $as;
						for (my $i = 1; $i < count(@cmtx); $i++) { if (defined $cmtx[$i]) { $as .= ' '.$cmtx[$i]; } }
					}
					$modes =~ s/($xc)//g;
				}
			}
		}
	}
	if (defined $curmo[1]) {
		for (my $i = 1; $i < count(@curmo); $i++) { if (defined $curmo[$i]) { $acs .= ' '.$curmo[$i]; } }
	}
	my ($finmodes);
	if (defined $curmos) {
		$finmodes .= $curmos;
	}
	if (defined $modes) {
		$finmodes .= $modes;
	}
	if (defined $acs) {
		$finmodes .= $acs;
	}
	if (defined $as) {
		$finmodes .= $as;
	}
	$Chakora::channel{lc($chan)}{modes} = $finmodes;
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
	$Chakora::sid{config('me', 'sid')}{'hub'} = $hub;
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
	my $sid = $rex[2];
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
	
	foreach my $key (keys %Chakora::sid) {
		if ($Chakora::sid{$key}{'hub'} eq $server) {
			foreach my $user (keys %Chakora::uid) {
				if($Chakora::uid{$user}{'server'} eq $Chakora::sid{$key}{'sid'}) {
					delete $Chakora::uid{$user};
				}
			}
			event_netsplit($Chakora::sid{$key}{'sid'}, "Servers hub split...", $source);
			delete $Chakora::sid{$key};
		}
	}
	
	foreach my $key (keys %Chakora::sid) {
		if (!defined($Chakora::sid{$Chakora::sid{$key}{'hub'}}{'sid'})) {
			foreach my $user (keys %Chakora::uid) {
				if ($Chakora::uid{$user}{'server'} eq $Chakora::sid{$key}{'sid'}) {
					delete $Chakora::uid{$user};
				}
			}
			event_netsplit($Chakora::sid{$key}{'sid'}, "Servers hub split...", $source);
			delete $Chakora::sid{$key};
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
    if ($target eq svsUID("operserv")) {
		serv_del("operserv");
		my $modes = '+io';
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add('operserv', config( 'operserv', 'user' ), config( 'operserv', 'nick' ), config( 'operserv', 'host' ), $modes, config( 'operserv', 'real' ));
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
        if (is_registered(2, $chan)) {
		if (metadata(2, $chan, "option:topiclock")) {
			if (has_flag(uidInfo($user, 1), $chan, "t")) {
                		metadata_add(2, $chan, "data:topic", $args);
			}
		}
		else {
			metadata_add(2, $chan, "data:topic", $args);
		}
        }
}

# Handle TB
sub raw_tb {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] :48X TB #services 1284006866 MattB!MattB@127.0.0.1 :loltest
	my @nick = split('!', $rex[4]);
	my $chan = $rex[2];
	my $args = substr($rex[5], 1);
	my ($i);
        for ($i = 6; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        event_stopic($nick[0], $chan, $args);
        if (is_registered(2, $chan)) {
                metadata_add(2, $chan, "data:topic", $args);
        }
}

# Handle KICK
sub raw_kick {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $user = substr($rex[0], 1);
        my $chan = $rex[2];
	my $target = $rex[3];
        my $args = substr($rex[4], 1);
        if ($target eq svsUID("operserv")) {
                serv_join("operserv", $chan);
                serv_kick("operserv", $chan, $user, "Please do not kick services.");
	}
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
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] :48XAAAAAB ENCAP some.server REHASH 
	if ($rex[2] eq config('me', 'name')) {
		# It's being sent to us only!
	}
}

# Handle MLOCK
sub raw_mlock {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# [IRC] :42X MLOCK 1286260382 #services :+nt
	my $ts = $rex[2];
	my $chan = $rex[3];
        my ($i);
        my $args = substr($rex[4], 1);
        for ($i = 5; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	$Chakora::channel{lc($chan)}{'mlock'} = $args;
	if (is_registered(2, $chan)) {
		$Chakora::DB_chan{lc($chan)}{mlock} = $args;
	}
}

# Handle MOTD
sub raw_motd {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	# [IRC] :48XAAAAAB MOTD :34R
	if (substr($rex[2], 1) eq config('me', 'sid')) {
		my $net = config('network', 'name');
		my $ed = config('nickserv', 'enforce_delay');
		my $name = config('me', 'name');
		send_sock(":".svsUID('chakora::server')." 375 ".$user." :- ".config('me', 'name')." Message of the Day -");
		send_sock(":".svsUID('chakora::server')." 372 ".$user." :-");
		if ( -e "$Chakora::ROOT_SRC/../etc/chakora.motd" ) {
    			open FILE, "<$Chakora::ROOT_SRC/../etc/chakora.motd";
    			my @lines = <FILE>;
    			foreach my $line (@lines) {
        			chomp($line);
				$line =~ s/%NAME%/$name/g;
				$line =~ s/%VERSION%/$Chakora::SERVICES_VERSION/g;
				$line =~ s/%NETWORK%/$net/g;
				$line =~ s/%EDELAY%/$ed/g;
				send_sock(":".svsUID('chakora::server')." 372 ".$user." :- ".$line);
			}
		}
		else {
			send_sock(":".svsUID('chakora::server')." 372 ".$user." :- Chakora MOTD file missing");
		}
		send_sock(":".svsUID('chakora::server')." 372 ".$user." :-");
		send_sock(":".svsUID('chakora::server')." 376 ".$user." :End of the message of the day");
	}
}

# Handle ADMIN
sub raw_admin {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $user = substr($rex[0], 1);
        # [IRC] :48XAAAAAB ADMIN :34R
        if (substr($rex[2], 1) eq config('me', 'sid')) {
		send_sock(":".svsUID('chakora::server')." 256 ".$user." :Administrative info about ".config('me', 'name'));
		send_sock(":".svsUID('chakora::server')." 257 ".$user." :".config('network', 'admin')." - Services Administrator");
		send_sock(":".svsUID('chakora::server')." 258 ".$user." :".$Chakora::SERVICES_VERSION." for ".config('network', 'name'));
		send_sock(":".svsUID('chakora::server')." 259 ".$user." :".config('services', 'email'));
	}
}

1;	
