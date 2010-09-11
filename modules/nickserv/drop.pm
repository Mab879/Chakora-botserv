# nickserv/drop by The Chakora Project. Allows users to drop their account.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("nickserv/drop", "The Chakora Project", "0.1", \&init_ns_drop, \&void_ns_drop, "all");

sub init_ns_drop {
	cmd_add("nickserv/drop", "Drops your account from services database.", "DROP will allow you to drop your Nickserv Account\nonce you have deleted your account, it may not be restored.\nThis action is not reversable.\n[T]\nSyntax: DROP [nick] <password>\n", \&svs_ns_drop);
}

sub void_ns_drop {
	delete_sub 'init_ns_drop';
	delete_sub 'svs_ns_drop';
	cmd_del("nickserv/drop");
	delete_sub 'void_ns_drop';
}

sub svs_ns_drop {
	my ($user, @sargv) = @_;
	
	if (!defined(uidInfo($user,9))) {	# User is not logged in.
		if (!defined($sargv[1])) {
			serv_notice("nickserv", $user, "You must state a nick. Syntax: DROP [nick] <password>");
			return;
		} 
	
		if (!defined($sargv[2])) {
			serv_notice("nickserv", $user, "You must state a password. Syntax: DROP [nick] <password>");
			return;		
		}
	
		if (!defined($Chakora::DB_nick{lc($sargv[1])}{account})) {
			serv_notice("nickserv", $user, "Nickname \002$sargv[1]\002 is not registered.");
			return;
		}
	
		my $en = Digest::HMAC->new(config('enc', 'key'), "Digest::Whirlpool");
		$en->add($sargv[2]);
		my $pass = $en->hexdigest;
		$pass = '$whirl$'.$pass;
		my $account = $Chakora::DB_nick{lc($sargv[1])}{account};
		if ($pass ne $Chakora::DB_account{lc($account)}{pass}) {
			serv_notice("nickserv", $user, "Incorrect password.");
			svsilog("nickserv", $user, "DROP:FAIL:BADPASS", $account);
			svsflog('commands', uidInfo($user, 1).": NickServ: DROP:FAIL:BADPASS: $account");
			return;
		}
		
		my $account_name = $sargv[1];
		
		delete $Chakora::DB_account{lc($account_name)}
		serv_notice("nickserv", $user, "You have successfully dropped the account $account_name.");
		
	} else {	# User is logged in.
		if (defined($sargv[2])) {
			serv_notice("nickserv", $user, "Too many parameters when you are logged in. Syntax: DROP <password>");
		}
		if (!defined($sargv[1])) {
			serv_notice("nickserv", $user, "You must state a password. Syntax: DROP <password>");
			return;
		} 
		my $en = Digest::HMAC->new(config('enc', 'key'), "Digest::Whirlpool");
		$en->add($sargv[1]);
		my $pass = $en->hexdigest;
		$pass = '$whirl$'.$pass;
		my $account = $Chakora::DB_nick{lc($sargv[1])}{account};
		if ($pass ne $Chakora::DB_account{lc($account)}{pass}) {
			serv_notice("nickserv", $user, "Incorrect password.");
			svsilog("nickserv", $user, "DROP:FAIL:BADPASS", $account);
			svsflog('commands', uidInfo($user, 1).": NickServ: DROP:FAIL:BADPASS: $account");
			return;
		}
		event_logout($user, uidInfo($user,9));
		svsflog('commands', uidInfo($user, 1).": NickServ: DROP: as ".uidInfo($user, 9));
		
		my $account_name = uidInfo($user, 9);
		
		delete $Chakora::DB_nick{lc(uidInfo($user, 1))}
		delete $Chakora::DB_account{lc(uidInfo($user, 9))}
		undef $Chakora::uid{$user}{'account'};
		serv_logout($user);
		serv_notice("nickserv", $user, "You have successfully dropped the account $account_name.");
	}
}