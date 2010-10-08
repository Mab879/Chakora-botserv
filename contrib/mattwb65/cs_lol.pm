# chanserv/lol by Matthew Barksdale. Adds LOL to ChanServ, an example module.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/lol", "Matthew Barksdale", "0.1", \&init_cs_lol, \&void_cs_lol, "all");

sub init_cs_lol {
	taint("LOL MODULE"); # Taints chakora
	serv_privmsg("chanserv", config('log', 'logchan'), "LOL MODULE ON"); # Messages the logchan, "LOL MODULE ON"
	cmd_add("chanserv/lol", "Short help", "Long help.", \&svs_cs_lol); # Adds the command
}

sub void_cs_lol {
	# Unload cleanup
	delete_sub 'init_cs_lol';
	delete_sub 'svs_cs_lol';
	cmd_del("chanserv/lol"); # Deletes the command
	delete_sub 'void_cs_lol'; 
}

sub svs_cs_lol {
	my ($user, @args) = @_;
	serv_notice("chanserv", $user, "LOL ".uidInfo($user, 1)); # Notices the user, "LOL <nickname>"
	svsilog("chanserv", $user, "LOL", ""); # Logs it to logchan
}

1;
