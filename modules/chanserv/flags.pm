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
	my ($user, $chan, $account, $srflags) = @_;
	
	my $bflags = $srflags;
	my @sflags = split(//, $bflags);
	my ($cargs, $flags);
	my $margs = 0;
	my $op = 0;
	my (@nomo);
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
		}
	}
	my ($as);
	my ($acs);
	my $curmos = $curmo[0];
	foreach my $xc (@nomo) {
		if (defined $xc) {
			if ($curmos =~ m/($xc)/) {
				if ($Chakora::PROTO_SETTINGS{cflags}{$xc} > 1) {
					my @cmta = split(//, $curmos);
					my $cmtb = 0;
					my $cmtd = 1;
					foreach my $cmtc (@cmta) {
						if ($cmtc eq $xc) {
							$cmtd = 0;
						}	
						elsif ($Chakora::PROTO_SETTINGS{cflags}{$cmtc} > 1 and $cmtd != 0) {
							$cmtb += $Chakora::PROTO_SETTINGS{cflags}{$cmtc};
						}
					}
					undef $curmo[$cmtb + 1];
				}	
				$curmos =~ s/($xc)//g;
			}	
			if (defined $flags) {
				if ($flags =~ m/($xc)/) {
					if ($Chakora::PROTO_SETTINGS{cflags}{$xc} > 1) {
						my @cmtx = split(' ', $as);
						my @cmta = split(//, $curmos);
						my $cmtb = 0;
						my $cmtd = 1;
						foreach my $cmtc (@cmta) {
							if ($cmtc eq $xc) {
								$cmtd = 0;
							}
							elsif ($Chakora::PROTO_SETTINGS{cflags}{$cmtc} > 1 and $cmtd != 0) {
								$cmtb += $Chakora::PROTO_SETTINGS{cflags}{$cmtc};
							}	
						}
						undef $cmtx[$cmtb + 1];
						undef $as;
						for (my $i = 1; $i < count(@cmtx); $i++) { if (defined $cmtx[$i]) { $as .= ' '.$cmtx[$i]; } }
					}
					$flags =~ s/($xc)//g;
				}	
			}
		}
	}
	if (defined $curmo[1]) {
		for (my $i = 1; $i < count(@curmo); $i++) { if (defined $curmo[$i]) { $acs .= ' '.$curmo[$i]; } }
	}
	my ($finflags);
	if (defined $curmos) {
		$finflags .= $curmos;
	}
	if (defined $flags) {
		$finflags .= $flags;
	}
	if (defined $acs) {
		$finflags .= $acs;
	}
	if (defined $as) {
		$finflags .= $as;
	}
	flags($chan, $account, $finflags);
	serv_notice("chanserv", $user, "Set flags for \002".$account."\002 on \002".$chan."\002 to \002".$finflags."\002"); 
}
