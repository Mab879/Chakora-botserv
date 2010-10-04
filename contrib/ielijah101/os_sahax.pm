# operserv/sahax by Elijah Perrault. Allows opers to forcibly join the target into the given amount of channels, all at once.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/sahax", "Elijah Perrault", "1.0", \&init_os_sahax, \&void_os_sahax, "inspircd12");

sub init_os_sahax {
	taint("Modules: operserv/sahax: Abusive module.");
	cmd_add("operserv/sahax", "Forcibly join someone into a given amount of channels.", "SAHAX allows opers to forcibly join the target\ninto the given amount of channels, each\nprefixed with the given prefix, all at once.\n[T]\nSyntax: SAHAX <user> <amount-of-channels> <channelname-prefix>", \&svs_os_sahax);
}

sub void_os_sahax {
	delete_sub 'init_os_sahax';
	delete_sub 'svs_os_sahax';
	cmd_del("operserv/sahax");
	delete_sub 'void_os_sahax';
}

sub svs_os_sahax {
	my ($user, @sargv) = @_;
	
	if (!has_spower($user, 'operserv:sahax')) {
		serv_notice("operserv", $user, "Permission denied.");
		return;
	}
	if (!defined($sargv[1]) or !defined($sargv[2]) or !defined($sargv[3])) {
		serv_notice("operserv", $user, "Not enough parameters. Syntax: SAHAX <user> <amount-of-channels> <channelname-prefix>");
		return;
	}
	
	my $i = 1;
	while ($i < $sargv[2] || $i == $sargv[2]) {
		serv_("operserv", "SVSJOIN ".nickUID($sargv[1])." #".$sargv[3].$i);
		$i += 1;
	}
	serv_notice("operserv", nickUID($sargv[1]), "\002Haha! You got pwnt by ".uidInfo($user, 1)."\002");
	serv_notice("operserv", $user, "Your evil request has been successfully fulfilled.");
	svsilog("operserv", $user, "SAHAX", "$sargv[1] to $sargv[2] channels");
}
