# chanserv/register by The Chakora Project. Allows users to register and protect channels with services.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("chanserv/register", "The Chakora Project", "0.1", \&init_cs_register, \&void_cs_register, "all");

sub init_cs_register {
	if (!module_exists("chanserv/main")) {
		module_load("chanserv/main");
	}
	cmd_add("chanserv/register", "Registers and protects a channel with services.", "REGISTER allows you to register a channel so\nthat you have better control over it. It\nwill also allow you to keep access lists, settings,\ntopics and keep the channel in sync and protected.\n[T]\nSyntax: REGISTER <#channel>", \&svs_cs_register);
}

sub void_cs_register {
	delete_sub 'init_cs_register';
	delete_sub 'svs_cs_register';
	cmd_del("chanserv/register");
	delete_sub 'void_cs_register';
}

sub svs_cs_register {
	my ($user, @sargv) = @_;
	
	if (!defined($sargv[1]) or !defined($sargv[2])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: REGISTER <#channel> <description>");
		return;
	}
	if (!uidInfo($user, 9)) {
		serv_notice("chanserv", $user, "You must be logged in to perform this operation.");
		return;
	}
	if (substr($sargv[1], 0, 1) ne '#') {
		serv_notice("chanserv", $user, "Invalid channel name.");
		return;
	}
	if (defined $Chakora::DB_chan{lc($sargv[1])}{name}) {
		serv_notice("chanserv", $user, "Channel \002$sargv[1]\002 is already registered.");
		return;
	}
	if (!isonchan($user, $sargv[1])) {
		serv_notice("chanserv", $user, "You are not on that channel.");
		return;
	}
	
	my $chan = $sargv[1];
	
	my $flags = '+vVoOtskiRmFSLC';
	if (defined $Chakora::PROTO_SETTINGS{owner}) {
		$flags .= 'qQ';
	}
	elsif (defined $Chakora::PROTO_SETTINGS{admin}) {
		$flags .= 'aA';
	}
	elsif (defined $Chakora::PROTO_SETTINGS{halfop}) {
		$flags .= 'hH';
	}
	elsif (defined $Chakora::PROTO_SETTINGS{mute}) {
		$flags .= 'M';
	}	
	$Chakora::DB_chan{lc($chan)}{name} = $chan;
	$Chakora::DB_chan{lc($chan)}{founder} = uidInfo($user, 9);
	$Chakora::DB_chan{lc($chan)}{regtime} = time();
	$Chakora::DB_chan{lc($chan)}{mlock} = '+nt';
	$Chakora::DB_chan{lc($chan)}{ts} = $Chakora::channel{lc($chan)}{'ts'};
	$Chakora::DB_chan{lc($chan)}{desc} = $sargv[2];
	my ($i);
	for ($i = 3; $i < count(@sargv); $i++) { $Chakora::DB_chan{lc($chan)}{desc} .= ' '.$sargv[$i]; }
	flags($chan, uidInfo($user, 9), $flags);
	metadata_add(2, $chan, 'option:guard', 1);
	metadata_add(2, $chan, 'option:fantasy', 1);
	serv_join("chanserv", $chan);
	
	my $modes = 'o';
	if (defined $Chakora::PROTO_SETTINGS{owner}) {
		$modes .= $Chakora::PROTO_SETTINGS{owner};
	}
	elsif (defined $Chakora::PROTO_SETTINGS{admin}) {
		$modes .= $Chakora::PROTO_SETTINGS{admin};
	}
	serv_mode("chanserv", $chan, "+$modes $user $user");
	serv_notice("chanserv", $user, "Channel \002$chan\002 is now registered to your account.");
	svsilog("chanserv", $user, "REGISTER", $chan);
	svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): ChanServ: REGISTER: $chan");
	event_cs_register($chan, $user, $Chakora::DB_chan{lc($chan)}{desc});
}
