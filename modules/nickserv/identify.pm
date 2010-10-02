# nickserv/identify by The Chakora Project. Allows users to identify to their account.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("nickserv/identify", "The Chakora Project", "0.1", \&init_ns_identify, \&void_ns_identify, "all");

sub init_ns_identify {
        if (!module_exists("nickserv/main")) {
                module_load("nickserv/main");
        }
	cmd_add("nickserv/identify", "Identifies to services for a nickname.", "IDENTIFY identifies you to services so that you can\nreceive channel status and perform general maintenance\nand commands that require you to be logged in.\n[T]\nSyntax: IDENTIFY <password>\n[T]\nYou can also identify for another nick/account than\nyou are currently using.\n[T]\nSyntax: IDENTIFY <nick> <password>", \&svs_ns_identify);
}

sub void_ns_identify {
	delete_sub 'init_ns_identify';
	delete_sub 'svs_ns_identify';
	cmd_del("nickserv/identify");
	delete_sub 'void_ns_identify';
}

sub svs_ns_identify {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1])) {
		serv_notice("nickserv", $user, "Not enough parameters. Syntax: IDENTIFY [nick] <password>");
		return;
	} 
	# they wish to identify to another nick, lets fulfill that
	if (defined $sargv[2]) {
		if (!defined($Chakora::DB_nick{lc($sargv[1])}{account})) {
			serv_notice("nickserv", $user, "Nickname \002$sargv[1]\002 is not registered.");
			return;
		}
		my $pass = hash($sargv[2]);
		my $account = $Chakora::DB_nick{lc($sargv[1])}{account};
		if ($pass ne $Chakora::DB_account{lc($account)}{pass}) {
			serv_notice("nickserv", $user, "Incorrect password.");
			svsilog("nickserv", $user, "IDENTIFY:FAIL:BADPASS", $account);
			svsflog('commands', uidInfo($user, 1).": NickServ: IDENTIFY:FAIL:BADPASS: $account");
			return;
		}
		if (lc(uidInfo($user, 9)) eq lc($account)) {
			serv_notice("nickserv", $user, "You're already identified as \002$account\002.");
			return;
		}
		unless (!is_identified($user)) {
			serv_notice("nickserv", $user, "Automatically logging you out of account \002".uidInfo($user, 9)."\002.");
			svsilog("nickserv", $user, "LOGOUT", uidInfo($user, 9));
			svsflog('commands', uidInfo($user, 1).": NickServ: LOGOUT: ".uidInfo($user, 9));
		}
		serv_accountname($user, $account);
		$Chakora::uid{$user}{'account'} = $account;
		serv_notice("nickserv", $user, "You are now identified as \002$account\002.");
		event_identify($user, uidInfo($user, 9));
		svsilog("nickserv", $user, "IDENTIFY", $account);
		svsflog('commands', uidInfo($user, 1).": NickServ: IDENTIFY: $account");
		my $host = uidInfo($user, 2)."@".uidInfo($user, 4);
		$Chakora::DB_account{lc($account)}{lasthost} = $host;
		metadata_add(1, $account, "data:realhost", uidInfo($user,1)."!".uidInfo($user,2)."@".uidInfo($user,3)." ".uidInfo($user,5));
	} 
	# they wish to identify to their current nick, lets fulfill that
	else {
		if (!defined($Chakora::DB_nick{lc(uidInfo($user, 1))}{account})) {
			serv_notice("nickserv", $user, "This nickname is not registered.");
			return;
		}
		my $pass = hash($sargv[1]);
		my $account = $Chakora::DB_nick{lc(uidInfo($user, 1))}{account};
		if ($pass ne $Chakora::DB_account{lc($account)}{pass}) {
			serv_notice("nickserv", $user, "Incorrect password.");
			svsilog("nickserv", $user, "IDENTIFY:FAIL:BADPASS", $account);
			svsflog('commands', uidInfo($user, 1).": NickServ: IDENTIFY:FAIL:BADPASS: $account");
			return;
		}
		if (lc(uidInfo($user, 9)) eq lc($account)) {
			serv_notice("nickserv", $user, "You're already identified as \002$account\002.");
			return;
		}
		unless (!is_identified($user)) {
			serv_notice("nickserv", $user, "Automatically logging you out of account \002".uidInfo($user, 9)."\002.");
			svsilog("nickserv", $user, "LOGOUT", uidInfo($user, 9));
			svsflog('commands', uidInfo($user, 1).": NickServ: LOGOUT: ".uidInfo($user, 9));
		}
		serv_accountname($user, $account);
		$Chakora::uid{$user}{'account'} = $account;
		serv_notice("nickserv", $user, "You are now identified as \002$account\002.");
		event_identify($user, uidInfo($user, 9));
		svsilog("nickserv", $user, "IDENTIFY", $account);
		svsflog('commands', uidInfo($user, 1).": NickServ: IDENTIFY: $account");
		my $host = uidInfo($user, 2)."@".uidInfo($user, 4);
		$Chakora::DB_account{lc($account)}{lasthost} = $host;
                metadata_add(1, $account, "data:realhost", uidInfo($user,1)."!".uidInfo($user,2)."@".uidInfo($user,3)." ".uidInfo($user,5));
	}	
}
