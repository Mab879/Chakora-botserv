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
	if (uidInfo($uid, 7)) {
		return 1;
	}
	else {
		return 0;
	}
}

sub is_registered {
	my ($nick) = @_;
	my $check = $Chakora::SVSDB->prepare("SELECT * from nicks WHERE nick='$nick'") or print "Cannot prepare: ".$Chakora::SVSDB->errstr;
        $check->execute() or print "Cannot execute ".$check->errstr();
        print $check->rows();
	if ($check->rows != 0) 
	{
		return 1;
	}
	else 
	{
		return 0;
	}
}

sub svsilog {
	my ($service, $user, $cmd, $args) = @_;
	if (length($args) == 0) {
		serv_privmsg($service, config('log', 'logchan'), uidInfo($user, 1).": \002".uc($cmd)."\002");
	}
	else {
		serv_privmsg($service, config('log', 'logchan'), uidInfo($user, 1).": \002".uc($cmd)."\002: ".$args);
	}
}

sub logchan {
	my ($service, $text) = @_;
	serv_privmsg($service, config('log', 'logchan'), $text);
}
