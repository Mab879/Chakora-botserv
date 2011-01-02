# operserv/defcon by Franklin IRC Services. BOTNET attack respose.
#
# Copyright (c) 2010 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

#Start The module
	module_init("operserv/defcon", "Franklin IRC Services", "0.1", \&inti_os_colordefcon, \&void_os_colordefcon);
#Add the command
sub inti_os_colordefcon {
	cmd_add("operserv/bluealret", "Sets the DEFCON TO 1", "Sets the DEFCON to 1", \&svs_os_bluealert);
	cmd_add("operserv/redalert", "Sets the DEFCON to 2","Sets the DEFCON to 2.", \&svs_os_redalert);
	cmd_add("yellowallert", "Sets the DEFCON to 3.", "Sets the DEFCON to 3.", \&svs_os_yellowalert);
	cmd_add("operserv/purplealert", "Sets the DEFCON to 4", "Sets the DEFCON to 4", \&svs_os_purplealert);
	cmd_add("operserv/standdown", "Sets the DEFCON to 5", "Returns the network to normal.", \&svs_os_standdown);
	}
sub void_os_colordefon {
	sub_delete "init_os_colordefcon";
	sub_delete "svs_os_bluealert"
}