# infoserv/chanreg by Franklin IRC Services. Tells how to register a channel.
use strict;
use warnings;

#Start The module
	module_init("infoserv/chanreg", "Franklin IRC Services", "0.1", \&inti_is_chanreg \&void_is_chanreg);
#Add the command
sub inti_is_chanreg {
	cmd_add("infoserv/chanreg", "Shows how to register a channel.", \&svs_is_chanreg);
	cmd_add("infoserv/chandrop", "Shows how to drop a channel", \&svs_is_chandrop);
}

sub void_is_chanreg {
	delete_sub 'inti_is_chanreg';
	delete_sub 'svs_is_chanreg';
	delete_sub 'svs_is)chandrop';
}

	
