# hostserv/help by Russell Bradford. Adds help functions to UtilServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("utilserv/help", "Russell Bradford", "0.1", \&init_us_help, \&void_us_help, "all");

sub init_us_help {
	if (!module_exists("utilserv/main")) {
		module_load("utilserv/main");
	}
	cmd_add("utilserv/help", "NO_HELP_ENTRY", "NO_HELP_ENTRY", \&svs_us_help);
}

sub void_us_help {
	delete_sub 'init_us_help';
	delete_sub 'svs_us_help';
	cmd_del("utilserv/help");
	delete_sub 'void_us_help';
}

sub svs_us_help {
    my ($user, @sargv) = @_;
	if (defined($sargv[1])) {
		my $hcmd = "utilserv/".lc($sargv[1]);
		if (defined($Chakora::HELP{$hcmd}{fhelp}) and $Chakora::HELP{$hcmd}{fhelp} ne "NO_HELP_ENTRY") {
			my @fhelp = split('\n', $Chakora::HELP{$hcmd}{fhelp});
			my ($help);
			serv_notice("utilserv", $user, "\002***** UtilServ Help *****\002");
			serv_notice("utilserv", $user, "Help for \002".uc($sargv[1])."\002:");
			serv_notice("utilserv", $user, "\002\002");
			foreach $help (@fhelp) {
				$help =~ s/\[T\]/     /g;
				serv_notice("utilserv", $user, $help);
			}
			serv_notice("utilserv", $user, "\002\002");
			serv_notice("utilserv", $user, "\002***** End of Help *****\002");
		} else {
			serv_notice("utilserv", $user, "No help available for \002".uc($sargv[1])."\002.");
		}
	} else {
		serv_notice("utilserv", $user, "\002***** UtilServ Help *****\002");
		serv_notice("utilserv", $user, "\002UtilServ\002 allows users to use a variety of non irc related");
		serv_notice("utilserv", $user, "commands to do simple tasks such as looking up dns records, getting");
		serv_notice("utilserv", $user, "the local time from our server and many more useful features.");
		serv_notice("utilserv", $user, "\002\002");
		serv_notice("utilserv", $user, "For more information on a command, please type:");
		serv_notice("utilserv", $user, "\002/msg ".$Chakora::svsnick{'utilserv'}." HELP <command>\002");
		serv_notice("utilserv", $user, "\002\002");
		serv_notice("utilserv", $user, "The following commands are available:");
		my %commands = %Chakora::HELP;
		my ($calc, $dv);
		foreach my $key (sort keys %commands) {
			my @skey = split('/', $key);
			if (lc($skey[0]) eq 'utilserv') {
				unless ($commands{$key}{shelp} eq "NO_HELP_ENTRY" or length($key) > 23) {
					$calc = length($key);
					$dv = "";
					while ($calc != 25) {
						$dv .= ' ';
						$calc += 1;
					}
					serv_notice("utilserv", $user, "   \002".uc($skey[1])."\002".$dv.$commands{$key}{shelp});
				}
			}
		}
		serv_notice("utilserv", $user, "\002\002");
		serv_notice("utilserv", $user, "\002***** End of Help *****\002");
	}
}
