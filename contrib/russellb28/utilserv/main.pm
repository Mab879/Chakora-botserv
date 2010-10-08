# utilserv/main by Russell Bradford. Creates the UtilServ service.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("utilserv/main", "Russell Bradford", "0.1", \&init_us_main, \&void_us_main, "all");

sub init_us_main {
	hook_kill_add(\&ircd_us_kill);
	create_cmdtree("utilserv");
	if (!$Chakora::synced) { hook_pds_add(\&svs_us_main); return 1; }
	else { svs_us_main(); }
}

sub void_us_main {
	delete_sub 'init_us_main';
	delete_sub 'svs_us_main';
	hook_pds_del(\&svs_us_main);
	serv_del('UtilServ');
	delete_cmdtree("utilserv");
	hook_kill_del(\&ircd_us_kill);
	delete_sub 'ircd_us_kill';
	delete_sub 'void_us_main';
}

sub svs_us_main {
	if (!config('utilserv', 'nick')) {
		svsflog('modules', 'Unable to create UtilServ. utilserv:nick is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002UtilServ\002: Unable to create UtilServ. utilserv:nick is not defined in the config!"); }
		module_void("utilserv/main");
	} elsif (!config('utilserv', 'user')) {
		svsflog('modules', 'Unable to create UtilServ. utilserv:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002UtilServ\002: Unable to create UtilServ. utilserv:user is not defined in the config!"); }
		module_void("utilserv/main");
	} elsif (!config('utilserv', 'host')) {
		svsflog('modules', 'Unable to create UtilServ. utilserv:host is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002UtilServ\002: Unable to create UtilServ. utilserv:host is not defined in the config!"); }
		module_void("utilserv/main");
	} elsif (!config('utilserv', 'real')) {
		svsflog('modules', 'Unable to create UtilServ. utilserv:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002UtilServ\002: Unable to create UtilServ. utilserv:real is not defined in the config!"); }
		module_void("utilserv/main");
	} else {
		my $modes = '+io';
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add('utilserv', config('utilserv', 'user'), config('utilserv', 'nick'), config('utilserv', 'host'), $modes, config('utilserv', 'real'));
	}
}

sub ircd_us_kill {
	my ($user, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'utilserv'}) {
		serv_del("UtilServ");
		ircd_us_main();
	}
}
