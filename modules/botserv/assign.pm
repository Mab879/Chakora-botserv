# botserv/assign by Franklin IRC Services. Assigns a bot a channel.
#
# Copyright (c) 2010 Franklin IRC Services. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
# Based on the original code of Chakora by The Techno Devs
use strict;
use warnings;

module_init("botserv/assign", "Franklin  IRC Services", "0.1", \&init_bs_assign, \&void_bs_assign);

