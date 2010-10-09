# chanserv/count by Elijah Perrault. Adds COUNT to ChanServ, for making ChanServ count to a given number.
# This module serves as an example module, you can find further documentation for the API via the man binary in bin/.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

# Call to initialize the module.
module_init("chanserv/count", "Elijah Perrault", "1.0", \&init_cs_count, \&void_cs_count, "all");

# Subroutine that initializes the module.
sub init_cs_count {
	if (!module_exists("chanserv/main")) {
		# chanserv/main is missing, this is required. Abort.
		svsflog('modules', "chanserv/count: Unable to load. Missing dependencies: chanserv/main"); # Log to modules.log.
		if ($Chakora::synced) { logchan('operserv', "chanserv/count: Unable to load. Missing dependencies: chanserv/main"); } # Log to the logchan if we're linked.
		return 0; # Abort the initialization.
	}
	# Create the command COUNT.
	cmd_add("chanserv/count", "ChanServ counting fun!", "COUNT will make ChanServ count from one to the given number,\n this module is meant as an example module.\n[T]\nSyntax: COUNT <number>", \&svs_cs_count);
	# Make this command operate with fantasy.
	fantasy("count", 0);
}

# Subroutine that voids the module.
sub void_cs_count {
	# Delete the command COUNT.
	cmd_del("chanserv/count");
	# Delete the subroutines introduced in this module.
	delete_sub 'init_cs_count';
	delete_sub 'svs_cs_count';
	delete_sub 'void_cs_count';
}

# Subroutine that is called by services when COUNT is used.
sub svs_cs_count {
	# Set $user to their UID and @sargv to the arguments given.
	my ($user, @sargv) = @_;
	
	# If argument 1 is greater than 25, bail.
	if ($sargv[1] > 25) {
		# Notice them the issue.
		serv_notice("chanserv", $user, "\002$sargv[1]\002 is too high. Please choose a number below or equal to 25.");
		# Bail.
		return;
	}
	
	### All is well, continue. ###
	
	# Set $i to 1.
	my $i = 1;
	# Create a while loop that continues until argument 1 is met.
	while ($i < $sargv[1] || $i == $sargv[1]) {
		# Notice them the current value of $i.
		serv_notice("chanserv", $user, $i);
		# Increase $i by one.
		$i++;
	}
	
	# All done.
	serv_notice("chanserv", $user, "Done.");
}
