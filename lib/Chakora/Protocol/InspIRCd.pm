# /  __ \ |         | |                  
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#    InspIRCd 1.2/2.0 Linking Module
#	   Chakora::Protocol::InspIRCd
#
# Linking protocol module for InspIRCd 1.2 and 2.0
use strict;
use warnings;
use FindBin qw($_BIN);
use lib "$_BIN/../lib";

######### Core #########

my (@svsuid, %uid);
$svsuid['cs'] = config('server', 'numeric')."AAAAAA";
$svsuid['hs'] = config('server', 'numeric')."AAAAAB";
$svsuid['ms'] = config('server', 'numeric')."AAAAAC";
$svsuid['ns'] = config('server', 'numeric')."AAAAAD";
$svsuid['os'] = config('server', 'numeric')."AAAAAE";
$svsuid['g'] = config('server', 'numeric')."AAAAAF";

sub irc_connect {
	send_sock("SERVER ".config('me', 'name')." ".config('server', 'password')." 0 ".config('me', 'sid')." :".config('me', 'info'));
}

# Get service UID
sub svsUID {
	my ($svs) = @_;
	if (lc($svs) eq 'chakora::server') {
		return config('me', 'sid');
	} else {
		return $svsuid[$svs];
	}
}

# Get UID info
sub uidInfo {
	my ($uid, $section) = @_;
	if ($section == 1) {
		return $uid{$uid}{'nick'};
	} elsif ($section == 2) {
		return $uid{$uid}{'user'};
	} elsif ($section == 3) {
		return $uid{$uid}{'host'};
	} elsif ($section == 4) {
		return $uid{$uid}{'mask'};
	} elsif ($section == 5) {
		return $uid{$uid}{'ip'};
	} elsif ($section == 6) {
		return $uid{$uid}{'real'};
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
	my ($uid, $user, $nick, $host, $modes, $real) = @_;
	send_sock(":".svsUID('chakora::server')." UID ".$uid." ".time()." ".$nick." ".$host." ".$host." ".$user." 0.0.0.0 ".time()." ".$modes." :".$real);
	send_sock(":".$uid." OPERTYPE Service");
}

# Handle PRIVMSG
sub serv_privmsg {
	my ($svs, $target, $msg) = @_;
	send_sock(":".svsUID($svs)." PRIVMSG ".$target." ".$msg);
}

# Handle NOTICE
sub serv_notice {
	my ($svs, $target, $msg) = @_;
	send_sock(":".svsUID($svs)." NOTICE ".$target." ".$msg);
}

# Handle JOIN
sub serv_join {
	my ($svs, $chan) = @_;
	send_sock(":".svsUID($svs)." JOIN ".$chan);
	serv_mode("Chakora::Server", $chan, "+o ".svsUID($svs));
}

# Handle MODE
sub serv_mode {
	my ($svs, $target, $modes) = @_;
	send_sock(":".svsUID($svs)." MODE ".$target." ".$modes);
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

# Handle ENDBURST
sub raw_endburst {
	send_sock(":".config('me', 'sid')." BURST");
	send_sock(":".config('me', 'sid')." VERSION :Chakora-1.0-dev ".config('me', 'sid'));
	serv_add(svsUID('g'), config('global', 'user'), config('global', 'nick'), config('global', 'host'), "+Iiok", config('global', 'real'));
	serv_add(svsUID('cs'), config('chanserv', 'user'), config('chanserv', 'nick'), config('chanserv', 'host'), "+Iiok", config('chanserv', 'real'));
	serv_add(svsUID('hs'), config('hostserv', 'user'), config('hostserv', 'nick'), config('hostserv', 'host'), "+Iiok", config('hostserv', 'real'));
	serv_add(svsUID('ms'), config('memoserv', 'user'), config('memoserv', 'nick'), config('memoserv', 'host'), "+Iiok", config('memoserv', 'real'));
	serv_add(svsUID('ns'), config('nickserv', 'user'), config('nickserv', 'nick'), config('nickserv', 'host'), "+Iiok", config('nickserv', 'real'));
	serv_add(svsUID('os'), config('operserv', 'user'), config('operserv', 'nick'), config('operserv', 'host'), "+Iiok", config('operserv', 'real'));
	serv_join(svsUID('g'), config('log', 'logchan'));
	serv_join(svsUID('cs'), config('log', 'logchan'));
	serv_join(svsUID('hs'), config('log', 'logchan'));
	serv_join(svsUID('ms'), config('log', 'logchan'));
	serv_join(svsUID('ns'), config('log', 'logchan'));
	serv_join(svsUID('os'), config('log', 'logchan'));
	send_sock(":".config('me', 'sid')." ENDBURST");
}

# Handle UID
sub raw_uid {
	my ($raw) = @_;
	my (@rex);
	@rex = split(' ', $raw);
	$uid{$uid}{'uid'} = $rex[0];
	$uid{$uid}{'nick'} = $rex[2];
	$uid{$uid}{'host'} = $rex[3];
	$uid{$uid}{'mask'} = $rex[4];
	$uid{$uid}{'user'} = $rex[5];
	$uid{$uid}{'ip'} = $rex[6];
	$uid{$uid}{'real'} = substr($rex[9], 1);
}
