# chanserv/drop by Franklin IRC Services. Allows you to drop a channel drop from services.
#
# Copyright (c) 2011 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

# Start the modul
module_init("chanserv/register", "The Chakora Project", "0.1", \&init_cs_drop, \&void_cs_drop);

sub init_cs_drop {
	sub init_cs_drop {
		if (!module_exists("chanserv/main")) {
			module_load("chanserv/main");
		}
		cmd_add("chanserv/drop", "deregisters and deprotects a channel with services.", "REGISTER allows you to register a channel so\nthat you have better control over it. It\nwill also allow you to keep access lists, settings,\ntopics and keep the channel in sync and protected.\n[T]\nSyntax: REGISTER <#channel>", \&svs_cs_drop);
	}

}
