# botserv/delete by Franklin IRC Services. Deletes a bot from the database.
#
# Copyright (c) 2010 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
# Based on the original code of Chakora by  TechnoDevs.
use strict;
use warnings;

module_init("botserv/delete", "Franklin  IRC Services", "0.1", \&init_bs_add, \&void_bs_add);

sub init_bs_assign {
        if (!module_exists("botserv/delete")) {
                module_load("botserv/delete");
        }
        cmd_add("botserv/delete", "Removes a botserv bot.", "DELETE allows an IRCop to remove a Botserv bot.", \&svs_bs_add);
}

sub void_bs_add {
        delete_sub 'init_bs_add';
        delete_sub 'svs_bs_add';
	delete_sub 'bs_add';
        cmd_del("botserv/delete");
        delete_sub 'void_bs_add';
}
sub svs_bs_add {
        my ($user, @sargv) = @_;
	# TODO: Check to if they botserv:add 
	 if (has_spower($user, 'botserv:add')) {

			if (!defined($sargv[1])) {
				serv_notice("botserv", $user, "Not enough parameters. Syntax: DELETE <nickname>");
				return;
			}
			}
			if (!uidInfo($user, 9)) {
				serv_notice("botserv", $user, "You must be logged in to perform this operation.");
				return;
			}     
			if (!defined $Chakora::DB_bot{lc($sargv[1])}{nickname}) {
				serv_notice("botserv", $user, "Bot \002$sargv[1]\002 doesn't exist!");
				return;
			}
			my $tu = nickUID($sargv[1]);
			if ($tu) {
		serv_notice("botserv", $user, "User \002$sargv[1]\002 is online! Please choose a differnt nickname for the bot or close the connect.");
		return;
			}
			} 
	if (defined $Chakora::DB_bots{lc($sargv[1]){nickname}) {
	  serv_notice("botserv" , $user "This bot exits.");
	  return;
	}
			if (defined($sargv[2]) and defined($sargv[3] and defined($sargv)[4])) {
				if (has_spower($user, 'botserv:assign')) {
				  
					
				serv_notice("botserv", $user Bot $sargv[1] was added with the host of $sargv[2] @ $sargv[3] with the real name $sargv[4] .;

	} 
	else {
		serv_notice("botserv", $user, "You do not have permission to add bots.");
		}
}
