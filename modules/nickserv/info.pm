# nickserv/info by The Chakora Project. View information for a registered nick/account.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("nickserv/info", "The Chakora Project", "0.1", \&init_ns_info, \&void_ns_info, "all");

sub init_ns_info {
	cmd_add("nickserv/info", "Display information about a nickname.", "INFO will display account information such as\nregistration date and time, settings, last host\nand seen time, and other details.\n[T]\nSyntax: INFO <nickname>", \&svs_ns_info);
}

sub void_ns_info {
	delete_sub 'init_ns_info';
	delete_sub 'svs_ns_info';
	cmd_del("nickserv/info");
}

sub svs_ns_info {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1])) {
		serv_notice("nickserv", $user, "Not enough parameters. Syntax: INFO <nickname>");
		return;
	}
	if (!defined($Chakora::DB_nick{lc($sargv[1])}{account})) {
		serv_notice("nickserv", $user, "Nickname \002$sargv[1]\002 is not registered.");
		return;
	}
	my $account = $Chakora::DB_nick{lc($sargv[1])}{account};
	serv_notice("nickserv", $user, "Information on \002".$Chakora::DB_nick{lc($sargv[1])}{nick}."\002 (account \002".$Chakora::DB_nick{lc($sargv[1])}{account}."\002):");
	serv_notice("nickserv", $user, "Registered : ".scalar(localtime($Chakora::DB_account{lc($account)}{regtime})));
	serv_notice("nickserv", $user, "Last addr  : ".$Chakora::DB_account{lc($account)}{lasthost});
	serv_notice("nickserv", $user, "Last seen  : ".scalar(localtime($Chakora::DB_account{lc($account)}{lastseen})));
	if (metadata(1, $account, "private:hidemail")) {
		if (uidInfo($user, 7)) {
			serv_notice("nickserv", $user, "Email      : ".$Chakora::DB_account{lc($account)}{email}." (hidden)");
		}
	}
	else {
		serv_notice("nickserv", $user, "Email      : ".$Chakora::DB_account{lc($account)}{email});
	}
	my ($flags);
	foreach my $key (keys %Chakora::DB_accdata) {
		if (lc($Chakora::DB_accdata{$key}{account}) eq lc($account)) {
			my @flag = split('private:', $Chakora::DB_accdata{$key}{name});
			$flags .= ' '.uc($flag[1]);
		}
	}
	unless (!defined($flags)) {
		serv_notice("nickserv", $user, "Flags      :".$flags);
	}
	serv_notice("nickserv", $user, "\002*** End of Info ***\002");
}