# infoserv/chanreg by Franklin IRC Services. Tells how to register a channel.
use strict;
use warnings;

#Start The module
	module_init("infoserv/chanreg", "Franklin IRC Services", "0.1", \&inti_is_chanreg \&void_is_main);
#Add the command
	cmd_add("infoserv/chanreg", "Shows how to register a channel.", \&svs_is_chanreg);
