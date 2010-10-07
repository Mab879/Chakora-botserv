# DNSBL/help by The Chakora Project. Adds help functions to DNSBL.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("dnsbl/help", "The Chakora Project", "0.1", \&init_dns_help, \&void_dns_help, "all");

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
    serv_notice("dnsbl", $user, "\002***** DNSBL Help *****\002");
    serv_notice("dnsbl", $user, "This DNSBL Module checks user's IP addresses against a long");
    serv_notice("dnsbl", $user, "and comprehensive list of databases to check if the ip is");
    serv_notice("dnsbl", $user, "blacklisted. If the IP is blacklisted, the user is killed");
    serv_notice("dnsbl", $user, "from the network explaining what list their ip is in and");
    serv_notice("dnsbl", $user, "the reason number that goes with it.");
    serv_notice("dnsbl", $user, "\002***** End of Help *****\002");
}
