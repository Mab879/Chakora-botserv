# chanserv/lol by Matthew Barksdale. Adds LOL to ChanServ, an example module.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/rmswar", "Alyx", "0.1", \&init_cs_rmswar, \&void_cs_rmswar, "all");

sub init_cs_lol {
	serv_privmsg("chanserv", config('log', 'logchan'), "OH GOD MATT'S SISTER, YOU'RE SO BIG!"); # Messages the logchan, "LOL MODULE ON"
	cmd_add("chanserv/rmswar", "Rape fun.", "Rapes MattB's sister with a rake", \&svs_cs_rmswar); # Adds the command
}

sub void_cs_lol {
	# Unload cleanup
	delete_sub 'init_cs_rmswar';
	delete_sub 'svs_cs_rmswar';
	cmd_del("chanserv/rmswar"); # Deletes the command
	delete_sub 'void_cs_rmswar'; 
}

sub svs_cs_lol {
	my ($user, @args) = @_;
	serv_notice("chanserv", $user, "\001ACTION rapes MattB's sister with a rake\001"); # Notices the user, "LOL <nickname>"
	svsilog("chanserv", $user, "RMSWAR", ""); # Logs it to logchan
}

1;
