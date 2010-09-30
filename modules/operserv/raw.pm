# operserv/raw by The Chakora Project. Adds RAW to OperServ, sends raw text to the services socket.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/raw", "The Chakora Project", "0.1", \&init_os_raw, \&void_os_raw, "all");

sub init_os_raw {
	cmd_add("operserv/raw", "Sends a raw message to the server", "Sends a raw message to the socket.", \&svs_os_raw);
	taint("operserv/raw is loaded - highly abusive");
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
			serv_notice("operserv", $user, "Not enough parameters. Syntax: RAW <message>");
		}
	}
	else {
		serv_notice("operserv", $user, "Permission denied.");
	}
}
1;
