# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/userlog", "The Chakora Project", "0.1", \&init_os_userlog, \&void_os_userlog, "all");

# Set this to 0 and verify it has a block in the config to make userlog use its own service
my $use_operserv = 1;
my $service;

sub init_os_userlog {

	if (!$use_operserv) {
		if (!config('logserv', 'user')) {
			print("A block for logserv doesn't appear to be in your config, please create one. Using OperServ instead...\n");
			$use_operserv = 1;
			$service = 'operserv';
		}
		else {
                	my $modes = '+io';
                	if (lc(config('server', 'ircd')) eq 'inspircd') {
                        	if ($Chakora::INSPIRCD_SERVICE_PROTECT_MOD) {
                                	$modes .= 'k';
                        	}
                		} elsif (lc(config('server', 'ircd')) eq 'charybdis') {
                        		$modes .= 'S';
 			}
			serv_add('logserv', config('logserv', 'user'), config('logserv', 'nick'), config('logserv', 'host'), $modes, config('logserv', 'real'));
			create_cmdtree('logserv');
			$service = 'logserv';
		}
	}	
	else {
		$service = 'operserv';
	}

	hook_join_add(\&svs_os_joinlog);
	hook_part_add(\&svs_os_partlog);
	hook_nick_add(\&svs_os_nicklog);
	hook_uid_add(\&svs_os_connectlog);
	hook_quit_add(\&svs_os_quitlog);
	hook_oper_add(\&svs_os_operlog);
	hook_deoper_add(\&svs_os_deoperlog);
	hook_away_add(\&svs_os_awaylog);
	hook_back_add(\&svs_os_backlog);
	hook_sid_add(\&svs_os_sidlog);
	hook_netsplit_add(\&svs_os_netsplit);
	hook_eos_add(\&svs_os_eoslog);
	hook_kill_add(\&svs_os_killlog);
}

sub void_os_userlog {
	delete_sub 'init_os_userlog';
	delete_sub 'svs_os_joinlog';
	delete_sub 'svs_os_partlog';
	delete_sub 'svs_os_nicklog';
	delete_sub 'svs_os_connectlog';
	delete_sub 'svs_os_quitlog';
	delete_sub 'svs_os_operlog';
	delete_sub 'svs_os_deoperlog';
	delete_sub 'svs_os_awaylog';
	delete_sub 'svs_os_backlog';
	delete_sub 'svs_os_sidlog';
	delete_sub 'svs_os_netsplit';
	delete_sub 'svs_os_eoslog';
	delete_sub 'svs_os_killlog';
	hook_join_del(\&svs_os_joinlog);	
	hook_part_del(\&svs_os_partlog);
	hook_nick_del(\&svs_os_nicklog);
	hook_uid_del(\&svs_os_connectlog);
	hook_quit_del(\&svs_os_quitlog);
	hook_oper_del(\&svs_os_operlog);
	hook_deoper_del(\&svs_os_deoperlog);
	hook_away_del(\&svs_os_awaylog);
	hook_back_del(\&svs_os_backlog);
	hook_sid_del(\&svs_os_sidlog);
	hook_netsplit_del(\&svs_os_netsplit);
	hook_eos_del(\&svs_os_eoslog);
	hook_kill_del(\&svs_os_killlog);
	delete_cmdtree('logserv');
	serv_del("logserv");
}

sub svs_os_joinlog {
        my ($user, $chan) = @_;
	if ($Chakora::synced) {
	        serv_privmsg($service, config('log', 'logchan'), "\2JOIN\2: ".uidInfo($user, 1)." -> ".$chan);
	}
}

sub svs_os_partlog {
	my ($user, $chan) = @_;
	serv_privmsg($service, config('log', 'logchan'), "\2PART\2: ".uidInfo($user, 1)." -> ".$chan);
}

sub svs_os_nicklog {
	my ($user, $newnick) = @_;
	serv_privmsg($service, config('log', 'logchan'), "\2NICK\2: ".uidInfo($user, 6)." -> ".$newnick);
}

sub svs_os_connectlog {
	my ($uid, $nick, $user, $host, $mask, $ip, $server) = @_;
	if ($Chakora::synced) {
		serv_privmsg($service, config('log', 'logchan'), "\2CONNECT on ".sidInfo($server, 1)."\2: ".$nick."!".$user."@".$host." (Mask: ".$mask." IP: ".$ip.")");
	}
}

sub svs_os_quitlog {
	my ($user, $msg) = @_;
	serv_privmsg($service, config('log', 'logchan'), "\2QUIT\2: ".uidInfo($user, 1)." on ".sidInfo(uidInfo($user, 8), 1)." Reason: ".$msg);
}

sub svs_os_operlog {
	my ($user) = @_;
	if ($Chakora::synced) {
		serv_privmsg($service, config('log', 'logchan'), "\2OPER\2: ".uidInfo($user, 1)." on ".sidInfo(uidInfo($user, 8), 1));
	}
}

sub svs_os_deoperlog {
        my ($user) = @_;
	if ($Chakora::synced) {
        	serv_privmsg($service, config('log', 'logchan'), "\2DEOPER\2: ".uidInfo($user, 1)." on ".sidInfo(uidInfo($user, 8), 1));
	}
}

sub svs_os_awaylog {
	my ($user, $reason) = @_;
	if ($Chakora::synced) {
		serv_privmsg($service, config('log', 'logchan'), "\2AWAY\2: ".uidInfo($user, 1)." - ".$reason);
	}
}

sub svs_os_backlog {
	my ($user) = @_;
	serv_privmsg($service, config('log', 'logchan'), "\2BACK\2: ".uidInfo($user, 1));
}

sub svs_os_sidlog {
	my ($server, $info) = @_;
	if ($Chakora::synced) {
		serv_privmsg($service, config('log', 'logchan'), "\2Server Introduction\2: ".$server." (Server Information - ".$info.")");
	}
}

sub svs_os_netsplit {
	my ($server, $reason, $source) = @_;
	serv_privmsg($service, config('log', 'logchan'), "\2Netsplit\2: ".sidInfo($server, 1)." split from ".sidInfo($source, 1)." (Reason - ".$reason.")");
}

sub svs_os_eoslog {
	serv_privmsg($service, config('log', 'logchan'), "\2End of sync\2: ".config('me', 'name')." -> ".config('server', 'host')." syncing complete");
}

sub svs_os_killlog {
	my ($user, $target, $reason) = @_;
	serv_privmsg($service, config('log', 'logchan'), "\2Kill\2: ".uidInfo($user, 1)." killed ".uidInfo($target, 1)." ".$reason);
}
