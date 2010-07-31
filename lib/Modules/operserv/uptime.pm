# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#    Operserv Uptime Module
#          Modules::operserv::uptime
#
# Operserv Uptime module for Chakora

use strict;
use warnings;

cmd_add("operserv/uptime", "The Chakora Project", "0.1", "Uptime", "Display\nservices\nuptime", \&svs_os_uptime, "all");


sub svs_os_uptime {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
	my $sdate = scalar(localtime($Chakora::SERVICES_STARTTIME));
	my $uptime = time() - $Chakora::SERVICES_STARTTIME; 
	my $minutes = $uptime / 60;
	my $hours = $minutes / 60;
	my $days = $hours / 24;
	my $weeks = $days / 7;
	my $user = substr($rex[0], 1);
	serv_notice("os", $user, "Services were started at: ".$sdate);
	serv_notice("os", $user, "Services have been up for: ".int($days)." days.");
}

1;
