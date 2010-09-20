# nickserv/set by The Chakora Project. Allows users to set account settings
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("nickserv/set", "The Chakora Project", "0.1", \&init_ns_set, \&void_ns_set, "all");

sub init_ns_set {
        cmd_add("nickserv/set", "Allows you to set account settings", "SET allows you to manage the way various\naspects of your account operate, such as \nflags and nickname enforcement.\n[T]\nSET options:\n[T]\n\002PASSWORD\002 - Changes your services password.\n\002EMAIL\002 - Changes your services email address.\n\002ENFORCE\002 - Sets nick enforcement on or off.\n\002HIDEMAIL\002 - Sets hiding your email address to users on or off.\n\002NOSTATUS\002 - Prevents you from recieving status in any channel regardless if you have flags or not.\n\002ACCOUNTNAME\002 - Sets your account name to a nick you own.\n[T]\nSyntax: SET <option> [parameters]", \&svs_ns_set);
}

sub void_ns_set {
        delete_sub 'init_ns_set';
        delete_sub 'svs_ns_set';
	delete_sub 'ns_set_password';
	delete_sub 'ns_set_enforce';
	delete_sub 'ns_set_hidemail';
	delete_sub 'ns_set_email';
	delete_sub 'ns_set_nostatus';
	delete_sub 'ns_set_accoutname';
        cmd_del("nickserv/set");
	delete_sub 'void_ns_set';
}

sub svs_ns_set {
        my ($user, @sargv) = @_;
	if (!uidInfo($user, 9)) {
		serv_notice("nickserv", $user, "You are not identified.");
	}
	elsif (!defined($sargv[1])) {
		serv_notice("nickserv", $user, "Not enough parameters. Syntax: SET <setting> [options]");
	}
	elsif (lc($sargv[1]) eq 'password') {
		if (!defined($sargv[2])) {
			serv_notice("nickserv", $user, "Not enough parameters. Syntax: SET PASSWORD <password>");
               	}
		elsif (length($sargv[2]) < 5) {
			serv_notice("nickserv", $user, "Your password must be at least 5 characters long.");
		}
		else {
			ns_set_password($user, uidInfo($user, 9), $sargv[2]);
		}
	}
        elsif (lc($sargv[1]) eq 'email') {
                if (!defined($sargv[2])) {
                        serv_notice("nickserv", $user, "Not enough parameters. Syntax: SET EMAIL <email-address>");
                }
                else {
                        ns_set_email($user, uidInfo($user, 9), $sargv[2]);
                }
        }
        elsif (lc($sargv[1]) eq 'accountname') {
                if (!defined($sargv[2])) {
                        serv_notice("nickserv", $user, "Not enough parameters. Syntax: SET ACCOUTNAME <grouped-nick>");
                }
                else {
                        ns_set_accountname($user, uidInfo($user, 9), $sargv[2]);
                }
        }
	elsif (lc($sargv[1]) eq 'enforce') {
        	if (!defined($sargv[2])) {
                	serv_notice("nickserv", $user, "Not enough parameters. Syntax: SET ENFORCE <on/off>");
                }
		elsif (lc($sargv[2]) eq 'on' or lc($sargv[2]) eq 'off') {
			ns_set_enforce($user, uidInfo($user, 9), lc($sargv[2]));
		}
		else {
                        serv_notice("nickserv", $user, "Invalid parameter. Syntax: SET ENFORCE <on/off>");
		}
	}
        elsif (lc($sargv[1]) eq 'nostatus') {
                if (!defined($sargv[2])) {
                        serv_notice("nickserv", $user, "Not enough parameters. Syntax: SET NOSTATUS <on/off>");
                }
                elsif (lc($sargv[2]) eq 'on' or lc($sargv[2]) eq 'off') {
                        ns_set_nostatus($user, uidInfo($user, 9), lc($sargv[2]));
                }
                else {
                        serv_notice("nickserv", $user, "Invalid parameter. Syntax: SET NOSTATUS <on/off>");
                }
        }
        elsif (lc($sargv[1]) eq 'hidemail') {
                if (!defined($sargv[2])) {
                        serv_notice("nickserv", $user, "Not enough parameters. Syntax: SET HIDEMAIL <on/off>");
                }
                elsif (lc($sargv[2]) eq 'on' or lc($sargv[2]) eq 'off') {
                        ns_set_hidemail($user, uidInfo($user, 9), lc($sargv[2]));
                }
                else {
                        serv_notice("nickserv", $user, "Invalid parameter. Syntax: SET HIDEMAIL <on/off>");
                }
        }

}

sub ns_set_password {
	my ($user, $account, $password) = @_;
        my $en = Digest::HMAC->new(config('enc', 'key'), "Digest::Whirlpool");
	$en->add($password);
	my $pass = $en->hexdigest;
	$Chakora::DB_account{lc($account)}{pass} = $pass;
	serv_notice("nickserv", $user, "Password for account \2".$account."\2 successfully changed to \2".$password."\2.");
	svsilog("nickserv", $user, "SET:PASSWORD", "");		
}

sub ns_set_email {
	my ($user, $account, $email) = @_;
	my @semail = split('@', $email);
	if (Email::Valid->address($email)) {
		$Chakora::DB_account{lc($account)}{email} = $email;
		serv_notice("nickserv", $user, "Email for account \2".$account."\2 successfully changed to \2".$email."\2.");
		svsilog("nickserv", $user, "SET:EMAIL", $email);
	}
	else {
		serv_notice("nickserv", $user, "The specified email address is invalid.");
	}
}
sub ns_set_accountname {
        my ($user, $account, $name) = @_;
        if (in_group($name, $account)) {
                $Chakora::DB_account{lc($account)}{name} = $name;
		$Chakora::DB_account{lc($name)} = delete $Chakora::DB_account{lc($account)};
		foreach my $key ( keys %Chakora::DB_nick ) {
			if (lc($Chakora::DB_nick{$key}{account}) eq lc($account)) {
				$Chakora::DB_nick{$key}{account} = $name;
			}
		}
		foreach my $key ( keys %Chakora::DB_accdata ) {
			if (lc($Chakora::DB_accdata{$key}{account}) eq lc($account)) {
				$Chakora::DB_accdata{$key}{account} = lc($name);
			}
		}
		$Chakora::uid{$user}{'account'} = $name;
		serv_accountname($user, $name);
                serv_notice("nickserv", $user, "Name for account \2".$account."\2 successfully changed to \2".$name."\2.");
                svsilog("nickserv", $user, "SET:ACCOUNTNAME", $account." -> ".$name);
        }
        else {
                serv_notice("nickserv", $user, "You do not own the specified nickname.");
        }
}

sub ns_set_enforce {
	my ($user, $account, $option) = @_;
	if ($option eq 'on') {
                if (!metadata(1, $account, "flag:enforce")) {
                	metadata_add(1, $account, "flag:enforce", 1);
			serv_notice("nickserv", $user, "\2ENFORCE\2 flag set.");
			svsilog("nickserv", $user, "SET:ENFORCE", "ON");
                }
		else {
			serv_notice("nickserv", $user, "The \2ENFORCE\2 flag is already set on your account.");
		}
	}
	elsif ($option eq 'off') {
                if (metadata(1, $account, "flag:enforce")) {
                        metadata_del(1, $account, "flag:enforce");
                        serv_notice("nickserv", $user, "\2ENFORCE\2 flag unset.");
                        svsilog("nickserv", $user, "SET:ENFORCE", "OFF");
                }
                else {
                        serv_notice("nickserv", $user, "The \2ENFORCE\2 flag is already unset on your account.");
                }
	}
}

sub ns_set_hidemail {
        my ($user, $account, $option) = @_;
        if ($option eq 'on') {
                if (!metadata(1, $account, "flag:hidemail")) {
                        metadata_add(1, $account, "flag:hidemail", 1);
                        serv_notice("nickserv", $user, "\2HIDEMAIL\2 flag set.");
                        svsilog("nickserv", $user, "SET:HIDEMAIL", "ON");
                }
                else {
                        serv_notice("nickserv", $user, "The \2HIDEMAIL\2 flag is already set on your account.");
                }
        }
        elsif ($option eq 'off') {
                if (metadata(1, $account, "flag:hidemail")) {
                        metadata_del(1, $account, "flag:hidemail");
                        serv_notice("nickserv", $user, "\2HIDEMAIL\2 flag unset.");
                        svsilog("nickserv", $user, "SET:HIDEMAIL", "OFF");
                }
                else {
                        serv_notice("nickserv", $user, "The \2HIDEMAIL\2 flag is already unset on your account.");
                }
        }
}

sub ns_set_nostatus {
        my ($user, $account, $option) = @_;
        if ($option eq 'on') {
                if (!metadata(1, $account, "flag:nostatus")) {
                        metadata_add(1, $account, "flag:nostatus", 1);
                        serv_notice("nickserv", $user, "\2NOSTATUS\2 flag set.");
                        svsilog("nickserv", $user, "SET:NOSTATUS", "ON");
                }
                else {
                        serv_notice("nickserv", $user, "The \2NOSTATUS\2 flag is already set on your account.");
                }
        }
        elsif ($option eq 'off') {
                if (metadata(1, $account, "flag:nostatus")) {
                        metadata_del(1, $account, "flag:nostatus");
                        serv_notice("nickserv", $user, "\2NOSTATUS\2 flag unset.");
                        svsilog("nickserv", $user, "SET:NOSTATUS", "OFF");
                }
                else {
                        serv_notice("nickserv", $user, "The \2NOSTATUS\2 flag is already unset on your account.");
                }
        }
}


1;
