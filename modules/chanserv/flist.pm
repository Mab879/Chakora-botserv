# chanserv/flist by The Chakora Project. Adds a flag list to ChanServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/flist", "The Chakora Project", "0.1", \&init_cs_flist, \&void_cs_flist, "all");

sub init_cs_flist {
	cmd_add("chanserv/flist", "Lists available channel flags.", "NO_HELP_ENTRY", \&svs_cs_flist);
}

sub void_cs_flist {
	delete_sub 'init_cs_flist';
	delete_sub 'svs_cs_flist';
	cmd_del("chanserv/flist");
	delete_sub 'void_cs_flist';
}

sub svs_cs_flist {
	my ($user, @sargv) = @_;
	my %flags = %Chakora::FLAGS;
	serv_notice("chanserv", $user, "\002*** Flag list ***\002");
	foreach my $key (sort keys %flags) {
		serv_notice("chanserv", $user, "\002".$Chakora::FLAGS{$key}{name}."\002 - ".$Chakora::FLAGS{$key}{description});
	}
	serv_notice("chanserv", $user, "\002*** End flag list ***\002");
}
