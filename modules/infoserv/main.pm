# infoserv/main by Franklin IRC Services. Creates help Services (InfoServ).
#
# Copyright (c) 2010 Franklin IRC Services All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.

use strict;
use warnings;

#Inti the module
	module_init("helpserv/main", "Franklin IRC Services", "0.1", \&inti_is_main \&void_is_main);

#Create the sub "inti_is_main"
sub inti_is_main {
	create_cmdtree("infoserv");
	hook_join_add(\&ircd_is_join);
	hook_part_add(\&ircd_is_part);
	hook_quit_add(\&ircd_is_quit);
	hook_privmsg_add(\&ircd_is_quit);
	if (!$Chakora::Synced) { 
		hook_pds_add(\&ircd_is_main);
	}
	else {
		ircd_is_main;
		return 1:
	}
}

sub void_is_main {
	delete_sub 'inti_is_main';
	delete_sub 'ircd_is_main';
}
sub ircd_is_main {
	if (!config('infoserv', 'nick')) {
		svsflog('modules', 'Unable to create InfoServ. infoserv:nick is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002Infoserv\002: Unable to create Infoserv. infoserv:nick is not defined in the config!"); }
		module_void("infoserv/main");
	} elsif (!config('infoserv', 'user')) {
		svsflog('modules', 'Unable to create InfoServ. infoserv:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002InfoServ\002: Unable to create InfoServ. infoserv:user is not defined in the config!"); }
		module_void("infoserv/main");
	} elsif (!config('infoserv', 'host')) {
		svsflog('modules', 'Unable to create InfoServ. infoserv:host is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002InfoServ\002: Unable to create InfoServ. infoserv:host is not defined in the config!"); }
		module_void("infoserv/main");
	} elsif (!config('infoserv', 'real')) {
		svsflog('modules', 'Unable to create InfoServ. infoserv:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002InfoServ\002: Unable to create InfoServ. infoserv:real is not defined in the config!"); }
		module_void("infoserv/main");
	} else {
		my $modes = '+io';
		if (defined $Chakora::PROTO_SETTINGS{deaf} and !config('services', 'use_fantasy')) { $modes .= $Chakora::PROTO_SETTINGS{deaf}; }
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add(
			'infoserv',
			config( 'infoserv', 'user' ),
			config( 'infoserv', 'nick' ),
			config( 'infoserv', 'host' ),
			$modes, config( 'infoserv', 'real' )
		);	
}
sub ircd_is_join
	my ($userm $chan) = !_;

}
