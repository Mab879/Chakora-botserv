# /  __ \ |         | |                  
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#          Protocol Events Module
#	     Chakora::Protocol::Events
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

### JOIN ###
our (%hook_join);

# When users join a channel, execute all join hooks.
sub event_join {
	my ($user, $chan) = @_;
	my ($hook);
	foreach $hook (%hook_join) {
		eval
		{
			&{ $hook }($user, $chan);
		};
	}
}

# Add a hook to the join event.
sub hook_join_add {
	my ($handler) = @_;
	$hook_join{$handler} = $handler;
}

# Delete a hook from the join event.
sub hook_join_del {
	my ($handler) = @_;
	undef $hook_join{$handler};
}

1;
