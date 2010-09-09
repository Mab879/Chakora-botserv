# api/server by The Chakora Project. Server-related functions of Chakora's module API.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

sub parse_mode {
	my ($modes, $key, $mode) = @_;
	if ($key eq '+') {
		my @kmodes = split('\+', $modes);
		my (@mmodes);
		foreach my $lmodes (@kmodes) {
			my @nmodes = split('-', $lmodes);
			if (defined $nmodes[0]) {
				push(@mmodes, $nmodes[0]);
			} else {
				push(@mmodes, $lmodes);
			}
		}
		my $ei = 0;
		foreach my $omodes (@mmodes) {
			if ($omodes =~ m/($mode)/) {
				$ei = 1;
			}
		}
		return $ei;
	}
	elsif ($key eq '-') {
		my @kmodes = split('-', $modes);
		my (@mmodes);
		foreach my $lmodes (@kmodes) {
			my @nmodes = split('\+', $lmodes);
			if (defined $nmodes[0]) {
				push(@mmodes, $nmodes[0]);
			} else {
				push(@mmodes, $lmodes);
			}
		}
		my $ei = 0;
		foreach my $omodes (@mmodes) {
			if ($omodes =~ m/($mode)/) {
				$ei = 1;
			}
		}
		return $ei;
	}
}

sub is_soper {
	my ($uid) = @_;
	my $return = 0;
	my @sopers = split(" ", config('operators', 'sra'));
	foreach my $soper (@sopers) {
		if (uidInfo($uid, 9)) {
			if (uidInfo($uid, 7) and uidInfo($uid, 9) eq $soper) {
				$return = 1;
			}
		}
	}
	return $return;
}

sub is_registered {
	my ($nick) = @_;
	if (defined $Chakora::DB_nick{lc($nick)}{account}) {
		return 1;
	}
	else 
	{
		return 0;
	}
}

sub is_identified {
	my ($user) = @_;
	if (defined $Chakora::uid{$user}{'account'}) {
		return 1;
	}
	else {
		return 0;
	}
}

sub svsilog {
	my ($service, $user, $cmd, $args) = @_;
	if (!uidInfo($user, 9)) { $user = uidInfo($user, 1); }
	else { $user = uidInfo($user, 1)." (".uidInfo($user, 9).")"; }
	if (length($args) == 0) {
		serv_privmsg($service, config('log', 'logchan'), "$user: \002".uc($cmd)."\002");
	}
	else {
		serv_privmsg($service, config('log', 'logchan'), "$user: \002".uc($cmd)."\002: ".$args);
	}
}

sub logchan {
	my ($service, $text) = @_;
	serv_privmsg($service, config('log', 'logchan'), $text);
}

sub apply_status {
	my ($user, $chan) = @_;
	if (!uidInfo($user, 9)) {
		return;
	}
	
	my $account = uidInfo($user, 9);
	my ($flags);
	foreach my $key (keys %Chakora::DB_chanflags) {
		if (lc($Chakora::DB_chanflags{$key}{chan}) eq lc($chan) and lc($Chakora::DB_chanflags{$key}{account}) eq lc($account)) {
			$flags = $Chakora::DB_chanflags{$key}{flags};
		}
	}
	
	if (!$flags) {
		return;
	}
	
	my ($modes);
	if ($flags =~ m/q/ and defined($Chakora::PROTO_SETTINGS{owner})) {
		$modes .= $Chakora::PROTO_SETTINGS{owner};
	}
	if ($flags =~ m/a/ and defined($Chakora::PROTO_SETTINGS{admin})) {
		$modes .= $Chakora::PROTO_SETTINGS{admin};
	}
	if ($flags =~ m/O/ and defined($Chakora::PROTO_SETTINGS{op})) {
		$modes .= $Chakora::PROTO_SETTINGS{op};
	}
	if ($flags =~ m/H/ and defined($Chakora::PROTO_SETTINGS{halfop})) {
		$modes .= $Chakora::PROTO_SETTINGS{halfop};
	}
	if ($flags =~ m/V/ and defined($Chakora::PROTO_SETTINGS{voice})) {
		$modes .= $Chakora::PROTO_SETTINGS{voice};
	}
	
	if (length($modes) == 0) {
		return;
	}
	
	my ($tg);
	my $calc = length($modes);
	while ($calc > 0) {
		$tg .= ' '.$user;
		$calc -= 1;
	}
	
	serv_mode("chanserv", $chan, $modes.$tg);
}

1;
