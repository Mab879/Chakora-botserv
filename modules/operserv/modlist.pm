
# operserv/modlist by The Chakora Project. Adds MODLIST to OperServ, which returns a list of modules loaded.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/modlist", "The Chakora Project", "0.1", \&init_os_modlist, \&void_os_modlist, "all");

sub init_os_modlist {
	cmd_add("operserv/modlist", "Displays a list of modules loaded.", "This returns a list of all the modules currently loaded.", \&svs_os_modlist);
}

sub void_os_modlist {
	delete_sub 'init_os_modlist';
	delete_sub 'svs_os_modlist';
	cmd_del("operserv/modlist");
}

sub svs_os_modlist {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	if (is_soper($user)) {
		my %MODULE = %Chakora::MODULE;
		my $count;
		serv_notice("os", $user, "\002*** Module List ***\002");
		foreach my $key (sort keys %MODULE) {
			$count++;
                	serv_notice("os", $user, $count.": ".$MODULE{$key}{name}." v".$MODULE{$key}{version}." By ".$MODULE{$key}{author});
        	} 
		serv_notice("os", $user, "\002*** End Module List ***\002");
		svsilog("os", $user, "modlist", "");
	}
	else {
		serv_notice("os", $user, "Access denied.");
	}
}

1;
