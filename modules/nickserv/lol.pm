# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#             nickserv/lol
#
# Adds a LOL command to NickServ.
use strict;
use warnings;

module_init("nickserv/lol", "The Chakora Project", "1.0", \&init_ns_lol, \&void_ns_lol, "all");

sub init_ns_lol {
	cmd_add("nickserv/lol", "dot", "dot", \&svs_ns_lol);
}

sub svs_ns_lol {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	if (uidInfo($user, 7)) {
		serv_notice('ns', $user, "Indeed; you are an oper.");
	} else {
		serv_notice('ns', $user, "Nope; you are not an oper.");
	}
}
