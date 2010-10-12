# DNSBL/help by The Chakora Project. Adds help functions to DNSBL.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("dnsbl/help", "The Chakora Project", "0.1", \&init_dns_help, \&void_dns_help);

sub init_dns_help {
	if (!module_exists("dnsbl/main")) {
		module_load("dnsbl/main");
	}
	cmd_add("dnsbl/help", "NO_HELP_ENTRY", "NO_HELP_ENTRY", \&svs_dns_help);
}

sub void_dns_help {
	delete_sub 'init_dns_help';
	delete_sub 'svs_dns_help';
	cmd_del("dnsbl/help");
	delete_sub 'void_dns_help';
}

sub svs_dns_help {
    my ($user, @sargv) = @_;
	if (defined($sargv[1])) {
		my $hcmd = "dnsbl/".lc($sargv[1]);
		if (defined($Chakora::HELP{$hcmd}{fhelp}) and $Chakora::HELP{$hcmd}{fhelp} ne "NO_HELP_ENTRY") {
			my @fhelp = split('\n', $Chakora::HELP{$hcmd}{fhelp});
			my ($help);
			serv_notice("dnsbl", $user, "\002***** DNSBL Help *****\002");
			serv_notice("dnsbl", $user, "Help for \002".uc($sargv[1])."\002:");
			serv_notice("dnsbl", $user, "\002\002");
			foreach $help (@fhelp) {
				$help =~ s/\[T\]/     /g;
				serv_notice("dnsbl", $user, $help);
			}
			serv_notice("dnsbl", $user, "\002\002");
			serv_notice("dnsbl", $user, "\002***** End of Help *****\002");
		} else {
			serv_notice("dnsbl", $user, "No help available for \002".uc($sargv[1])."\002.");
		}
	}
	else
	{
   		serv_notice("dnsbl", $user, "\002***** DNSBL Help *****\002");
    		serv_notice("dnsbl", $user, "This DNSBL Module checks user's IP addresses against a long");
    		serv_notice("dnsbl", $user, "and comprehensive list of databases to check if the ip is");
    		serv_notice("dnsbl", $user, "blacklisted. If the IP is blacklisted, the user is killed");
    		serv_notice("dnsbl", $user, "from the network explaining what list their ip is in and");
    		serv_notice("dnsbl", $user, "the reason number that goes with it.");
		serv_notice("dnsbl", $user, "\002\002");
		serv_notice("dnsbl", $user, "The following commands are available:");
		my %commands = %Chakora::HELP;
		my ($calc, $dv);
		foreach my $key (sort keys %commands) {
			my @skey = split('/', $key);
			if (lc($skey[0]) eq 'dnsbl') {
				unless ($commands{$key}{shelp} eq "NO_HELP_ENTRY" or length($key) > 23) {
					$calc = length($key);
					$dv = "";
					while ($calc != 25) {
						$dv .= ' ';
						$calc += 1;
					}
					serv_notice("dnsbl", $user, "   \002".uc($skey[1])."\002".$dv.$commands{$key}{shelp});
				}
			}
		}
		serv_notice("dnsbl", $user, "\002\002");
    		serv_notice("dnsbl", $user, "\002***** End of Help *****\002");
	}
}
