# operserv/modunload by The Chakora Project. Adds MODUNLOAD to OperServ, which unloads a services module.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/modunload", "The Chakora Project", "0.1", \&init_os_modunload, \&void_os_modunload, "all");

sub init_os_modunload {
	cmd_add("operserv/modunload", "Unloads a module", "Unloads a module from Chakora.", \&svs_os_modunload);
}

sub void_os_modunload {
	delete_sub 'init_os_modunload';
	delete_sub 'svs_os_modunload';
	cmd_del("operserv/modunload");
	delete_sub 'void_os_modunload';
}

sub svs_os_modunload {
	my ($user, @sargv) = @_;
	if (has_spower($user, 'operserv:mod_')) {
		if ($sargv[1]) {
			serv_notice("operserv", $user, "Attempting to unload ".$sargv[1]);
			if (!module_exists($sargv[1])) { serv_notice("operserv", $user, "Module not loaded"); }
			elsif (module_void($sargv[1]) eq "MODUNLOAD_SUCCESS") {
				serv_notice("operserv", $user, "Module unloaded");
				svsilog("operserv", $user, "modunload", $sargv[1]); 
				my @us = split('/', $sargv[1]);
				if (lc($us[1]) eq 'main') {
					foreach my $ml (keys %Chakora::MODULE) {
						my @ms = split('/', $ml);
						if (lc($ms[0]) eq lc($us[0])) {
							logchan('operserv', "\002!!!\002 Unloading module \002$ml\002");
							module_void($ml);
						}
					}
				}
			}
			else { serv_notice("operserv", $user, "Module unloading failed"); }
		}
		else {
			serv_notice("operserv", $user, "Not enough parameters. Syntax: MODUNLOAD <module>");
		}
	}
	else {
		serv_notice("operserv", $user, "Access denied.");
	}
}
1;
