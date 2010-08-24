# operserv/modload by The Chakora Project. Adds MODLOAD to OperServ, which loads a services module.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/modload", "The Chakora Project", "0.1", \&init_os_modload, \&void_os_modload, "all");

sub init_os_modload {
	cmd_add("operserv/modload", "Unloads a module", "Unloads a module from Chakora.", \&svs_os_modload);
}

sub void_os_modload {
	delete_sub 'init_os_modload';
	delete_sub 'svs_os_modload';
	cmd_del("operserv/modload");
}

sub svs_os_modload {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	if (is_soper($user)) {
		if ($rex[4]) {
			serv_notice("os", $user, "Attempting to load ".$rex[4]);
			if (module_exists($rex[4])) { serv_notice("os", $user, "Module already loaded"); }
			elsif (module_load($rex[4])) {
				serv_notice("os", $user, "Module loaded");
				svsilog("os", $user, "modload", $rex[4]); 
			}
			else { serv_notice("os", $user, "Module loading failed"); }
		}
		else {
			serv_notice("os", $user, "Not enough parameters. Syntax: MODLOAD <module>");
		}
	}
	else {
		serv_notice("os", $user, "Access denied.");
	}
}
1;
