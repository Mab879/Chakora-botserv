
# nickserv/register by The Chakora Project. Allows users to register their nickname with services.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("nickserv/register", "The Chakora Project", "0.1", \&init_ns_register, \&void_ns_register, "all");

sub init_ns_register {
	cmd_add("nickserv/register", "Register a nickname with services.", "This will allow you to register your current nickname with ".config('nickserv', 'nick').".\nBy doing this you are creating an identity for yourself on the network,\nand allowing yourself to be added to access lists. ".config('nickserv', 'nick')." will also\nwarn users when using your nick, make them go unidentified if they don't\nidentify, and allow you to kill ghosts. The password is a case sensitive\npassword that you make up. Please write it down or memorize it! You will\nneed it to identify or change settings later on.\n[T]\nSyntax: REGISTER <password> <email-address>", \&svs_ns_register);
}

sub void_ns_register {
	delete_sub 'init_ns_register';
	delete_sub 'svs_ns_register';
	cmd_del("nickserv/register");
}

sub svs_ns_register {
	my ($raw) = @_;
	my (@semail);
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	my $nick = uidInfo($user, 1);
	my $password = $rex[4];
	my $email = $rex[5];
	my $en = Digest::HMAC->new(config('encryption', 'key'), "Digest::Whirlpool");
	unless (!defined($email) or !defined($password)) {
		unless (length($password) < 5) {
			@semail = split('@', $email);
			unless ($semail[0] =~ m/![A-Z|a-z|0-9]/) {
				
			} else { serv_notice("ns", $user, 'Invalid email address.'); }
			$en->add($password);
			my $pass = $en->hexdigest;
			svsilog("ns", $user, "REGISTER", "\002".$nick."\002 to \002".$email."\002");
			serv_notice("ns", $user, "\2".$nick."\2 is now registered to \2".$email."\2 with the password \2".$password."\2");
			serv_notice("ns", $user, "Thanks for register with ".config('network', 'name'));
		} else { serv_notice("ns", $user, 'Your password must be at least 5 characters long.'); }
	} else { serv_notice("ns", $user, 'Not enough parameters. Syntax: REGISTER <password> <email-address>'); }
}
