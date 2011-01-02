# botserv/add by Franklin IRC Services. Adds a bot to the database.
#
# Copyright (c) 2010 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
# Based on the original code of Chakora by The Techno Devs
use strict;
use warnings;

module_init("botserv/add", "Franklin  IRC Services", "0.1", \&init_bs_add, \&void_bs_add);

sub init_bs_add {
        if (!module_exists("botserv/main")) {
                module_load("botserv/main");
        }
        cmd_add("botserv/add", "Create a botserv bot.", "ADD allows an IRC Operator to add an botserv bot the bot list.", \&svs_bs_add);
}

sub void_bs_add {
        delete_sub 'init_bs_add';
        delete_sub 'svs_bs_add';
	delete_sub 'bs_add';
        cmd_del("botserv/add");
        delete_sub 'void_bs_add';
}
sub svs_bs_add {
        my ($user, @sargv) = @_;
	 if (has_spower($user, 'botserv:add')) {

			if (!defined($sargv[1])) {
				serv_notice("botserv", $user, "Not enough parameters. Syntax: ADD [nickname] [name] [host] [real name]");
				return;
			}
			if (!defined($sargv[2])) {
				serv_notice("botserv", $user, "Not enough parameters. Syntax: ADD [nickname] [name] [host] [real name]");
				return;
			}
			if (!defined($sargv[3])) {
			serv_notice("botserv", $user, "Not enough parameters. Syntax: ADD [nickname] [name] [host] [real name]");
				return;
			}
			if (!uidInfo($user, 9)) {
				serv_notice("botserv", $user, "You must be logged in to perform this operation.");
				return;
			}     
			if (defined $Chakora::DB_account{lc($sargv[1])}{name}) {
				serv_notice("botserv", $user, "User \002$sargv[1]\002 is registered! Choose a differnt nick for the bot.");
				return;
<<<<<<< HEAD

=======
>>>>>>> 443bc037eba9b10b64ab34adfa6cefa3352770e8
			}
			my $tu = nickUID($sargv[1]);
			if ($tu) {
			serv_notice("botserv", $user, "User \002$sargv[1]\002 is online! Please choose a differnt nickname for the bot or close the connect.");
		return;
			}
<<<<<<< HEAD

			} 
		if (defined $Chakora::DB_bot{lc($sargv[1]){nickname}) {
	  serv_notice("botserv" , $user "This bot exits.");
	  return;
=======
			} 
	  if (defined $Chakora::DB_bots{lc($sargv[1]){nickname}) {
	    serv_notice("botserv" , $user "This bot exits.");
	    return;
>>>>>>> 443bc037eba9b10b64ab34adfa6cefa3352770e8
	}
			if (defined($sargv[2]) and defined($sargv[3] and defined($sargv)[4])) {
				if (has_spower($user, 'botserv:assign')) {
				  
					
				serv_notice("botserv", $user Bot $sargv[1] was added with the host of $sargv[2] @ $sargv[3] with the real name $sargv[4] .;

	} 
	else {
		serv_notice("botserv", $user, "You do not have permission to add bots.");
		}
}
