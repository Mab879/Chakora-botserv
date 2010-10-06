# utilserv/time by Russell Bradford. Adds TIME to UtilServ, which shows users the current date & time
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("utilserv/time", "Russell Bradford", "1.0", \&init_us_time, \&void_us_time, "all");

sub init_us_time {
	cmd_add("utilserv/time", "Show the Current Date & Time", "Show the current date and time. \nThe date and time are retrieved from \nthe server that this service is running on. \n[T]\nSyntax: TIME", \&svs_us_time);
}

sub void_us_time {
	delete_sub 'init_us_time';
	delete_sub 'svs_us_time';
	cmd_del("utilserv/time");
       delete_sub 'void_us_time';
}

sub svs_us_time {
	my ($user, @sargv) = @_;
	
	my @months = qw(January February March April May June July August September October November December);
 	my @weekDays = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday);
 	my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
 	my $year = 1900 + $yearOffset;
 	my $timestr = "The current time is $hour:$minute:$second and today is $weekDays[$dayOfWeek]. The date is the $dayOfMonth of $months[$month] $year";
	serv_notice("utilserv", $user, $timestr);
	svsilog("utilserv", $user, "TIME");
	svsflog('commands', uidInfo($user, 1).": UtilServ: TIME");
	return;
}

1;