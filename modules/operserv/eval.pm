# operserv/eval by Elijah Perrault. Adds EVAL to OperServ, which allows you to eval Perl code.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/eval", "Elijah Perrault", "1.0", \&init_os_eval, \&void_os_eval, "all");

sub init_os_eval {
	cmd_add("operserv/eval", "Eval Perl code.", "Eval Perl code.", \&svs_os_eval);
}

sub void_os_eval {
	delete_sub 'init_os_eval';
	delete_sub 'svs_os_eval';
	cmd_del("operserv/eval");
}

sub svs_os_eval {
	my ($user, @sargv) = @_;
	if (!is_soper($user)) {
		serv_notice("operserv", $user, "Access denied.");
		return;
	}
	if (!defined($sargv[1])) {
		serv_notice("operserv", $user, "Not enough parameters. Syntax: EVAL <code>");
		return;
	}
	
	my $args = $sargv[1];
	my ($i);
	for ($i = 2; $i < count(@sargv); $i++) { $args .= ' '.$sargv[$i]; }
	
	serv_notice("operserv", $user, "Eval Result: ".eval($args));
	svsilog("operserv", $user, "EVAL", $args);
}

1;
