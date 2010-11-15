# chanserv/xop by The Chakora Project. Adds XOP support to ChanServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/xop", "The Chakora Project", "0.1", \&init_cs_xop, \&void_cs_xop);

sub init_cs_xop {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	# Add cmds based on prefixes available: qop, sop, aop, hop, vop
	# Add fantasy for them too
}

sub void_cs_xop {
	delete_sub 'init_cs_xop';
	# Delete commands and subs based on prefixes
	delete_sub 'void_cs_xop';
}

