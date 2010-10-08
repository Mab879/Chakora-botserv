# global/main by The Chakora Project. Creates global services (Global).
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("global/main", "The Chakora Project", "0.3", \&init_g_main, \&void_g_main, "all");

sub init_g_main {
	create_cmdtree("global");
	hook_kill_add(\&ircd_g_kill);
	hook_kick_add(\&ircd_g_kick);
	if (!$Chakora::synced) { hook_pds_add(\&ircd_g_main); }
	else { ircd_g_main(); return 1; }
}

sub void_g_main {
	delete_sub 'init_g_main';
	delete_sub 'ircd_g_main';
	delete_sub 'ircd_g_kill';
	delete_sub 'ircd_g_kick';
	hook_pds_del(\&svs_g_main);
	serv_del('Global');
	hook_kill_del(\&ircd_g_kill);
	hook_kick_del(\&ircd_g_kick);
	delete_cmdtree("global");
	delete_sub 'void_g_main';
}

sub ircd_g_main {
	if (!config('global', 'nick')) {
		svsflog('modules', 'Unable to create Global. global:nick is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002Global\002: Unable to create Global. global:nick is not defined in the config!"); }
		module_void("global/main");
	} elsif (!config('global', 'user')) {
		svsflog('modules', 'Unable to create Global. global:user is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002Global\002: Unable to create Global. global:user is not defined in the config!"); }
		module_void("global/main");
	} elsif (!config('global', 'host')) {
		svsflog('modules', 'Unable to create Global. global:host is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002Global\002: Unable to create Global. global:host is not defined in the config!"); }
		module_void("global/main");
	} elsif (!config('global', 'real')) {
		svsflog('modules', 'Unable to create Global. global:real is not defined in the config!');
		if ($Chakora::synced) { logchan('operserv', "\002Global\002: Unable to create Global. global:real is not defined in the config!"); }
		module_void("global/main");
	} else {
		my $modes = '+io';
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add(
			'global',
			config( 'global', 'user' ),
			config( 'global', 'nick' ),
			config( 'global', 'host' ),
			$modes, config( 'global', 'real' )
		);
	}	
}

sub ircd_g_kill {
	my ($user, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'global'}) {
		serv_del("Global");
		ircd_g_main();
	}
}

sub ircd_g_kick {
	my ($user, $chan, $target, $reason) = @_;
	
	if ($target eq $Chakora::svsuid{'global'}) {
		if (lc($chan) ne config('log', 'logchan') and !defined($Chakora::DB_chan{lc($chan)}{name})) {
			return;
		}	
		serv_join("Global", $chan);
		serv_kick("Global", $chan, $user, "Please do not kick services.");
	}
}

1;
