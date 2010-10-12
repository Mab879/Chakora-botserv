# hostserv/help by The Chakora Project. Adds help functions to HostServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("hostserv/help", "The Chakora Project", "0.1", \&init_hs_help, \&void_hs_help);

sub init_hs_help {
	if (!module_exists("hostserv/main")) {
		module_load("hostserv/main");
	}
	cmd_add("hostserv/help", "NO_HELP_ENTRY", "NO_HELP_ENTRY", \&svs_hs_help);
}

sub void_hs_help {
	delete_sub 'init_hs_help';
	delete_sub 'svs_hs_help';
	cmd_del("hostserv/help");
	delete_sub 'void_hs_help';
}

sub svs_hs_help {
    my ($user, @sargv) = @_;
	if (defined($sargv[1])) {
		my $hcmd = "hostserv/".lc($sargv[1]);
		if (defined($Chakora::HELP{$hcmd}{fhelp}) and $Chakora::HELP{$hcmd}{fhelp} ne "NO_HELP_ENTRY") {
			my @fhelp = split('\n', $Chakora::HELP{$hcmd}{fhelp});
			my ($help);
			serv_notice("hostserv", $user, "\002***** HostServ Help *****\002");
			serv_notice("hostserv", $user, "Help for \002".uc($sargv[1])."\002:");
			serv_notice("hostserv", $user, "\002\002");
			foreach $help (@fhelp) {
				$help =~ s/\[T\]/     /g;
				serv_notice("hostserv", $user, $help);
			}
			serv_notice("hostserv", $user, "\002\002");
			serv_notice("hostserv", $user, "\002***** End of Help *****\002");
		} else {
			serv_notice("hostserv", $user, "No help available for \002".uc($sargv[1])."\002.");
		}
	} else {
		serv_notice("hostserv", $user, "\002***** HostServ Help *****\002");
		serv_notice("hostserv", $user, "\002HostServ\002 allows users to have a vHost (virtual host), having one");
		serv_notice("hostserv", $user, "will mean they will have a custom cloaked host for protecting");
		serv_notice("hostserv", $user, "their true host from other users, and giving them a more eye-");
		serv_notice("hostserv", $user, "appealing visible host in the process.");
		serv_notice("hostserv", $user, "\002\002");
		serv_notice("hostserv", $user, "For more information on a command, please type:");
		serv_notice("hostserv", $user, "\002/msg ".$Chakora::svsnick{'hostserv'}." HELP <command>\002");
		serv_notice("hostserv", $user, "\002\002");
		serv_notice("hostserv", $user, "The following commands are available:");
		my %commands = %Chakora::HELP;
		my ($calc, $dv);
		foreach my $key (sort keys %commands) {
			my @skey = split('/', $key);
			if (lc($skey[0]) eq 'hostserv') {
				unless ($commands{$key}{shelp} eq "NO_HELP_ENTRY" or length($key) > 23) {
					$calc = length($key);
					$dv = "";
					while ($calc != 25) {
						$dv .= ' ';
						$calc += 1;
					}
					serv_notice("hostserv", $user, "   \002".uc($skey[1])."\002".$dv.$commands{$key}{shelp});
				}
			}
		}
		serv_notice("hostserv", $user, "\002\002");
		serv_notice("hostserv", $user, "\002***** End of Help *****\002");
	}
}
