# botserv/assign by Franklin IRC Services. Assigns a bot to a channel.
#
# Copyright (c) 2010 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
# Based on the original code of Chakora by The Techno Devs
use strict;
use warnings;

module_init("botserv/assign", "Franklin  IRC Services", "0.1", \&init_bs_assign, \&void_bs_assign);

sub init_bs_assign {
        if (!module_exists("botserv/main")) {
                module_load("botserv/main");
        }
        cmd_add("botserv/asssign", "Assign a BotServ bot.", "ASSGIN allows you to assign a botserv bot to a channel.", \&svs_bs_assign);
}

sub void_bs_assign {
        delete_sub 'init_bs_flags';
        delete_sub 'svs_bs_assign';
	delete_sub 'bs_assign';
        cmd_del("botserv/assign");
        delete_sub 'void_bs_flags';
}
sub svs_cs_flags {
        my ($user, @sargv) = @_;

        if (!defined($sargv[1])) {
                serv_notice("botserv", $user, "Not enough parameters. Syntax: ASSIGN <#channel> [bot]");
                return;
        }
        if (!uidInfo($user, 9)) {
                serv_notice("botserv", $user, "You must be logged in to perform this operation.");
                return;
        }
        if (substr($sargv[1], 0, 1) ne '#') {
                serv_notice("botserv", $user, "Invalid channel name.");
                return;
        }
        if (!defined $Chakora::DB_chan{lc($sargv[1])}{name}) {
                serv_notice("botserv", $user, "Channel \002$sargv[1]\002 is not registered.");
                return;
        }
	if (defined($sargv[2]) and defined($sargv[3])) {
		if (has_flag(uidInfo($user, 9), $sargv[1], "m")) {
			bs_assign($user, $sargv[1], $sargv[2);
		serv_notice("botserv", $user Bot $sargv[2] was assigned to 

	} 
	else {
		serv_notice("botserv", $user, "You do not have permission to assign bots in ".$sargv[1]);
		}
