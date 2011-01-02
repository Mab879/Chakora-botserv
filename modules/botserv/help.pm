# botserv/help by The Chakora Project. Creates channel bot services (BotServ).
#
# Copyright (c) 2010 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("botserv/help", "Franklin  IRC Services", "0.1", \&init_bs_help, \&void_bs_help);

sub init_hs_help {
	if (!module_exists("botserv/main")) {
		module_load("botserv/main");
	}
	cmd_add("botserv/help", "NO_HELP_ENTRY", "NO_HELP_ENTRY", \&svs_bs_help);
}

sub void_hs_help {
	delete_sub 'init_hs_help';
	delete_sub 'svs_hs_help';
	cmd_del("botserv/help");
	delete_sub 'void_hs_help';
}

sub svs_hs_help {
    my ($user, @sargv) = @_;
	if (defined($sargv[1])) {
		my $hcmd = "botserv/".lc($sargv[1]);
		if (defined($Chakora::HELP{$hcmd}{fhelp}) and $Chakora::HELP{$hcmd}{fhelp} ne "NO_HELP_ENTRY") {
			my @fhelp = split('\n', $Chakora::HELP{$hcmd}{fhelp});
			my ($help);
			serv_notice("botserv", $user, "\002***** BotServ Help *****\002");
			serv_notice("botserv", $user, "Help for \002".uc($sargv[1])."\002:");
			serv_notice("botserv", $user, "\002\002");
			foreach $help (@fhelp) {
				$help =~ s/\[T\]/     /g;
				serv_notice("botservserv", $user, $help);
			}
			serv_notice("botserv", $user, "\002\002");
			serv_notice("botserv", $user, "\002***** End of Help *****\002");
		} else {
			serv_notice("botserv", $user, "No help available for \002".uc($sargv[1])."\002.");
		}
	} else {
		serv_notice("botserv", $user, "\002***** BotServ Help *****\002");
		serv_notice("botserv", $user, "\00BotServ\002 allows channel owners to have a Services bot");
		serv_notice("botserv", $user, "in there channel. It serves as a protection bot and ");
		serv_notice("botserv", $user, "allows the use of \002FANSTY\002 commands.");
		serv_notice("botserv", $user, "\002\002");
		serv_notice("botserv", $user, "For more information on a command, please type:");
		serv_notice("botserv", $user, "\002/msg ".$Chakora::svsnick{'botserv'}." HELP <command>\002");
		serv_notice("botserv", $user, "\002\002");
		serv_notice("botserv", $user, "The following commands are available:");
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
					serv_notice("botserv", $user, "   \002".uc($skey[1])."\002".$dv.$commands{$key}{shelp});
				}
			}
		}
		serv_notice("botserv", $user, "\002\002");
		serv_notice("botserv", $user, "\002***** End of Help *****\002");
	}
}
