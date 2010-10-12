# operserv/modlist by The Chakora Project. Adds MODLIST to OperServ, which returns a list of modules loaded.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/modlist", "The Chakora Project", "0.1", \&init_os_modlist, \&void_os_modlist);

sub init_os_modlist {
	cmd_add("operserv/modlist", "Displays a list of modules loaded.", "This returns a list of all the modules currently loaded.", \&svs_os_modlist);
}

sub void_os_modlist {
	delete_sub 'init_os_modlist';
	delete_sub 'svs_os_modlist';
	cmd_del("operserv/modlist");
	delete_sub 'void_os_modlist';
}

sub svs_os_modlist {
	my ($user, @sargv) = @_;
	if (has_spower($user, 'operserv:mod_')) {
		my %MODULE = %Chakora::MODULE;
		my $count;
		serv_notice("operserv", $user, "\002*** Module List ***\002");
		foreach my $key (sort keys %MODULE) {
			$count++;
                	serv_notice("operserv", $user, $count.": ".$MODULE{$key}{name}." v".$MODULE{$key}{version}." by ".$MODULE{$key}{author});
        	} 
		serv_notice("operserv", $user, "\002*** End Module List ***\002");
		svsilog("operserv", $user, "modlist", "");
	}
	else {
		serv_notice("operserv", $user, "Access denied.");
	}
}

1;
