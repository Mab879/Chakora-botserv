# operserv/help by The Chakora Project. Adds help functions to OperServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/help", "The Chakora Project", "0.1", \&init_os_help, \&void_os_register);

sub init_os_help {
	cmd_add("operserv/help", "NO_HELP_ENTRY", "NO_HELP_ENTRY", \&svs_os_help);
}

sub void_os_help {
	delete_sub 'init_os_help';
	delete_sub 'svs_os_help';
	cmd_del("operserv/help");
	delete_sub 'void_os_help';
}

sub svs_os_help {
    my ($user, @sargv) = @_;
	if (defined($sargv[1])) {
		my $hcmd = "operserv/".lc($sargv[1]);
		if (defined($Chakora::HELP{$hcmd}{fhelp}) and $Chakora::HELP{$hcmd}{fhelp} ne "NO_HELP_ENTRY") {
			my @fhelp = split('\n', $Chakora::HELP{$hcmd}{fhelp});
			my ($help);
			serv_notice("operserv", $user, "\002***** OperServ Help *****\002");
			serv_notice("operserv", $user, "Help for \002".uc($sargv[1])."\002:");
			serv_notice("operserv", $user, "\002\002");
			foreach $help (@fhelp) {
				$help =~ s/\[T\]/     /g;
				serv_notice("operserv", $user, $help);
			}
			serv_notice("operserv", $user, "\002\002");
			serv_notice("operserv", $user, "\002***** End of Help *****\002");
		} else {
			serv_notice("operserv", $user, "No help available for \002".uc($sargv[1])."\002.");
		}
	} else {
		serv_notice("operserv", $user, "\002***** OperServ Help *****\002");
		serv_notice("operserv", $user, "\002OperServ\002 allows opers to better control services.");
		serv_notice("operserv", $user, "\002\002");
		serv_notice("operserv", $user, "For more information on a command, please type:");
		serv_notice("operserv", $user, "\002/msg ".$Chakora::svsnick{'operserv'}." HELP <command>\002");
		serv_notice("operserv", $user, "\002\002");
		serv_notice("operserv", $user, "The following commands are available:");
		my %commands = %Chakora::HELP;
		my ($calc, $dv);
		foreach my $key (sort keys %commands) {
			my @skey = split('/', $key);
			if (lc($skey[0]) eq 'operserv') {
				unless ($commands{$key}{shelp} eq "NO_HELP_ENTRY" or length($key) > 23) {
					$calc = length($key);
					$dv = "";
					while ($calc != 25) {
						$dv .= ' ';
						$calc += 1;
					}
					serv_notice("operserv", $user, "   \002".uc($skey[1])."\002".$dv.$commands{$key}{shelp});
				}
			}
		}
		serv_notice("operserv", $user, "\002\002");
		serv_notice("operserv", $user, "\002***** End of Help *****\002");
	}
}
