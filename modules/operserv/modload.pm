# operserv/modload by The Chakora Project. Adds MODLOAD to OperServ, which loads a services module.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/modload", "The Chakora Project", "0.1", \&init_os_modload, \&void_os_modload, "all");

sub init_os_modload {
	cmd_add("operserv/modload", "Loads a module", "Loads a module from Chakora.", \&svs_os_modload);
}

sub void_os_modload {
	delete_sub 'init_os_modload';
	delete_sub 'svs_os_modload';
	cmd_del("operserv/modload");
}

sub svs_os_modload {
	my ($user, @sargv) = @_;
	if (is_soper($user)) {
		if ($sargv[1]) {
			serv_notice("operserv", $user, "Attempting to load ".$sargv[1]);
			if (module_exists($sargv[1])) { serv_notice("operserv", $user, "Module already loaded."); }
			elsif (module_load($sargv[1])) {
				serv_notice("operserv", $user, "Module loaded.");
				svsilog("operserv", $user, "modload", $sargv[1]); 
			}
			else { serv_notice("operserv", $user, "Module loading failed."); }
		}
		else {
			serv_notice("operserv", $user, "Not enough parameters. Syntax: MODLOAD <module>");
		}
	}
	else {
		serv_notice("operserv", $user, "Access denied.");
	}
}
1;