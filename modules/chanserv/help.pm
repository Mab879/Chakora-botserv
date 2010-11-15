# chanserv/help by The Chakora Project. Adds help functions to ChanServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/help", "The Chakora Project", "0.1", \&init_cs_help, \&void_cs_help);

sub init_cs_help {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/help", "NO_HELP_ENTRY", "NO_HELP_ENTRY", \&svs_cs_help);
	fantasy("help", 0);
}

sub void_cs_help {
	delete_sub 'init_cs_help';
	delete_sub 'svs_cs_help';
	fantasy_del("help");
	cmd_del("chanserv/help");
	delete_sub 'void_cs_help';
}

sub svs_cs_help {
    my ($user, @sargv) = @_;
	if (defined($sargv[1])) {
		my $hcmd = "chanserv/".lc($sargv[1]);
		if (defined($Chakora::HELP{$hcmd}{fhelp}) and $Chakora::HELP{$hcmd}{fhelp} ne "NO_HELP_ENTRY") {
			my @fhelp = split('\n', $Chakora::HELP{$hcmd}{fhelp});
			my ($help);
			serv_notice("chanserv", $user, "\002***** ChanServ Help *****\002");
			serv_notice("chanserv", $user, "Help for \002".uc($sargv[1])."\002:");
			serv_notice("chanserv", $user, "\002\002");
			foreach $help (@fhelp) {
				$help =~ s/\[T\]/     /g;
				serv_notice("chanserv", $user, $help);
			}
			serv_notice("chanserv", $user, "\002\002");
			serv_notice("chanserv", $user, "\002***** End of Help *****\002");
		} else {
			serv_notice("chanserv", $user, "No help available for \002".uc($sargv[1])."\002.");
		}
	} else {
		serv_notice("chanserv", $user, "\002***** ChanServ Help *****\002");
		serv_notice("chanserv", $user, "\002ChanServ\002 allows users to '\002register\002' a channel, and protect");
		serv_notice("chanserv", $user, "it from being taken over.  \002ChanServ\002 will also provide the");
		serv_notice("chanserv", $user, "channel with various options to change how services behave");
		serv_notice("chanserv", $user, "with the channel and how they manage the channel, it will");
		serv_notice("chanserv", $user, "also allow users to be given auto-status (flags) to better");
		serv_notice("chanserv", $user, "manage the channel.");
		serv_notice("chanserv", $user, "\002\002");
		serv_notice("chanserv", $user, "For more information on a command, please type:");
		serv_notice("chanserv", $user, "\002/msg ".$Chakora::svsnick{'chanserv'}." HELP <command>\002");
		serv_notice("chanserv", $user, "\002\002");
		serv_notice("chanserv", $user, "The following commands are available:");
		my %commands = %Chakora::HELP;
		my ($calc, $dv);
		foreach my $key (sort keys %commands) {
			my @skey = split('/', $key);
			if (lc($skey[0]) eq 'chanserv') {
				unless ($commands{$key}{shelp} eq "NO_HELP_ENTRY" or length($key) > 23) {
					$calc = length($key);
					$dv = "";
					while ($calc != 25) {
						$dv .= ' ';
						$calc += 1;
					}
					serv_notice("chanserv", $user, "   \002".uc($skey[1])."\002".$dv.$commands{$key}{shelp});
				}
			}
		}
		serv_notice("chanserv", $user, "\002\002");
		serv_notice("chanserv", $user, "\002***** End of Help *****\002");
	}
}
