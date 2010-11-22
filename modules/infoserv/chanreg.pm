# infoserv/chanreg by Franklin IRC Services. Tells how to register a channel.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
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
	delete_sub 'svs_is_chandrop';
	delete_sub 'void_is_chanreg';
}
sub svs_is_chanref {
	my ($user, @sargv) = @_;
	serv_notice("infoserv", $user, "To register a channel first have to have a registred nickname. If don't if have one plese type:/n /msg infoserv nickcheck $user");
}

1;
  

	
