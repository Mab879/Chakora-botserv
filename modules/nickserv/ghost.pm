# nickserv/ghost by The Chakora Project. View information for a registered nick/account.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("nickserv/ghost", "The Chakora Project", "0.1", \&init_ns_ghost, \&void_ns_ghost, "all");

sub init_ns_ghost {
        if (!module_exists("nickserv/main")) {
                module_load("nickserv/main");
        }
		
	cmd_add("nickserv/ghost", "Ghost an old user session or somebody attempting to use your nickname without authorization.", "If you are logged in to the nick's account, you do not\nneed to specify a password\notherwise it is required\n[T]\nSyntax: GHOST <nickname> [password]", \&svs_ns_ghost);
}

sub void_ns_ghost {
	delete_sub 'init_ns_ghost';
	delete_sub 'svs_ns_ghost';
	cmd_del("nickserv/ghost");
	delete_sub 'void_ns_ghost';
}

sub svs_ns_ghost {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1])) {
		serv_notice("nickserv", $user, "Not enough parameters. Syntax: GHOST [nickname] <password>");
		return;
	}
	
	if (!defined($sargv[2])) {
		serv_notice("nickserv", $user, "Not enough parameters. Syntax: GHOST [nickname] <password>");
		return;
	}
	if (!is_registered(1, $sargv[1])) {
		serv_notice("nickserv", $user, "Nickname \002$sargv[1]\002 is not registered.");
		return;
	}
	
	my $pass = hash($sargv[2]);
	my $account = $Chakora::DB_nick{lc($sargv[1])}{account};
	my $nick = $Chakora::DB_nick{lc($sargv[1])}{nick};
	if ($pass ne $Chakora::DB_account{lc($account)}{pass}) {
		serv_notice("nickserv", $user, "Incorrect password.");
		svsilog("nickserv", $user, "GHOST:FAIL:BADPASS", $nick);
		svsflog('commands', uidInfo($user, 1).": NickServ: GHOST:FAIL:BADPASS: $nick");
		return;
	}
	
	my ($dele);
	svsilog("nickserv", $user, "GHOST", $nick);
	svsflog('commands', uidInfo($user, 1).": NickServ: GHOST: $nick");
	$dele .= 'serv_kill(\'nickserv\', \''.$nick.'\', \'Killed (NickServ (GHOST command used by '.uidInfo($user, 1).'!'.uidInfo($user, 2).'@'.uidInfo($user, 4).'))\'); ';
	$dele .= '1; ';
	eval($dele) or svsilog("nickserv", $user, "GHOST:FAIL", $@) and svsflog('commands', uidInfo($user, 1)." NickServ: GHOST:FAIL: ".$@) and serv_notice("nickserv", $user, "An error occurred. No user was ghosted. Please report this to an IRCop immediately.") 
	
}
