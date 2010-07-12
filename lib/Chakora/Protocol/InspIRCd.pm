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

######### Receiving data #########

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
