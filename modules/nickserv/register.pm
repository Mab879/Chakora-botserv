# nickserv/register by The Chakora Project. Allows users to register their nickname with services.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("nickserv/register", "The Chakora Project", "0.1", \&init_ns_register, \&void_ns_register, "all");

sub init_ns_register {
	cmd_add("nickserv/register", "Register a nickname with services.", "This will allow you to register your current nickname with ".config('nickserv', 'nick').".\nBy doing this you are creating an identity for yourself on the network,\nand allowing yourself to be added to access lists. ".config('nickserv', 'nick')." will also\nwarn users when using your nick, make them go unidentified if they don't\nidentify, and allow you to kill ghosts. The password is a case sensitive\npassword that you make up. Please write it down or memorize it! You will\nneed it to identify or change settings later on.\n[T]\nSyntax: REGISTER <password> <email-address>", \&svs_ns_register);
	hook_uid_add(\&ns_enforce_on_uid);
	hook_nick_add(\&ns_enforce_on_nick);
}

sub void_ns_register {
	hook_uid_del(\&ns_enforce_on_uid);
	hook_nick_add(\&ns_enforce_on_nick);
	delete_sub 'init_ns_register';
	delete_sub 'svs_ns_register';
	delete_sub 'ns_enforce_os_uid';
	delete_sub 'ns_enforce_on_nick';
	cmd_del("nickserv/register");
}

sub svs_ns_register {
	my ($user, @sargv) = @_;
	my (@semail);
	my $nick = uidInfo($user, 1);
	my $password = $sargv[1];
	my $email = $sargv[2];
	my $regtime = time();
	my $host = uidInfo($user, 2)."@".uidInfo($user, 4);
	my $en = Digest::HMAC->new(config('enc', 'key'), "Digest::Whirlpool");
	unless (!defined($email) or !defined($password)) {
		unless (defined $Chakora::DB_nick{lc($nick)}{account}) {
			unless (length($password) < 5) {
				@semail = split('@', $email);
				unless (!Email::Valid->address($email)) {
					$en->add($password);
					my $pass = $en->hexdigest;
					$Chakora::DB_account{lc($nick)}{name} = $nick;
					$Chakora::DB_account{lc($nick)}{pass} = $pass;
					$Chakora::DB_account{lc($nick)}{email} = $email;
					$Chakora::DB_account{lc($nick)}{regtime} = time();
					$Chakora::DB_account{lc($nick)}{lasthost} = $host;
					$Chakora::DB_account{lc($nick)}{lastseen} = time();
					$Chakora::DB_nick{lc($nick)}{nick} = $nick;
					$Chakora::DB_nick{lc($nick)}{account} = $nick;
					metadata_add(1, $nick, "flag:enforce", 1);
					metadata_add(1, $nick, "flag:hidemail", 1);
					serv_accountname($user, $nick);
					$Chakora::uid{$user}{'account'} = $nick;
					svsilog("nickserv", $user, "REGISTER", "\002".$nick."\002 to \002".$email."\002");
					serv_notice("nickserv", $user, "\2".$nick."\2 is now registered to \2".$email."\2 with the password \2".$password."\2");
					serv_notice("nickserv", $user, "Thank you for registering with ".config('network', 'name')."!");
				} else { serv_notice("nickserv", $user, 'Invalid email address.'); }
			} else { serv_notice("nickserv", $user, 'Your password must be at least 5 characters long.'); }
		} else { serv_notice("nickserv", $user, 'This nickname is already registered.'); }
	} else { serv_notice("nickserv", $user, 'Not enough parameters. Syntax: REGISTER <password> <email address>'); }
}

sub ns_enforce_on_uid {
	my ($uid, $nick, $user, $host, $mask, $ip, $server) = @_;
	
	if (defined $Chakora::DB_nick{lc($nick)}{account}) {
		my $account = $Chakora::DB_nick{lc($nick)}{account};
		if (!metadata(1, $account, "flag:enforce")) {
			return;
		}
		serv_notice("nickserv", $uid, "This nickname is registered and protected.  Please");
		serv_notice("nickserv", $uid, "identify with /msg ".$Chakora::svsnick{'nickserv'}." IDENTIFY <password>");
		serv_notice("nickserv", $uid, "within ".config('nickserv', 'enforce_delay')." seconds or I will change your nick.");
		timer_add("ns_id_".$uid, time()+config('nickserv', 'enforce_delay'), "ns_enforce($uid, $account)");
	}
}

sub ns_enforce_on_nick {
	my ($uid, $nick) = @_;
	
	if (defined $Chakora::DB_nick{lc($nick)}{account}) {
		my $account = $Chakora::DB_nick{lc($nick)}{account};
		if (!metadata(1, $account, "flag:enforce")) {
			return;
		}
		serv_notice("nickserv", $uid, "This nickname is registered and protected.  Please");
		serv_notice("nickserv", $uid, "identify with /msg ".$Chakora::svsnick{'nickserv'}." IDENTIFY <password>");
		serv_notice("nickserv", $uid, "within ".config('nickserv', 'enforce_delay')." seconds or I will change your nick.");
		timer_add("ns_id_".$uid, time()+config('nickserv', 'enforce_delay'), "ns_enforce($uid, $account)");
	}
}

sub ns_enforce {
	my ($user, $account) = @_;
	if (!uidInfo($user, 9) or uidInfo($user, 9) ne $account) {
		serv_notice("nickserv", $user, "You failed to identify in time.");
		serv_enforce($user, "Guest-".int(rand(99999)));
	}
}
