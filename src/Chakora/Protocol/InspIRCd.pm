# protocol/inspircd by The Chakora Project. Link with InspIRCd 1.2/2.0.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;
use lib "../lib";

######### Core #########

our %rawcmds = (
	'UID' => {
		handler => \&raw_uid,
	},
	'PING' => {
		handler => \&raw_ping,
	},
	'QUIT' => {
		handler => \&raw_quit,
	},
	'FJOIN' => {
		handler => \&raw_fjoin,
	},
	'NICK' => {
		handler => \&raw_nick,
	},
	'PART' => {
		handler => \&raw_part,
	},
	'FHOST' => {
		handler => \&raw_fhost,
	},
	'SETIDENT' => {
		handler => \&raw_setident,
	},
	'VERSION' => {
		handler => \&raw_version,
	},
	'PRIVMSG' => {
		handler => \&raw_privmsg,
	},
	'NOTICE' => {
		handler => \&raw_notice,
	},
	'OPERTYPE' => {
		handler => \&raw_opertype,
	},
	'MODE' => {
		handler => \&raw_mode,
	},
	'ERROR' => {
		handler => \&raw_error,
	},
	'ENDBURST' => {
		handler => \&raw_endburst,
	},
	'SQUIT' => {
		handler => \&raw_squit,
	},
	'RSQUIT' => {
		handler => \&raw_squit,
	},
	'AWAY' => {
		handler => \&raw_away,
	},
);
our %PROTO_SETTINGS = (
	name => 'InspIRCd 1.2/2.0',
	owner => '-',
	admin => '-',
	op => 'o',
	halfop => '-',
	voice => 'v',
	mute => 'b m:',
	bexcept => 'e',
	iexcept => 'I',
);

my (%svsuid, %uid, $uid, %sid, $sid, %channel);
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
		send_sock("SERVER ".config('me', 'name')." ".config('server', 'password')." 0 ".config('me', 'sid')." :".config('me', 'info'));
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

######### Sending data #########

# Handle client creation
sub serv_add {
	my ($ruid, $user, $nick, $host, $modes, $real) = @_;
	send_sock(":".svsUID('chakora::server')." UID ".$ruid." ".time()." ".$nick." ".$host." ".$host." ".$user." 0.0.0.0 ".time()." ".$modes." :".$real);
	send_sock(":".$ruid." OPERTYPE Service");
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

# Handle JOIN/FJOIN
sub serv_join {
	my ($svs, $chan) = @_;
	# If a channel has no TS, we're obviously creating that channel, set TS to current time --Matthew
	if (!$channel{$chan}{'ts'}) {
		$channel{$chan}{'ts'} = time();
	} 
	send_sock(":".svsUID("chakora::server")." FJOIN ".$chan." ".$channel{$chan}{'ts'}." + :o,".svsUID($svs));
}

# Handle Client MODE
sub serv_cmode {
	my ($svs, $target, $modes) = @_;
	send_sock(":".svsUID($svs)." MODE ".$target." ".$modes);
}

# Handle FMODE
sub serv_mode {
	my ($svs, $target, $modes) = @_;
	# This should never happen, but just in case, have a check.
	if (!$channel{$target}{'ts'}) {
		$channel{$target}{'ts'} = time();
	}
	send_sock(":".svsUID($svs)." FMODE ".$target." ".$channel{$target}{'ts'}." ".$modes);
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

# Handle CHGHOST
sub serv_chghost {
	my ($user, $newhost) = @_;
	send_sock(":".svsUID('chakora::server')." CHGHOST ".$user." ".$newhost);
}

# Handle CHGIDENT
sub serv_chgident {
	my ($user, $newident) = @_;
	send_sock(":".svsUID('chakora::server')." CHGIDENT ".$user." ".$newident);
}	

# Handle CHGNAME
sub serv_chgname {
	my ($user, $newname) = @_;
	send_sock(":".svsUID('chakora::server')." CHGNAME ".$user." :".$newname);
}	

# Handle WALLOPS
sub serv_wallops {
        my ($msg) = @_;
        send_sock(":".svsUID('chakora::server')." WALLOPS :".$msg);
}

# Set account name
sub serv_accountname {
	my ($user, $name) = @_;
	send_sock(":".svsUID('chakora::server')." METADATA ".$user." accountname :".$name);
}

# Handle when a user logs out of nickserv
sub serv_logout {
        my ($user) = @_;
        send_sock(":".svsUID('chakora::server')." METADATA ".$user." accountname");
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
        # Note: fix jupe later
}

# Send global messages
sub send_global {
	my ($msg) = @_;
	foreach my $key (keys %uid) {
		serv_notice("g", $uid{$key}{'uid'}, $msg);
	}
}

######### Receiving data #########

# Handle CAPAB END
sub raw_capabend {
	my $modes = '+io';
	if ($Chakora::INSPIRCD_SERVICE_PROTECT_MOD) { $modes .= 'k'; }
	send_sock(":".config('me', 'sid')." BURST");
	send_sock(":".config('me', 'sid')." VERSION :".$Chakora::SERVICES_VERSION." ".config('me', 'sid'));
	serv_add(svsUID('g'), config('global', 'user'), config('global', 'nick'), config('global', 'host'), $modes, config('global', 'real'));
	serv_add(svsUID('cs'), config('chanserv', 'user'), config('chanserv', 'nick'), config('chanserv', 'host'), $modes, config('chanserv', 'real'));
	serv_add(svsUID('hs'), config('hostserv', 'user'), config('hostserv', 'nick'), config('hostserv', 'host'), $modes, config('hostserv', 'real'));
	serv_add(svsUID('ms'), config('memoserv', 'user'), config('memoserv', 'nick'), config('memoserv', 'host'), $modes, config('memoserv', 'real'));
	serv_add(svsUID('ns'), config('nickserv', 'user'), config('nickserv', 'nick'), config('nickserv', 'host'), $modes, config('nickserv', 'real'));
	serv_add(svsUID('os'), config('operserv', 'user'), config('operserv', 'nick'), config('operserv', 'host'), $modes, config('operserv', 'real'));
	send_sock(":".config('me', 'sid')." ENDBURST");
}

# Handle UID
sub raw_uid {
	my ($raw) = @_;
	my (@rex);
	@rex = split(' ', $raw);
	my $ruid = $rex[2];
	$uid{$ruid}{'uid'} = $rex[2];
	$uid{$ruid}{'nick'} = $rex[4];
	$uid{$ruid}{'host'} = $rex[5];
	$uid{$ruid}{'mask'} = $rex[6];
	$uid{$ruid}{'user'} = $rex[7];
	$uid{$ruid}{'ip'} = $rex[8];
	$uid{$ruid}{'server'} = substr($rex[0], 1);
	$uid{$ruid}{'pnick'} = 0;
	$uid{$ruid}{'away'} = 0;
	if ($Chakora::IN_DEBUG) { serv_notice('g', $ruid, "Services are in debug mode, be careful when sending messages to services."); }
	event_uid($ruid, $rex[4], $rex[7], $rex[5], $rex[6], $rex[8], substr($rex[0], 1));
}

# Handle PING
sub raw_ping {
	my ($raw) = @_;
	my (@rex);
	@rex = split(' ', $raw);
	send_sock(":".svsUID("chakora::server")." PONG ".$rex[3]." ".$rex[2]);
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

# Handle FJOIN
sub raw_fjoin {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $chan = $rex[2];
        $channel{$chan}{'ts'} = $rex[3];
	my ($args, $i, @users, $juser, @rjuser);
	for ($i = 5; $i < count(@rex); $i++) { $args .= $rex[$i] . ' '; }
	@users = split(' ', $args);
	foreach $juser (@users) {
		undef, @rjuser = split(',', $juser);			
		event_join($rjuser[0], $rex[2]);
	}
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

# Handle MODE
sub raw_mode {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	if ($uid{$rex[2]}{'oper'} and parse_mode($rex[3], '-', 'o')) {
		undef $uid{$rex[2]}{'oper'};
		event_deoper($rex[2]);
	}
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

# Handle FHOST
sub raw_fhost {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = substr($rex[0], 1);
	$uid{$ruid}{'mask'} = $rex[2];
}

# Handle SETIDENT
sub raw_setident {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $ruid = substr($rex[0], 1);
	$uid{$ruid}{'user'} = substr($rex[2], 1);
}

# Handle VERSION
sub raw_version {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
}

# Handle SERVER
sub raw_server {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
        # :490 SERVER test.server password 0 491 :test server
	$sid{$rex[5]}{'sid'} = $rex[5];
	$sid{$rex[5]}{'name'} = $rex[2];
	$sid{$rex[5]}{'hub'} = substr($rex[0], 1);
        my $args = substr($rex[6], 1);
        my ($i);
        for ($i = 7; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        $sid{$rex[5]}{'info'} = $args;
	event_sid($rex[2], $args);
}

# Handle SERVER while linking
sub raw_lserver {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	# SERVER test.server password 0 491 :test server
	$sid{$rex[4]}{'sid'} = $rex[4];
	$sid{$rex[4]}{'name'} = $rex[1];
	$sid{$rex[4]}{'hub'} = 0;
	my $args = substr($rex[5], 1);
        my ($i);
        for ($i = 6; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
	$sid{$rex[4]}{'info'} = $args;
	event_sid($rex[1], $args);
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

# Handle OPERTYPE
sub raw_opertype {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	$uid{$user}{'oper'} = 1;
	event_oper($user);
}

# Handle ERROR without a source server
sub raw_nosrcerror {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $args = substr($rex[1], 1);
        my $i;
        for ($i = 2; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        error("chakora", "[Server Error] ".$args);
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

# Handle ENDBURST
sub raw_endburst {
        serv_join('g', config('log', 'logchan'));
        serv_join('cs', config('log', 'logchan'));
        serv_join('hs', config('log', 'logchan'));
        serv_join('ms', config('log', 'logchan'));
        serv_join('ns', config('log', 'logchan'));
        serv_join('os', config('log', 'logchan'));
	$Chakora::synced = 1;
}

# Handle SQUIT/RSQUIT
sub raw_squit {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $args = substr($rex[3], 1);
        my ($i);
        for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        netsplit($rex[2], $args, substr($rex[0], 1));
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
