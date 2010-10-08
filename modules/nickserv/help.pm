# nickserv/help by The Chakora Project. Adds help functions to NickServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("nickserv/help", "The Chakora Project", "0.1", \&init_ns_help, \&void_ns_help, "all");

sub init_ns_help {
        if (!module_exists("nickserv/main")) {
                module_load("nickserv/main");
        }
	cmd_add("nickserv/help", "NO_HELP_ENTRY", "NO_HELP_ENTRY", \&svs_ns_help);
}

sub void_ns_help {
	delete_sub 'init_ns_help';
	delete_sub 'svs_ns_help';
	cmd_del("nickserv/help");
	delete_sub 'void_ns_help';
}

sub svs_ns_help {
    my ($user, @sargv) = @_;
	if (defined($sargv[1])) {
		my $hcmd = "nickserv/".lc($sargv[1]);
		if (defined($Chakora::HELP{$hcmd}{fhelp}) and $Chakora::HELP{$hcmd}{fhelp} ne "NO_HELP_ENTRY") {
			my @fhelp = split('\n', $Chakora::HELP{$hcmd}{fhelp});
			my ($help);
			serv_notice("nickserv", $user, "\002***** NickServ Help *****\002");
			serv_notice("nickserv", $user, "Help for \002".uc($sargv[1])."\002:");
			serv_notice("nickserv", $user, "\002\002");
			foreach $help (@fhelp) {
				$help =~ s/\[T\]/     /g;
				serv_notice("nickserv", $user, $help);
			}
			serv_notice("nickserv", $user, "\002\002");
			serv_notice("nickserv", $user, "\002***** End of Help *****\002");
		} else {
			serv_notice("nickserv", $user, "No help available for \002".uc($sargv[1])."\002.");
		}
	} else {
		serv_notice("nickserv", $user, "\002***** NickServ Help *****\002");
		serv_notice("nickserv", $user, "\002NickServ\002 allows users to '\002register\002' a nickname, and stop");
		serv_notice("nickserv", $user, "others from using that nick.  \002NickServ\002 allows the owner of a");
		serv_notice("nickserv", $user, "nickname to disconnect a user from the network that is using their");
		serv_notice("nickserv", $user, "nickname.");
		serv_notice("nickserv", $user, "\002\002");
		serv_notice("nickserv", $user, "For more information on a command, please type:");
		serv_notice("nickserv", $user, "\002/msg ".$Chakora::svsnick{'nickserv'}." HELP <command>\002");
		serv_notice("nickserv", $user, "\002\002");
		serv_notice("nickserv", $user, "The following commands are available:");
		my %commands = %Chakora::HELP;
		my ($calc, $dv);
		foreach my $key (sort keys %commands) {
			my @skey = split('/', $key);
			if (lc($skey[0]) eq 'nickserv') {
				unless ($commands{$key}{shelp} eq "NO_HELP_ENTRY" or length($key) > 23) {
					$calc = length($key);
					$dv = "";
					while ($calc != 25) {
						$dv .= ' ';
						$calc += 1;
					}
					serv_notice("nickserv", $user, "   \002".uc($skey[1])."\002".$dv.$commands{$key}{shelp});
				}
			}
		}
		serv_notice("nickserv", $user, "\002\002");
		serv_notice("nickserv", $user, "\002***** End of Help *****\002");
	}
}
