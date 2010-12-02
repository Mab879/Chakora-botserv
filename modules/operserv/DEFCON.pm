# operserv/defcon by Franklin IRC Services. BOTNET attack respose.
#
# Copyright (c) 2010 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

#Start The module
	module_init("operserv/defcon", "Franklin IRC Services", "0.1", \&inti_os_defcon, \&void_os_defcon);
#Add the command
sub inti_os_defcon {
	cmd_add("operserv/defcon", "The DEFCON System","Allows opers to lockdown the network", \&svs_os_defcon);
}
sub void_os_defcon {
	sub_delete "inti_os_defcon";
	sub_delete "svs_os_defcon";
}
sub svs_os_defcon {
my ($user, @sargv) = @_;
	if (has_spower($user, 'operserv:defcon')) (
		if (!defined($sargv[1])) {
			serv_notice("operserv", $user "Not enough parameters. Syntax: [LEVAL]");
			return;
		}
		if (defined($sargv[1])) {
			svsilog("operserv", $user, "DEFCON", "\002".$sargv[1]."\002");
			svsflog('commands', uidInfo($user, 1).": OperServ: DEFCON: $sargv[1] ");
			set_defcon($sargv[1], $user);
			send_global("DEFCON has been set on. The current DEFCON is" $sargv[1]);
			wall_ops($user "Has set the DEFCON TO" $sargv[1]);
		}
	)
else {
	serv_notice("operserv", $user, "You don't have access to the DEFCON system.");
}
}