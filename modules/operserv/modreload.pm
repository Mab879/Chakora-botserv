# operserv/modreload by The Chakora Project. Adds MODRELOAD to OperServ, which reloads a services module.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/modreload", "The Chakora Project", "0.1", \&init_os_modreload, \&void_os_modreload, "all");

sub init_os_modreload {
	cmd_add("operserv/modreload", "Reloads a module.", "UNLOAD will unload the given services module (if it\nexists), then load it again from disk and initialize it.\n[T]\nSyntax: MODRELOAD <module>", \&svs_os_modreload);
}

sub void_os_modreload {
	delete_sub 'init_os_modreload';
	delete_sub 'svs_os_modreload';
	cmd_del("operserv/modreload");
	delete_sub 'void_os_modreload';
}

sub svs_os_modreload {
	my ($user, @sargv) = @_;
	
	if (!has_spower($user, 'operserv:mod_')) {
		serv_notice("operserv", $user, "Permission denied.");
		return;
	}
	if (!defined $sargv[1]) {
		serv_notice("operserv", $user, "Not enough parameters. Syntax: MODRELOAD <module>");
		return;
	}
	my $module = lc($sargv[1]);
	if (!module_exists($module)) {
		serv_notice("operserv", $user, "No such module '\002$module\002' loaded.");
		return;
	}
	if (!-e "$Chakora::ROOT_SRC/../modules/$module.pm") {
		serv_notice("operserv", $user, "File '\002modules/$module.pm\002' not found.");
		return;
	}

	my $mu = module_void($module);
	if ($mu eq 'MODUNLOAD_FAIL') {
		serv_notice("operserv", $user, "Module \002$module\002 failed to unload.");
		return;
	}
	my $ml = module_load($module);
	if (!$ml) {
		serv_notice("operserv", $user, "Module \002$module\002 failed to load.");
		return;
	}
	else {
		serv_notice("operserv", $user, "Module \002$module\002 reloaded.");
		svsilog("operserv", $user, "MODRELOAD", $module);
		svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): OperServ: MODRELOAD: $module");
	}
}

1;
