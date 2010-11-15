# chanserv/set by The Chakora Project. Allows users to set channel settings
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("chanserv/set", "The Chakora Project", "0.1", \&init_cs_set, \&void_cs_set);

sub init_cs_set {
	cmd_add("chanserv/set", "Allows you to set channel settings", "SET allows you to manage the way various\naspects of your channel operate, such as \ntopiclock and fantasy.\n[T]\nSET options:\n[T]\n\002FANTASY\002 - Enables fantasy in your channel.\n\002GUARD\002 - Makes ChanServ stay in your channel until user count is below 1.\n\002RESTRICTED\002 - Restricts your channel from users who don't have flags.\n\002TOPICLOCK\002 - Keeps your topic 'locked' from changing unless the user has the +t flag.\n\002NOSTATUS\002 - Prevents users from recieving status regardless if they have flags or not.\n\002DESCRIPTION\002 - Changes your channels description.\n\002URL\002 - Sets a URL for your channel\n\002NOEXPIRE\002 - Makes a channel never expire. This is settable by service operators only.\n\002AUTOVOICE\002 - Allows you to autovoice all or all registered users upon joining your channel\n[T]\nSyntax: SET <option> [parameters]", \&svs_cs_set);
	fantasy("set", 1);
	if (!flag_exists("s")) {
	        flaglist_add("s", "Allows the use of SET");
	}
}

sub void_cs_set {
        delete_sub 'init_cs_set';
        delete_sub 'svs_cs_set';
	delete_sub 'cs_set_description';
	delete_sub 'cs_set_autovoice';
	delete_sub 'cs_set_url';
	delete_sub 'cs_set_guard';
	delete_sub 'cs_set_fantasy';
	delete_sub 'cs_set_nostatus';
	delete_sub 'cs_set_topiclock';
	delete_sub 'cs_set_restricted';
	delete_sub 'cs_set_noexpire';
	flaglist_del("s");
	fantasy_del("set");
        cmd_del("chanserv/set");
	delete_sub 'void_cs_set';
}

sub svs_cs_set {
        my ($user, @sargv) = @_;

	if (!is_identified($user)) {
		serv_notice("chanserv", $user, "You are not identified.");
		return;
	}
	elsif(!defined($sargv[1]) or !defined($sargv[2])) {
		serv_notice("chanserv", $user, "Not enough parameters. Syntax: SET <channel> <setting> [options]");
		return;
	}
	elsif (!is_registered(2, $sargv[1])) {
		serv_notice("chanserv", $user, $sargv[1]." is not registered.");
		return;
	}
	elsif (!has_flag(uidInfo($user, 9), $sargv[1], "s")) {
		serv_notice("chanserv", $user, "Permission denied");
		return;
	}
	elsif (lc($sargv[2]) eq 'url') {
		if (!defined($sargv[3])) {
			cs_unset_url($user, $sargv[1]);
               	}
		else {
			cs_set_url($user, $sargv[1], $sargv[3]);
		}
	}
        elsif (lc($sargv[2]) eq 'description') {
                if (!defined($sargv[3])) {
                        serv_notice("chanserv", $user, "Not enough parameters. Syntax: SET <channel> DESCRIPTION <description>");
                }
                else {
			my $desc = $sargv[3];
			my ($i);
			for ($i = 4; $i < count(@sargv); $i++) { $desc .= ' '.$sargv[$i]; }
                        cs_set_description($user, $sargv[1], $desc);
                }
        }
	elsif (lc($sargv[2]) eq 'guard') {
        	if (!defined($sargv[3])) {
                	serv_notice("chanserv", $user, "Not enough parameters. Syntax: SET <channel> GUARD <on/off>");
                }
		elsif (lc($sargv[3]) eq 'on' or lc($sargv[3]) eq 'off') {
			cs_set_guard($user, $sargv[1], lc($sargv[3]));
		}
		else {
                        serv_notice("chanserv", $user, "Invalid parameter. Syntax: SET <channel> GUARD <on/off>");
		}
	}
        elsif (lc($sargv[2]) eq 'nostatus') {
                if (!defined($sargv[3])) {
                        serv_notice("chanserv", $user, "Not enough parameters. Syntax: SET <channel> NOSTATUS <on/off>");
                }
                elsif (lc($sargv[3]) eq 'on' or lc($sargv[3]) eq 'off') {
                        cs_set_nostatus($user, $sargv[1], lc($sargv[3]));
                }
                else {
                        serv_notice("chanserv", $user, "Invalid parameter. Syntax: SET <channel> NOSTATUS <on/off>");
                }
        }
        elsif (lc($sargv[2]) eq 'autovoice') {
                if (!defined($sargv[3])) {
                        serv_notice("chanserv", $user, "Not enough parameters. Syntax: SET <channel> AUTOVOICE <all/registered/off>");
                }
                elsif (lc($sargv[3]) eq 'all' or lc($sargv[3]) eq 'registered' or lc($sargv[3]) eq 'off') {
                        cs_set_autovoice($user, $sargv[1], lc($sargv[3]));
                }
                else {
                        serv_notice("chanserv", $user, "Invalid parameter. Syntax: SET <channel> AUTOVOICE <all/registered/off>");
                }
        }

        elsif (lc($sargv[2]) eq 'restricted') {
                if (!defined($sargv[3])) {
                        serv_notice("chanserv", $user, "Not enough parameters. Syntax: SET <channel> RESTRICTED <on/off>");
                }
                elsif (lc($sargv[3]) eq 'on' or lc($sargv[3]) eq 'off') {
                        cs_set_restricted($user, $sargv[1], lc($sargv[3]));
                }
                else {
                        serv_notice("chanserv", $user, "Invalid parameter. Syntax: SET <channel> RESTRICTED <on/off>");
                }
        }
        elsif (lc($sargv[2]) eq 'topiclock') {
                if (!defined($sargv[3])) {
                        serv_notice("chanserv", $user, "Not enough parameters. Syntax: SET <channel> TOPICLOCK <on/off>");
                }
                elsif (lc($sargv[3]) eq 'on' or lc($sargv[3]) eq 'off') {
                        cs_set_topiclock($user, $sargv[1], lc($sargv[3]));
                }
                else {
                        serv_notice("chanserv", $user, "Invalid parameter. Syntax: SET <channel> TOPICLOCK <on/off>");
                }
        }
	elsif (lc($sargv[2]) eq 'noexpire') {
                if (!is_soper($user)) {
                        serv_notice("chanserv", $user, "Permission denied.");
                }
                elsif (!defined($sargv[2]) or !defined($sargv[3])) {
                        serv_notice("chanserv", $user, "Not enough parameters. Syntax: SET NOEXPIRE <channel> <on/off>");
                }
                elsif (!is_registered(2, $sargv[2])) {
                        serv_notice("chanserv", $user, "Channel \002".$sargv[2]."\002 is not registered.");
                }
                elsif (lc($sargv[3]) eq 'on' or lc($sargv[3]) eq 'off') {
                        cs_set_noexpire($user, $sargv[2], lc($sargv[3]));
                }
                else {
                        serv_notice("chanserv", $user, "Invalid parameter. Syntax: SET NOEXPIRE <channel> <on/off>");
                }
        }

        elsif (lc($sargv[2]) eq 'fantasy') {
                if (!defined($sargv[3])) {
                        serv_notice("chanserv", $user, "Not enough parameters. Syntax: SET <channel> FANTASY <on/off>");
                }
		elsif (!config('services', 'use_fantasy')) {
			serv_notice("chanserv", $user, "Fantasy has been disabled. Please contact an IRCop for more information.");
		}
                elsif (lc($sargv[3]) eq 'on' or lc($sargv[3]) eq 'off') {
                        cs_set_fantasy($user, $sargv[1], lc($sargv[3]));
                }
                else {
                        serv_notice("chanserv", $user, "Invalid parameter. Syntax: SET FANTASY <channel> <on/off>");
                }
        }

}

sub cs_set_description {
        my ($user, $chan, $desc) = @_;
	$Chakora::DB_chan{lc($chan)}{desc} = $desc;
	serv_notice("chanserv", $user, "The description for ".$chan." has been changed to: \2".$desc."\2");
	svsilog("chanserv", $user, "SET:".$chan.":DESCRIPTION", $desc);
}

sub cs_set_url {
        my ($user, $chan, $url) = @_;
	metadata_add(2, $chan, "data:url", $url);
	serv_notice("chanserv", $user, "Set channel URL for ".$chan." to ".$url);
	svsilog("chanserv", $user, "SET:".$chan.":URL", $url);
}

sub cs_unset_url {
        my ($user, $chan) = @_;
        metadata_del(2, $chan, "data:url");
        serv_notice("chanserv", $user, "Unset channel URL for ".$chan);
        svsilog("chanserv", $user, "UNSET:".$chan.":URL");
}

sub cs_set_guard {
	my ($user, $chan, $option) = @_;
	if ($option eq 'on') {
                if (!metadata(2, $chan, "option:guard")) {
                	metadata_add(2, $chan, "option:guard", 1);
			serv_notice("chanserv", $user, "\2GUARD\2 flag set on ".$chan);
			svsilog("chanserv", $user, "SET:".$chan.":GUARD", "ON");
                }
		else {
			serv_notice("chanserv", $user, "The \2GUARD\2 flag is already set on ".$chan);
		}
	}
	elsif ($option eq 'off') {
                if (metadata(2, $chan, "option:guard")) {
                        metadata_del(2, $chan, "option:guard");
                        serv_notice("chanserv", $user, "\2GUARD\2 flag unset on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":GUARD", "OFF");
                }
                else {
                        serv_notice("chanserv", $user, "The \2GUARD\2 flag is already unset on ".$chan);
                }
	}
}

sub cs_set_fantasy {
        my ($user, $chan, $option) = @_;
        if ($option eq 'on') {
                if (!metadata(2, $chan, "option:fantasy")) {
                        metadata_add(2, $chan, "option:fantasy", 1);
                        serv_notice("chanserv", $user, "\2FANTASY\2 flag set on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":FANTASY", "ON");
                }
                else {
                        serv_notice("chanserv", $user, "The \2FANTASY\2 flag is already set on ".$chan);
                }
        }
        elsif ($option eq 'off') {
                if (metadata(2, $chan, "option:fantasy")) {
                        metadata_del(2, $chan, "option:fantasy");
                        serv_notice("chanserv", $user, "\2FANTASY\2 flag unset on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":FANTASY", "OFF");
                }
                else {
                        serv_notice("chanserv", $user, "The \2FANTASY\2 flag is already unset on ".$chan);
                }
        }
}

sub cs_set_nostatus {
        my ($user, $chan, $option) = @_;
        if ($option eq 'on') {
                if (!metadata(2, $chan, "option:nostatus")) {
                        metadata_add(2, $chan, "option:nostatus", 1);
                        serv_notice("chanserv", $user, "\2NOSTATUS\2 flag set on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":NOSTATUS", "ON");
                }
                else {
                        serv_notice("chanserv", $user, "The \2NOSTATUS\2 flag is already set on ".$chan);
                }
        }
        elsif ($option eq 'off') {
                if (metadata(2, $chan, "option:nostatus")) {
                        metadata_del(2, $chan, "option:nostatus");
                        serv_notice("chanserv", $user, "\2NOSTATUS\2 flag unset on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":NOSTATUS", "OFF");
                }
                else {
                        serv_notice("chanserv", $user, "The \2NOSTATUS\2 flag is already unset on ".$chan);
                }
        }
}

sub cs_set_restricted {
        my ($user, $chan, $option) = @_;
        if ($option eq 'on') {
                if (!metadata(2, $chan, "option:restricted")) {
                        metadata_add(2, $chan, "option:restricted", 1);
                        serv_notice("chanserv", $user, "\2RESTRICTED\2 flag set on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":RESTRICTED", "ON");
                }
                else {
                        serv_notice("chanserv", $user, "The \2RESTRICTED\2 flag is already set on ".$chan);
                }
        }
        elsif ($option eq 'off') {
                if (metadata(2, $chan, "option:restricted")) {
                        metadata_del(2, $chan, "option:restricted");
                        serv_notice("chanserv", $user, "\2RESTRICTED\2 flag unset on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":RESTRICTED", "OFF");
                }
                else {
                        serv_notice("chanserv", $user, "The \2RESTRICTED\2 flag is already unset on ".$chan);
                }
        }
}

sub cs_set_autovoice {
        my ($user, $chan, $option) = @_;
        if ($option eq 'all') {
                if (!metadata(2, $chan, "option:autovoice")) {
                        metadata_add(2, $chan, "option:autovoice", "all");
                        serv_notice("chanserv", $user, "\2AUTOVOICE (all)\2 flag set on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":AUTOVOICE", "ALL");
                }
        }
        elsif ($option eq 'registered') {
                if (!metadata(2, $chan, "option:autovoice")) {
                        metadata_add(2, $chan, "option:autovoice", "registerd");
                        serv_notice("chanserv", $user, "\2AUTOVOICE (registered)\2 flag set on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":AUTOVOICE", "REGISTERED");
                } 
        }
        elsif ($option eq 'off') {
                if (metadata(2, $chan, "option:autovoice")) {
                        metadata_del(2, $chan, "option:autovoice");
                        serv_notice("chanserv", $user, "\2AUTOVOICE\2 flag unset on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":AUTOVOICE", "OFF");
                }
        }
}

sub cs_set_topiclock {
        my ($user, $chan, $option) = @_;
        if ($option eq 'on') {
                if (!metadata(2, $chan, "option:topiclock")) {
                        metadata_add(2, $chan, "option:topiclock", 1);
                        serv_notice("chanserv", $user, "\2TOPICLOCK\2 flag set on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":TOPICLOCK", "ON");
                }
                else {
                        serv_notice("chanserv", $user, "The \2TOPICLOCK\2 flag is already set on ".$chan);
                }
        }
        elsif ($option eq 'off') {
                if (metadata(2, $chan, "option:topiclock")) {
                        metadata_del(2, $chan, "option:topiclock");
                        serv_notice("chanserv", $user, "\2TOPICLOCK\2 flag unset on ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":TOPICLOCK", "OFF");
                }
                else {
                        serv_notice("chanserv", $user, "The \2TOPICLOCK\2 flag is already unset on ".$chan);
                }
        }
}

sub cs_set_noexpire {
        my ($user, $chan, $option) = @_;
        if ($option eq 'on') {
                if (!metadata(2, $chan, "option:noexpire")) {
                        metadata_add(2, $chan, "option:noexpire", 1);
                        serv_notice("chanserv", $user, "\2NOEXPIRE\2 flag set on channel ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":NOEXPIRE", "ON");
                }
                else {
                        serv_notice("chanserv", $user, "The \2NOEXPIRE\2 flag is already set on channel ".$chan);
                }
        }
        elsif ($option eq 'off') {
                if (metadata(2, $chan, "option:noexpire")) {
                        metadata_del(2, $chan, "option:noexpire");
                        serv_notice("chanserv", $user, "\2NOEXPIRE\2 flag unset on channel ".$chan);
                        svsilog("chanserv", $user, "SET:".$chan.":NOEXPIRE", "OFF");
                }
                else {
                        serv_notice("chanserv", $user, "The \2NOEXPIRE\2 flag is already unset on channel ".$chan);
                }
        }
}

1;
