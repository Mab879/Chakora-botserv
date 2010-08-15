# operserv/help by The Chakora Project. Adds help functions to OperServ.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/help", "The Chakora Project", "0.1", \&init_os_help, \&void_os_register, "all");

sub init_os_help {
	cmd_add("operserv/help", "NO_HELP_ENTRY", "NO_HELP_ENTRY", \&svs_os_help);
}

sub void_os_help {
	delete_sub 'init_os_help';
	delete_sub 'svs_os_help';
	cmd_del("operserv/help");
}

sub svs_os_help {
    my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	if (defined($rex[4])) {
		my $hcmd = "operserv/".lc($rex[4]);
		if (defined($Chakora::HELP{$hcmd}{fhelp}) and $Chakora::HELP{$hcmd}{fhelp} ne "NO_HELP_ENTRY") {
			my @fhelp = split('\n', $Chakora::HELP{$hcmd}{fhelp});
			my ($help);
			serv_notice("os", $user, "\002***** OperServ Help *****\002");
			serv_notice("os", $user, "Help for \002".uc($rex[4])."\002:");
			serv_notice("os", $user, "\002\002");
			foreach $help (@fhelp) {
				$help =~ s/\[T\]/     /g;
				serv_notice("os", $user, $help);
			}
			serv_notice("os", $user, "\002\002");
			serv_notice("os", $user, "\002***** End of Help *****\002");
		} else {
			serv_notice("os", $user, "No help available for \002".uc($rex[4])."\002.");
		}
	} else {
		serv_notice("os", $user, "\002***** OperServ Help *****\002");
		serv_notice("os", $user, "\002OperServ\002 allows opers to better control services. a nickname");
		serv_notice("os", $user, "\002\002");
		serv_notice("os", $user, "For more information on a command, please type:");
		serv_notice("os", $user, "\002/msg ".config('operserv', 'nick')." HELP <command>\002");
		serv_notice("os", $user, "\002\002");
		serv_notice("os", $user, "The following commands are available:");
		my %commands = %Chakora::HELP;
		foreach my $key (sort keys %commands) {
			my @skey = split('/', $key);
			if (lc($skey[0]) eq 'operserv') {
				unless ($commands{$key}{shelp} eq "NO_HELP_ENTRY") {
					serv_notice("os", $user, "\002".uc($skey[1])."\002   -   ".$commands{$key}{shelp});
				}
			}
		}
		serv_notice("os", $user, "\002\002");
		serv_notice("os", $user, "\002***** End of Help *****\002");
	}
}