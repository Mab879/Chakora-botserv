# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
module_init("operserv/joinlog", "The Chakora Project", "0.1", \&init_os_joinlog, \&void_os_joinlog, "all");

sub init_os_joinlog {
	hook_join_add(\&svs_os_joinlog);
}

sub void_os_joinlog {
	delete_sub 'init_os_joinlog';
	delete_sub 'svs_os_joinlog';
	hook_join_del(\&svs_os_joinlog);	
}

sub svs_os_joinlog {
	my ($user, $chan) = @_;
	serv_privmsg("os", "#services", "JOIN: ".$user." -> ".$chan);
}
