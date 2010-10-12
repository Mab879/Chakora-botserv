# operserv/raw by The Chakora Project. Adds RAW to OperServ, sends raw text to the services socket.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/raw", "The Chakora Project", "0.1", \&init_os_raw, \&void_os_raw);

sub init_os_raw {
	taint("Modules: operserv/eval: Destructive module. Not supported.");
	cmd_add("operserv/raw", "Sends raw data to the server.", "RAW will send raw data to the server bypassing absolutely\nALL of Chakora's handlers, possibly creating desync.  RAW\nis extremely dangerous, please use with caution!\n[T]\nSyntax: RAW <data>", \&svs_os_raw);
}

sub void_os_raw {
	delete_sub 'init_os_raw';
	delete_sub 'svs_os_raw';
	cmd_del("operserv/raw");
	delete_sub 'void_os_raw';
}

sub svs_os_raw {
	my ($user, @sargv) = @_;
	if (has_spower($user, 'operserv:raw')) {
		if ($sargv[1]) {
			my $i;
			my $args = $sargv[1];
			for ($i = 2; $i < count(@sargv); $i++) { $args .= ' '.$sargv[$i]; }
			svsilog("operserv", $user, "raw", $args);
			send_sock($args);
		}
		else {
			serv_notice("operserv", $user, "Not enough parameters. Syntax: RAW <data>");
		}
	}
	else {
		serv_notice("operserv", $user, "Permission denied.");
	}
}
1;
