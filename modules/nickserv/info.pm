# nickserv/info by The Chakora Project. View information for a registered nick/account.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("nickserv/info", "The Chakora Project", "0.1", \&init_ns_info, \&void_ns_info);

sub init_ns_info {
        if (!module_exists("nickserv/main")) {
                module_load("nickserv/main");
        }
	cmd_add("nickserv/info", "Display information about a nickname.", "INFO will display account information such as\nregistration date and time, settings, last host\nand seen time, and other details.\n[T]\nSyntax: INFO <nickname>", \&svs_ns_info);
}

sub void_ns_info {
	delete_sub 'init_ns_info';
	delete_sub 'svs_ns_info';
	cmd_del("nickserv/info");
	delete_sub 'void_ns_info';
}

sub svs_ns_info {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1])) {
		serv_notice("nickserv", $user, "Not enough parameters. Syntax: INFO <nickname>");
		return;
	}
	if (!is_registered(1, $sargv[1])) {
		serv_notice("nickserv", $user, "Nickname \002$sargv[1]\002 is not registered.");
		return;
	}
	my $account = $Chakora::DB_nick{lc($sargv[1])}{account};
	serv_notice("nickserv", $user, "Information on \002".$Chakora::DB_nick{lc($sargv[1])}{nick}."\002 (account \002".$Chakora::DB_nick{lc($sargv[1])}{account}."\002):");
	serv_notice("nickserv", $user, "Registered: ".scalar(localtime($Chakora::DB_account{lc($account)}{regtime})));
	serv_notice("nickserv", $user, "Last addr: ".$Chakora::DB_account{lc($account)}{lasthost});
	if (metadata(1, $account, "data:realhost")) {
		if (has_spower($user, 'nickserv:fullinfo') or lc(uidInfo($user, 9)) eq lc($account)) {
			serv_notice("nickserv", $user, "Last real host: ".metadata(1, $account, "data:realhost"));
		}
	}
	serv_notice("nickserv", $user, "Last seen: ".scalar(localtime($Chakora::DB_account{lc($account)}{lastseen})));
	if (metadata(1, $account, "flag:hidemail")) {
		if (has_spower($user, 'nickserv:fullinfo') or lc(uidInfo($user, 9)) eq lc($account)) {
			serv_notice("nickserv", $user, "Email: ".$Chakora::DB_account{lc($account)}{email}." (hidden)");
		}
	}
	else {
		serv_notice("nickserv", $user, "Email: ".$Chakora::DB_account{lc($account)}{email});
	}

	my ($flags);
	foreach my $key (keys %Chakora::DB_accdata) {
		if (lc($Chakora::DB_accdata{$key}{account}) eq lc($account)) {
			my @flag = split('flag:', $Chakora::DB_accdata{$key}{name});
			$flags .= ' '.uc($flag[1]);
		}
	}
	unless (!defined($flags)) {
		serv_notice("nickserv", $user, "Flags:".$flags);
	}

        if (is_soper(nickUID($sargv[1]))) {
                serv_notice("nickserv", $user, $Chakora::DB_nick{lc($sargv[1])}{nick}." is a Services Operator.");
        }

	serv_notice("nickserv", $user, "\002*** End of Info ***\002");
}
