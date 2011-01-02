# chanserv/flags by The Chakora Project. Allows users to set and view flags.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/flags", "The Chakora Project", "0.1", \&init_cs_flags, \&void_cs_flags, "all");

sub init_cs_flags {
        if (!module_exists("chanserv/main")) {
                module_load("chanserv/main");
        }
        cmd_add("chanserv/flags", "View and edit users access", "FLAGS allows you to view and manage your channels access list", \&svs_cs_flags);
	fantasy("flags", 1);
}

sub void_cs_flags {
	delete_sub 'init_cs_flags';
	delete_sub 'svs_cs_flags';
	delete_sub 'cs_listflags';
	delete_sub 'cs_setflags';
	delete_sub 'already_setting';
	cmd_del("chanserv/flags");
	delete_sub 'void_cs_flags';
}

sub svs_cs_flags {
        my ($user, @sargv) = @_;
	
        if (!defined($sargv[1])) {
                serv_notice("chanserv", $user, "Not enough parameters. Syntax: FLAGS <#channel> [nick] [flags]");
                return;
        }
        if (!uidInfo($user, 9)) {
                serv_notice("chanserv", $user, "You must be logged in to perform this operation.");
                return;
        }
        if (substr($sargv[1], 0, 1) ne '#') {
                serv_notice("chanserv", $user, "Invalid channel name.");
                return;
        }
        if (!defined $Chakora::DB_chan{lc($sargv[1])}{name}) {
                serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 is not registered.");
                return;
        }
	if (defined($sargv[2]) and defined($sargv[3])) {
		if (has_flag(uidInfo($user, 9), $sargv[1], "m")) {
			cs_setflags($user, $sargv[1], $sargv[2], $sargv[3]);
		}
		else {
			serv_notice("chanserv", $user, "You do not have permission to set flags in \002".$sargv[1]."\002.");
		}
	}
	if (defined($sargv[1]) and !defined($sargv[2])) {
		cs_listflags($user, $sargv[1]);
	}
}

sub cs_listflags {
	my ($user, $chan) = @_;
	serv_notice("chanserv", $user, "\002*** ".$chan." flag list ***\002");
	foreach my $flag (keys %Chakora::DB_chanflags) {
		if (lc($Chakora::DB_chanflags{$flag}{chan} eq lc($chan))) {
			serv_notice("chanserv", $user, "\002".$Chakora::DB_chanflags{$flag}{account}."\002 - \002".substr($Chakora::DB_chanflags{$flag}{flags},1)."\002");
		}
	}
	serv_notice("chanserv", $user, "\002*** End flag list ***\002");
}

sub already_setting {
	my ($flag, @array) = @_;
	my $repeat;
	foreach my $flags (@array) {
		if ($flags eq $flag) {
			$repeat++;
		}
	}
	if ($repeat > 1) { return 1; } else { return 0; }
}

sub cs_setflags {
	my ($user, $chan, $account, $srflags) = @_;
	
	# Make sure the target account is registered.
	if (!is_registered(1, $account)) {
		serv_notice("chanserv", $user, "User \002$account\002 is not registered.");
		return;
	}
	
	# Sort out the changes (if any).
	my $bflags = $srflags;
	my @sflags = split(//, $bflags);
	my ($flags);
	my $op = 0;
	my (@nomo, $nomon);
	foreach my $r (@sflags) {
		if ($r eq '+') {
			$op = 1;
		}
		if ($r eq '-') {
			$op = 0;
		}
		if (flag_exists($r) and $op) {
			$flags .= $r;
		}
		elsif (flag_exists($r) and $op == 0) {
			$nomo[count(@nomo) + 1] = $r;
			$nomon = 1;
		}
	}
	if (!defined $flags) { $flags = 0; }
	
	# Sort out existing flags.
	my ($oflags);
	foreach my $acfm (keys %Chakora::DB_chanflags) {
		if (lc($Chakora::DB_chanflags{$acfm}{chan}) eq lc($chan) and lc($Chakora::DB_chanflags{$acfm}{account}) eq lc($account)) {
			if (defined $Chakora::DB_chanflags{$acfm}{flags}) {
				$oflags = $Chakora::DB_chanflags{$acfm}{flags}; $oflags =~ s/\+//g;
				if ($Chakora::DB_chanflags{$acfm}{flags} eq '+') {
					$oflags = 0;
				}
			}
			else {
				$oflags = 0;
			}
		}
	}
	
	# Make sure they're actually making changes.
 	if ($flags eq $oflags and !defined $nomon) {
		serv_notice("chanserv", $user, "Flags unchanged.");
		return;
	}
	else {
		my ($noof);
		my @nofa = split(//, $oflags);
		foreach my $noff (@nofa) {
			if (flag_exists($noff)) {
				$noof .= $noff;
			}
		}
		if ($flags eq $noof and !defined $nomon) {
			serv_notice("chanserv", $user, "Flags unchanged.");
			return;
		}
	}
	
	# Make all changes.
	my $nflags = $oflags;
	my @ncflags = split(//, $flags);
	foreach my $r (@ncflags) {
		if ($oflags !~ m/($r)/) {
			$nflags .= $r;
		}
	}
	foreach my $r (@nomo) {
		if (defined $r) {
			$nflags =~ s/($r)//g;
		}
	}
	foreach my $acfm (keys %Chakora::DB_chanflags) {
		if (lc($Chakora::DB_chanflags{$acfm}{chan}) eq lc($chan) and lc($Chakora::DB_chanflags{$acfm}{account}) eq lc($account)) {
			$Chakora::DB_chanflags{$acfm}{flags} = '+'.$nflags;
		}
	}
	
	# Done.
	serv_notice("chanserv", $user, "Flags for \002$account\002 on \002$chan\002 changed to \002$nflags\002.");
}

1;
