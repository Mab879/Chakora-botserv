# nickserv/ghost by The Chakora Project. Allows ghosting of users (and dead sessions AKA ghosts) using another's nickname.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("nickserv/ghost", "The Chakora Project", "1.0", \&init_ns_ghost, \&void_ns_ghost, "all");

sub init_ns_ghost {
        if (!module_exists("nickserv/main")) {
                module_load("nickserv/main");
        }
		
	cmd_add("nickserv/ghost", "Ghost a user/ghost using your nickname.", "GHOST will allow you to kill users (and dead sessions)\nusing your nickname, if you are identified to the\naccount, no password is required.\n[T]\nSyntax: GHOST <nickname> [password]", \&svs_ns_ghost);
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
	my $tu = nickUID($sargv[1]);
	if (!$tu) {
		serv_notice("nickserv", $user, "User \002$sargv[1]\002 is not online.");
		return;
	}
	if ($tu eq $user) {
		serv_notice("nickserv", $user, "You may not ghost yourself!");
		return;
	}

	if (lc(uidInfo($user, 9)) eq lc(uidInfo($tu, 9))) {
		my $nick = uidInfo($tu, 1);
		serv_kill("nickserv", $tu, "Killed (NickServ (GHOST command from: ".uidInfo($user, 1)."!".uidInfo($user, 2)."@".uidInfo($user, 4)."))");
		serv_notice("nickserv", $user, "\002$nick\002 has been ghosted.");
		svsilog("nickserv", $user, "GHOST", $nick);
		svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): NickServ: GHOST: $nick");
	}
	else {
		if (!defined($sargv[2])) {
			serv_notice("nickserv", $user, "Not enough parameters. Syntax: GHOST <nickname> [password]");
			return;
		}
	
		my $account = uidInfo($tu, 9);
		my $nick = uidInfo($tu, 1);
		if (!defined $Chakora::DB_account{lc($account)}) {
			if (!defined $Chakora::DB_nick{lc($nick)}{account}) {
				serv_notice("nickserv", $user, "User \002$sargv[1]\002 is not registered.");
				return;
			}
			else {
				$account = $Chakora::DB_nick{lc($nick)}{account};
			}
		}
		my $pass = hash($sargv[2]);
		if ($pass ne $Chakora::DB_account{lc($account)}{pass}) {
			serv_notice("nickserv", $user, "Incorrect password.");
			svsilog("nickserv", $user, "GHOST:FAIL:BADPASS", $nick);
			svsflog('commands', uidInfo($user, 1).": NickServ: GHOST:FAIL:BADPASS: $nick");
			return;
		}
	
		serv_kill("nickserv", $tu, "Killed (NickServ (GHOST command from: ".uidInfo($user, 1)."!".uidInfo($user, 2)."@".uidInfo($user, 4)."))");
		serv_notice("nickserv", $user, "\002$nick\002 has been ghosted.");
		svsilog("nickserv", $user, "GHOST", $nick);
		svsflog('commands', uidInfo($user, 1).": NickServ: GHOST: $nick");	
	}
}
