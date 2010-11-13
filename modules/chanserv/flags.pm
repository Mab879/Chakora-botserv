# chanserv/flags by The Chakora Project. Allows users to set and view flags.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/flags", "The Chakora Project", "0.1", \&init_cs_flags, \&void_cs_flags, "all");

sub init_cs_flags {
        if (!module_exists("chanserv/main")) {
                module_load("chanserv/main");
        }
        cmd_add("chanserv/flags", "View and edit users access", "FLAGS allows you to view and manage your channels access list", \&svs_cs_flags);
}

sub void_cs_flags {
        delete_sub 'init_cs_flags';
        delete_sub 'svs_cs_flags';
	delete_sub 'cs_listflags';
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
			serv_notice("chanserv", $user, "You do not have permission to set flags in ".$sargv[1]);
		}
	}
	if (defined($sargv[1]) and !defined($sargv[2])) {
		cs_listflags($user, $sargv[1]);
	}
}

sub cs_listflags {
	my ($user, $chan) = @_;
	serv_notice("chanserv", $user, "*** ".$chan." flag list ***");
	foreach my $flag (keys %Chakora::DB_chanflags) {
		if (lc($Chakora::DB_chanflags{$flag}{chan} eq lc($chan))) {
			serv_notice("chanserv", $user, $Chakora::DB_chanflags{$flag}{account}." - ".substr($Chakora::DB_chanflags{$flag}{flags},1));
		}
	}
	serv_notice("chanserv", $user, "*** End flag list ***");
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
	my ($user, $chan, $account, $flags) = @_;
	my $sflag;
	my @uflag = ('');
	my @flag = split(//, $flags);
	my $op;
	foreach my $f (@flag) {
		push(@uflag, $f);
		if (has_flag($account, $chan, $f) and flag_exists($f) and !already_setting($f, @uflag)) {
			# the user already has these flags
		}
		if (flag_exists($f) and !already_setting($f, @uflag)) {
			$sflag .= $f."";
			my @tmp_flags = split(/(\+ | \-)/, $sflag);
			foreach my $tmp_F (@tmp_flags) {
				if ($tmp =~ /\+/) {
					$sflaf = $tmp_F;
					$op = $tmp_flags[$. - 1];
				}
				elsif ($tmp =~ /\-/) {
					$sflaf = $tmp_F;
					$op = $tmp_flafs[$. - 1];
				}
				if (length($sflag) => 1) { 
					flags($chan, $account, $op.$sflag);
				}
				else {
					delete $Chakora::DB_chanflags{$account};
					return;
				}
				if ($sflag) { serv_notice("chanserv", $user, "Set flags ".$sflag." on ".$account); }
			}
		}
		else { 
			# these flags done exist
		}
	}
	
}
