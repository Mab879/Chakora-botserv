# /  __ \ |         | |                  
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#    InspIRCd 1.2/2.0 Linking Module
#	   Chakora::Protocol::InspIRCd
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
	'FJOIN' => {
		handler => \&raw_fjoin,
	},
);
our %PROTO_SETTINGS = (
	name => 'InspIRCd',
	owner => '-',
	admin => '-',
	op => 'o',
	halfop => '-',
	voice => 'v',
	mute => 'b m:',
	bexcept => 'e',
	iexcept => 'I',
);
my (%svsuid, %uid, $uid);
$svsuid{'cs'} = config('me', 'sid')."AAAAAA";
$svsuid{'hs'} = config('me', 'sid')."AAAAAB";
$svsuid{'ms'} = config('me', 'sid')."AAAAAC";
$svsuid{'ns'} = config('me', 'sid')."AAAAAD";
$svsuid{'os'} = config('me', 'sid')."AAAAAE";
$svsuid{'g'} = config('me', 'sid')."AAAAAF";

sub irc_connect {
	send_sock("SERVER ".config('me', 'name')." ".config('server', 'password')." 0 ".config('me', 'sid')." :".config('me', 'info'));
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
	send_sock(":".svsUID("chakora::server")." FJOIN ".$chan." ".time()." + :,".svsUID($svs));
	serv_mode("chakora::server", $chan, "+o ".svsUID($svs));
}

# Handle MODE
sub serv_mode {
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

######### Receiving data #########

# Handle CAPAB END
sub raw_capabend {
	send_sock(":".config('me', 'sid')." BURST");
	send_sock(":".config('me', 'sid')." VERSION :Chakora-1.0-dev ".config('me', 'sid'));
	serv_add(svsUID('g'), config('global', 'user'), config('global', 'nick'), config('global', 'host'), "+iok", config('global', 'real'));
	serv_add(svsUID('cs'), config('chanserv', 'user'), config('chanserv', 'nick'), config('chanserv', 'host'), "+iok", config('chanserv', 'real'));
	serv_add(svsUID('hs'), config('hostserv', 'user'), config('hostserv', 'nick'), config('hostserv', 'host'), "+iok", config('hostserv', 'real'));
	serv_add(svsUID('ms'), config('memoserv', 'user'), config('memoserv', 'nick'), config('memoserv', 'host'), "+iok", config('memoserv', 'real'));
	serv_add(svsUID('ns'), config('nickserv', 'user'), config('nickserv', 'nick'), config('nickserv', 'host'), "+iok", config('nickserv', 'real'));
	serv_add(svsUID('os'), config('operserv', 'user'), config('operserv', 'nick'), config('operserv', 'host'), "+iok", config('operserv', 'real'));
	serv_join('g', config('log', 'logchan'));
	serv_join('cs', config('log', 'logchan'));
	serv_join('hs', config('log', 'logchan'));
	serv_join('ms', config('log', 'logchan'));
	serv_join('ns', config('log', 'logchan'));
	serv_join('os', config('log', 'logchan'));
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
}

# Handle PING
sub raw_ping {
	my ($raw) = @_;
	my (@rex);
	@rex = split(' ', $raw);
	send_sock(":".svsUID("chakora::server")." PONG ".$rex[3]." ".$rex[2]);
}

# Handle FJOIN
sub raw_fjoin {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my ($args, $i, @users, $juser, @rjuser);
	for ($i = 5; $i < count(@rex); $i++) { $args .= $rex[$i] . ' '; }
	@users = split(' ', $args);
	foreach $juser (@users) {
		@rjuser = split(',', $juser);
		event_join($rjuser[1], $rex[2]);
	}
}

1;
