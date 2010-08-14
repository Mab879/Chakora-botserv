# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#             nickserv/help
#
# Adds a HELP command to NickServ.
use strict;
use warnings;

module_init("nickserv/help", "The Chakora Project", "0.1", \&init_ns_help, \&void_ns_register, "all");

sub init_ns_help {
	cmd_add("nickserv/help", "NO_HELP_ENTRY", "NO_HELP_ENTRY", \&svs_ns_help);
}

sub void_ns_help {
	delete_sub 'init_ns_help';
	delete_sub 'svs_ns_help';
	cmd_del("nickserv/help");
}

sub svs_ns_help {
    my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	if (defined($rex[4])) {
		if (defined($Chakora::COMMANDS{nickserv}{lc($rex[4])}{fhelp}) and $Chakora::COMMANDS{nickserv}{lc($rex[4])}{fhelp} ne "NO_HELP_ENTRY") {
			my @fhelp = split('\n', $Chakora::COMMANDS{nickserv}{lc($rex[4])}{fhelp});
			my ($help);
			serv_notice("ns", $user, "\002***** NickServ Help *****\002");
			serv_notice("ns", $user, "Help for \002".uc($rex[4])."\002:");
			serv_notice("ns", $user, "\002\002");
			foreach $help (@fhelp) {
				$help =~ s/\[T\]/     /g;
				serv_notice("ns", $user, $help);
			}
			serv_notice("ns", $user, "\002\002");
			serv_notice("ns", $user, "\002***** End of Help *****\002");
		} else {
			serv_notice("ns", $user, "No help available for \002".uc($rex[4])."\002.");
		}
	} else {
		serv_notice("ns", $user, "\002***** NickServ Help *****\002");
		serv_notice("ns", $user, "\002NickServ\002 allows users to '\002register\002' a nickname, and stop");
		serv_notice("ns", $user, "others from using that nick.  \002NickServ\002 allows the owner of a");
		serv_notice("ns", $user, "nickname to disconnect a user from the network that is using their");
		serv_notice("ns", $user, "nickname.");
		serv_notice("ns", $user, "\002\002");
		serv_notice("ns", $user, "For more information on a command, please type:");
		serv_notice("ns", $user, "\002/msg ".config('nickserv', 'nick')." HELP <command>\002");
		serv_notice("ns", $user, "\002\002");
		serv_notice("ns", $user, "The following commands are available:");
		my (%command, $command);
		foreach $command ($Chakora::COMMANDS{nickserv}) {
			unless ($command{shelp} eq "NO_HELP_ENTRY") {
				my @cmd = split('/', $command{name});
				serv_notice("ns", $user, "\002".uc($cmd[1])."\002   -   ".$command{shelp});
			}
		}
		serv_notice("ns", $user, "\002\002");
		serv_notice("ns", $user, "\002***** End of Help *****\002");
	}
}
