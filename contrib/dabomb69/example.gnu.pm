#!/usr/bin/perl

# example.pm - Example module for Chakora
# Copyright 2010 Chazz Wolcott <chazz@staticbox.net>
# Released under the GNU General Public License v2

=head1 NAME

example.gnu.pm - Example module for Chakora

=head1 DESCRIPTION

This module serves to illustrate the general concepts of the Chakora API. 
This module differs from example.pm in that it follows closely the GNU code style guide, instead of generally proper Perl syntax.

=head1 SYNOPSIS

=over 4

    use strict;
    use warnings;

    module_init( "service/module", "Author Name",
        "0.0", \&init_command, \&destroy_command, "no fucking clue" );

    sub init_command {
        hook_example_add( \&example_handler );
    }

    sub destroy_command {
        delete_sub 'example_handler';
        hook_example_del( \&example_handler );
    }
    
    sub example_handler {
        my ( $user, $channel ) = @_;
        example("BLAH $user $channel");
    }

=cut

use strict;
use warnings;
module_init("operserv/example", "Chazz Wolcott",
            "0.1", \&init_os_userlog, \&void_os_userlog, "all");

sub init_os_userlog
{
    hook_join_add(\&handle_join);
    hook_part_add(\&handle_part);
    hook_nick_add(\&handle_nick);
    hook_uid_add(\&handle_connect);
    hook_quit_add(\&handle_quit);
    hook_oper_add(\&handle_oper);
    hook_deoper_add(\&handle_deoper);
    hook_away_add(\&handle_away);
    hook_back_add(\&handle_back);
    hook_sid_add(\&handle_servers);
    hook_netsplit_add(\&handle_netsplit);
    hook_eos_add(\&handle_eos);
    hook_kill_add(\&handle_kill);
}

sub void_os_userlog
{
    delete_sub 'init_os_userlog';
    delete_sub 'svs_os_joinlog';
    delete_sub 'svs_os_partlog';
    delete_sub 'svs_os_nicklog';
    delete_sub 'svs_os_connectlog';
    delete_sub 'svs_os_quitlog';
    delete_sub 'svs_os_operlog';
    delete_sub 'svs_os_deoperlog';
    delete_sub 'svs_os_awaylog';
    delete_sub 'svs_os_backlog';
    delete_sub 'svs_os_sidlog';
    delete_sub 'svs_os_netsplit';
    delete_sub 'svs_os_eoslog';
    delete_sub 'svs_os_killlog';
    hook_join_del(\&svs_os_joinlog);
    hook_part_del(\&svs_os_partlog);
    hook_nick_del(\&svs_os_nicklog);
    hook_uid_del(\&svs_os_connectlog);
    hook_quit_del(\&svs_os_quitlog);
    hook_oper_del(\&svs_os_operlog);
    hook_deoper_del(\&svs_os_deoperlog);
    hook_away_del(\&svs_os_awaylog);
    hook_back_del(\&svs_os_backlog);
    hook_sid_del(\&svs_os_sidlog);
    hook_netsplit_del(\&svs_os_netsplit);
    hook_eos_del(\&svs_os_eoslog);
    hook_kill_del(\&svs_os_killlog);
}

sub svs_os_joinlog
{
    my ($user, $chan) = @_;
    if ($Chakora::synced)
    {
        serv_privmsg($service,
                     config('log', 'logchan'),
                     "\2JOIN\2: " . uidInfo($user, 1) . " -> " . $chan);
    }
}

sub svs_os_partlog
{
    my ($user, $chan) = @_;
    serv_privmsg($service,
                 config('log', 'logchan'),
                 "\2PART\2: " . uidInfo($user, 1) . " -> " . $chan);
}

sub svs_os_nicklog
{
    my ($user, $newnick) = @_;
    serv_privmsg($service,
                 config('log', 'logchan'),
                 "\2NICK\2: " . uidInfo($user, 6) . " -> " . $newnick);
}

sub svs_os_connectlog
{
    my ($uid, $nick, $user, $host, $mask, $ip, $server) = @_;
    if ($Chakora::synced)
    {
        serv_privmsg(
                     $service,
                     config('log', 'logchan'),
                     "\2CONNECT on "
                       . sidInfo($server, 1) . "\2: "
                       . $nick . "!"
                       . $user . "@"
                       . $host
                       . " (Mask: "
                       . $mask . " IP: "
                       . $ip . ")"
                    );
    }
}

sub svs_os_quitlog
{
    my ($user, $msg) = @_;
    serv_privmsg(
                 $service,
                 config('log', 'logchan'),
                 "\2QUIT\2: "
                   . uidInfo($user, 1) . " on "
                   . sidInfo(uidInfo($user, 8), 1)
                   . " Reason: "
                   . $msg
                );
}

sub svs_os_operlog
{
    my ($user) = @_;
    if ($Chakora::synced)
    {
        serv_privmsg(
                     $service,
                     config('log', 'logchan'),
                     "\2OPER\2: "
                       . uidInfo($user, 1) . " on "
                       . sidInfo(uidInfo($user, 8), 1)
                    );
    }
}

sub svs_os_deoperlog
{
    my ($user) = @_;
    if ($Chakora::synced)
    {
        serv_privmsg(
                     $service,
                     config('log', 'logchan'),
                     "\2DEOPER\2: "
                       . uidInfo($user, 1) . " on "
                       . sidInfo(uidInfo($user, 8), 1)
                    );
    }
}

sub svs_os_awaylog
{
    my ($user, $reason) = @_;
    if ($Chakora::synced)
    {
        serv_privmsg($service,
                     config('log', 'logchan'),
                     "\2AWAY\2: " . uidInfo($user, 1) . " - " . $reason);
    }
}

sub svs_os_backlog
{
    my ($user) = @_;
    serv_privmsg($service,
                 config('log', 'logchan'),
                 "\2BACK\2: " . uidInfo($user, 1));
}

sub svs_os_sidlog
{
    my ($server, $info) = @_;
    if ($Chakora::synced)
    {
        serv_privmsg(
                     $service,
                     config('log', 'logchan'),
                     "\2Server Introduction\2: " 
                       . $server
                       . " (Server Information - "
                       . $info . ")"
                    );
    }
}

sub svs_os_netsplit
{
    my ($server, $reason, $source) = @_;
    serv_privmsg(
                 $service,
                 config('log', 'logchan'),
                 "\2Netsplit\2: "
                   . sidInfo($server, 1)
                   . " split from "
                   . sidInfo($source, 1)
                   . " (Reason - "
                   . $reason . ")"
                );
}

sub svs_os_eoslog
{
    serv_privmsg(
                 $service,
                 config('log', 'logchan'),
                 "\2End of sync\2: "
                   . config('me',     'name') . " -> "
                   . config('server', 'host')
                   . " syncing complete"
                );
}

sub svs_os_killlog
{
    my ($user, $target, $reason) = @_;
    serv_privmsg(
                 $service,
                 config('log', 'logchan'),
                 "\2Kill\2: "
                   . uidInfo($user, 1)
                   . " killed "
                   . uidInfo($target, 1) . " "
                   . $reason
                );
}

# vim:cinoptions=>s,e0,n0,f0,{0,}0,^0,=s,ps,t0,c3,+s,(2s,us,)20,*30,gs,hs
# vim:ts=4
# vim:sw=4
# vim:noexpandtab
