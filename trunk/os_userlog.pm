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
	hook_nick_add(\&svs_os_nicklog);
	hook_uid_add(\&svs_os_connectlog);
	hook_quit_add(\&svs_os_quitlog);
	hook_oper_add(\&svs_os_operlog);
	hook_deoper_add(\&svs_os_deoperlog);
}

sub void_os_userlog {
	delete_sub 'init_os_userlog';
	delete_sub 'svs_os_joinlog';
	delete_sub 'svs_os_partlog';
	delete_sub 'svs_os_nicklog';
	delete_sub 'svs_os_connectlog';
	delete_sub 'svs_os_quitlog';
	hook_join_del(\&svs_os_joinlog);	
	hook_part_del(\&svs_os_partlog);
	hook_nick_del(\&svs_os_nicklog);
	hook_uid_del(\&svs_os_connectlog);
	hook_quit_del(\&svs_os_quitlog);
	hook_oper_del(\&svs_os_operlog);
	hook_deoper_del(\&svs_os_deoperlog);
}

sub svs_os_joinlog {
        my ($user, $chan) = @_;
	if ($Chakora::synced) {
	        serv_privmsg("os", config('log', 'logchan'), "\2JOIN\2: ".uidInfo($user, 1)." -> ".$chan);
	}
}

sub svs_os_partlog {
	my ($user, $chan) = @_;
	serv_privmsg("os", config('log', 'logchan'), "\2PART\2: ".uidInfo($user, 1)." -> ".$chan);
}

sub svs_os_nicklog {
	my ($user, $newnick) = @_;
	serv_privmsg("os", config('log', 'logchan'), "\2NICK\2: ".uidInfo($user, 6)." -> ".$newnick);
}

sub svs_os_connectlog {
	my ($uid, $nick, $user, $host, $mask, $ip) = @_;
	if ($Chakora::synced) {
		serv_privmsg("os", config('log', 'logchan'), "\2CONNECT\2: ".$nick."!".$user."@".$host." (Mask: ".$mask." IP: ".$ip.")");
	}
}

sub svs_os_quitlog {
	my ($user, $msg) = @_;
	serv_privmsg("os", config('log', 'logchan'), "\2QUIT\2: ".uidInfo($user, 1)." Reason: ".$msg);
}

sub svs_os_operlog {
	my ($user) = @_;
	serv_privmsg("os", config('log', 'logchan'), "\2OPER\2: ".uidInfo($user, 1));
}

sub svs_os_deoperlog {
        my ($user) = @_;
        serv_privmsg("os", config('log', 'logchan'), "\2DEOPER\2: ".uidInfo($user, 1));
}

