# operserv/modunload by The Chakora Project. Adds MODUNLOAD to OperServ, which unloads a services module.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
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
}

sub svs_os_modunload {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	if (is_soper($user)) {
		if ($rex[4]) {
			serv_notice("os", $user, "Attempting to unload ".$rex[4]);
			if (!module_exists($rex[4])) { serv_notice("os", $user, "Module not loaded"); }
			elsif (module_void($rex[4]) eq "MODUNLOAD_SUCCESS") {
				serv_notice("os", $user, "Module unloaded");
				svsilog("os", $user, "modunload", $rex[4]); 
			}
			else { serv_notice("os", $user, "Module unloading failed"); }
		}
		else {
			serv_notice("os", $user, "Not enough parameters. Syntax: MODUNLOAD <module>");
		}
	}
	else {
		serv_notice("os", $user, "Access denied.");
	}
}
1;
