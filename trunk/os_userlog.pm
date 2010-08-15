# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
module_init("operserv/userlog", "The Chakora Project", "0.1", \&init_os_userlog, \&void_os_userlog, "all");

sub init_os_userlog {
	hook_join_add(\&svs_os_joinlog);
	hook_part_add(\&svs_os_partlog);
}

sub void_os_userlog {
	delete_sub 'init_os_userlog';
	delete_sub 'svs_os_joinlog';
	delete_sub 'svs_os_partlog;
	hook_join_del(\&svs_os_joinlog);	
	hook_part_del(\&svs_os_partlog);
}

sub svs_os_joinlog {
        my ($user, $chan) = @_;
        serv_privmsg("os", config('log', 'logchan'), "JOIN: ".uidInfo($user, 1)." -> ".$chan);
}

sub svs_os_partlog {
	my ($user, $chan) = @_;
	serv_privmsg("os", config('log', 'logchan'), "PART: ".uidInfo($user, 1)." -> ".$chan);
}
