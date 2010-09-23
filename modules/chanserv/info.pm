# chanserv/info by The Chakora Project. View information for a registered channel.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/info", "The Chakora Project", "0.1", \&init_cs_info, \&void_cs_info, "all");

sub init_cs_info {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/info", "Display information about a channel.", "INFO will display channel information such as\nregistration date and time, settings, founder\n,and other details.\n[T]\nSyntax: INFO <channel>", \&svs_cs_info);
}

sub void_cs_info {
	delete_sub 'init_cs_info';
	delete_sub 'svs_cs_info';
	cmd_del("chanserv/info");
	delete_sub 'void_cs_info';
}

sub svs_cs_info {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: INFO <channel>");
		return;
	}
	if (!is_registered(2, $sargv[1])) {
		serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 is not registered.");
		return;
	}
        if (substr($sargv[1], 0, 1) ne '#') {
                serv_notice("chanserv", $user, "Invalid channel name.");
                return;
        }

	my $chan = $Chakora::DB_chan{lc($sargv[1])}{name};
	serv_notice("chanserv", $user, "Information on \002".$Chakora::DB_chan{lc($sargv[1])}{name}."\002:");
	serv_notice("chanserv", $user, "Registered: ".scalar(localtime($Chakora::DB_chan{lc($chan)}{regtime})));
	serv_notice("chanserv", $user, "Founder: ".$Chakora::DB_chan{lc($chan)}{founder});
	serv_notice("chanserv", $user, "Description: ".$Chakora::DB_chan{lc($chan)}{desc});
	serv_notice("chanserv", $user, "MLOCK: ".$Chakora::DB_chan{lc($chan)}{mlock});

	my ($flags);
	foreach my $key (keys %Chakora::DB_chandata) {
		if (lc($Chakora::DB_chandata{$key}{chan}) eq lc($chan)) {
			my @flag = split('option:', $Chakora::DB_chandata{$key}{name});
			$flags .= ' '.uc($flag[1]);
		}
	}
	unless (!defined($flags)) {
		serv_notice("chanserv", $user, "Options:".$flags);
	}

	serv_notice("chanserv", $user, "\002*** End of Info ***\002");
}
