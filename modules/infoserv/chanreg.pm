# infoserv/chanreg by Franklin IRC Services. Tells how to register and drop a channel.
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
	serv_notice("infoserv", $user, "To register a channel first have to have a registred nickname. If don't if have one plese type:/n /msg infoserv nickcheck $user /n After you have a regiserd nick. Join the channel you want to register./n /002Please Note:/002 That the channnel you want may be already registered./n Then do /msg chanserv REGISTER <#channel> <description.");
}
sub svs_chandrop {
  serv_notice("infoserv", $user, "To drop a channel you must be the channels founder./n If you want to drop your channel do/n /msg chanserv drop <#channel> /n /002Please note:/002 Once you drop your channel. someone else can register the channel.")
1;
  

	
