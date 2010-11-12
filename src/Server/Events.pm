# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#          Protocol Events Module
#	     Chakora::Server::Events
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

### JOIN ###
our (%hook_join);

# When users join a channel, execute all join hooks.
sub event_join {
    my ($user,$chan) = @_;
    my ($hook);
    foreach $hook (%hook_join) {
        eval { &{$hook}($user,$chan); };
    }
}

# Add a hook to the join event.
sub hook_join_add {
    my ($handler) = @_;
    $hook_join{$handler} = $handler;
}

# Delete a hook from the join event.
sub hook_join_del {
    my ($handler) = @_;
    undef $hook_join{$handler};
}

### QUIT ###
our (%hook_quit);

# When users disconnect, execute all quit hooks.
sub event_quit {
    my ( $user, $msg ) = @_;
    my ($hook);
    foreach $hook (%hook_quit) {
        eval { &{$hook}( $user, $msg ); };
    }
}

# Add a hook to the quit event.
sub hook_quit_add {
    my ($handler) = @_;
    $hook_quit{$handler} = $handler;
}

# Delete a hook from the quit event.
sub hook_quit_del {
    my ($handler) = @_;
    undef $hook_quit{$handler};
}

### NICK ###
our (%hook_nick);

# When users change their nick, execute all nick hooks.
sub event_nick {
    my ( $user, $newnick ) = @_;
    my ($hook);
    foreach $hook (%hook_nick) {
        eval { &{$hook}( $user, $newnick ); };
    }
}

# Add a hook to the nick event.
sub hook_nick_add {
    my ($handler) = @_;
    $hook_nick{$handler} = $handler;
}

# Delete a hook from the nick event.
sub hook_nick_del {
    my ($handler) = @_;
    undef $hook_nick{$handler};
}

### UID/EUID ###
our (%hook_uid);

# When users connect, execute all UID hooks.
sub event_uid {
    my ( $uid, $nick, $user, $host, $mask, $ip, $server ) = @_;
    my ($hook);
    foreach $hook (%hook_uid) {
        eval { &{$hook}( $uid, $nick, $user, $host, $mask, $ip, $server ); };
    }
}

# Add a hook to the UID event.
sub hook_uid_add {
    my ($handler) = @_;
    $hook_uid{$handler} = $handler;
}

# Delete a hook from the UID event.
sub hook_uid_del {
    my ($handler) = @_;
    undef $hook_uid{$handler};
}

### PART ###
our (%hook_part);

# When users part, execute all part hooks.
sub event_part {
    my ( $user, $chan, $msg ) = @_;
    my ($hook);
    foreach $hook (%hook_part) {
        eval { &{$hook}( $user, $chan, $msg ); };
    }
}

# Add a hook to the part event.
sub hook_part_add {
    my ($handler) = @_;
    $hook_part{$handler} = $handler;
}

# Delete a hook from the part event.
sub hook_part_del {
    my ($handler) = @_;
    undef $hook_part{$handler};
}

### PRIVMSG ###
our (%hook_privmsg);

# When users send a message, execute all privmsg hooks.
sub event_privmsg {
    my ( $user, $target, $msg ) = @_;
    my ($hook);
    foreach $hook (%hook_privmsg) {
        eval { &{$hook}( $user, $target, $msg ); };
    }
}

# Add a hook to the privmsg event.
sub hook_privmsg_add {
    my ($handler) = @_;
    $hook_privmsg{$handler} = $handler;
}

# Delete a hook from the privmsg event.
sub hook_privmsg_del {
    my ($handler) = @_;
    undef $hook_privmsg{$handler};
}

### NOTICE ###
our (%hook_notice);

# When users send a message, execute all notice hooks.
sub event_notice {
    my ( $user, $target, $msg ) = @_;
    my ($hook);
    foreach $hook (%hook_notice) {
        eval { &{$hook}( $user, $target, $msg ); };
    }
}

# Add a hook to the notice event.
sub hook_notice_add {
    my ($handler) = @_;
    $hook_notice{$handler} = $handler;
}

# Delete a hook from the notice event.
sub hook_notice_del {
    my ($handler) = @_;
    undef $hook_notice{$handler};
}

### OPER ###
our (%hook_oper);

# When a user opers, execute all oper hooks.
sub event_oper {
    my ($user) = @_;
    my ($hook);
    foreach $hook (%hook_oper) {
        eval { &{$hook}($user); };
    }
}

# Add a hook to the oper event.
sub hook_oper_add {
    my ($handler) = @_;
    $hook_oper{$handler} = $handler;
}

# Delete a hook from the oper event.
sub hook_oper_del {
    my ($handler) = @_;
    undef $hook_oper{$handler};
}

### DEOPER ###
our (%hook_deoper);

# When a user deopers, execute all deoper hooks.
sub event_deoper {
    my ($user) = @_;
    my ($hook);
    foreach $hook (%hook_deoper) {
        eval { &{$hook}($user); };
    }
}

# Add a hook to the deoper event.
sub hook_deoper_add {
    my ($handler) = @_;
    $hook_deoper{$handler} = $handler;
}

# Delete a hook from the deoper event.
sub hook_deoper_del {
    my ($handler) = @_;
    undef $hook_deoper{$handler};
}

## SERVER/SID ###
our (%hook_sid);

# When a server links, execute all SID hooks.
sub event_sid {
    my ( $server, $info ) = @_;
    my ($hook);
    foreach $hook (%hook_sid) {
        eval { &{$hook}( $server, $info ); };
    }
}

# Add a hook to the SID event.
sub hook_sid_add {
    my ($handler) = @_;
    $hook_sid{$handler} = $handler;
}

# Delete a hook from the SID event.
sub hook_sid_del {
    my ($handler) = @_;
    undef $hook_sid{$handler};
}

### Netsplit ###
our (%hook_netsplit);

# When a server splits, execute all netsplit hooks.
sub event_netsplit {
    my ( $server, $reason, $source ) = @_;
    my ($hook);
    foreach $hook (%hook_netsplit) {
        eval { &{$hook}( $server, $reason, $source ); };
    }
}

# Add a hook to the netsplit event.
sub hook_netsplit_add {
    my ($handler) = @_;
    $hook_netsplit{$handler} = $handler;
}

# Delete a hook from the netsplit event.
sub hook_netsplit_del {
    my ($handler) = @_;
    undef $hook_netsplit{$handler};
}

### AWAY ###
our (%hook_away);

# When a user goes away, execute all away hooks.
sub event_away {
    my ( $user, $reason ) = @_;
    my ($hook);
    foreach $hook (%hook_away) {
        eval { &{$hook}( $user, $reason ); };
    }
}

# Add a hook to the away event.
sub hook_away_add {
    my ($handler) = @_;
    $hook_away{$handler} = $handler;
}

# Delete a hook from the away event.
sub hook_away_del {
    my ($handler) = @_;
    undef $hook_away{$handler};
}

### Return from AWAY ###
our (%hook_back);

# When a user returns from away, execute all back hooks.
sub event_back {
    my ($user) = @_;
    my ($hook);
    foreach $hook (%hook_back) {
        eval { &{$hook}($user); };
    }
}

# Add a hook to the back event.
sub hook_back_add {
    my ($handler) = @_;
    $hook_back{$handler} = $handler;
}

# Delete a hook from the back event.
sub hook_back_del {
    my ($handler) = @_;
    undef $hook_back{$handler};
}

### End of Sync ###
our (%hook_eos);

# When we finish syncing, execute all end of sync hooks.
sub event_eos {
    foreach my $hook (%hook_eos) {
        eval { &{$hook}(); };
    }
}

# Add a hook to the end of sync event.
sub hook_eos_add {
    my ($handler) = @_;
    $hook_eos{$handler} = $handler;
}

# Delete a hook from the end of sync event.
sub hook_eos_del {
    my ($handler) = @_;
    undef $hook_eos{$handler};
}

### KILL ###
our (%hook_kill);

# When users is killed, execute all kill hooks.
sub event_kill {
    my ( $user, $target, $reason ) = @_;
    my ($hook);
    foreach $hook (%hook_kill) {
        eval { &{$hook}( $user, $target, $reason ); };
    }
}

# Add a hook to the kill event.
sub hook_kill_add {
    my ($handler) = @_;
    $hook_kill{$handler} = $handler;
}

# Delete a hook from the kill event.
sub hook_kill_del {
    my ($handler) = @_;
    undef $hook_kill{$handler};
}

### KICK ###
our (%hook_kick);

# When a user is kicked from a channel, execute all kick hooks.
sub event_kick {
        my ($user, $chan, $target, $reason) = @_;
        my ($hook);
        foreach $hook (%hook_kick) {
                eval
                {
                        &{ $hook }($user, $chan, $target, $reason);
                };
        }
}

# Add a hook to the kick event.
sub hook_kick_add {
        my ($handler) = @_;
        $hook_kick{$handler} = $handler;
}

# Delete a hook from the kick event.
sub hook_kick_del {
        my ($handler) = @_;
        undef $hook_kick{$handler};
}


### TOPIC ###
our (%hook_topic);

# When a channels topic is changed, execute all topic hooks.
sub event_topic {
        my ($user, $chan, $topic) = @_;
        my ($hook);
        foreach $hook (%hook_topic) {
                eval
                {
                        &{ $hook }($user, $chan, $topic);
                };
        }
}

# Add a hook to the topic event.
sub hook_topic_add {
        my ($handler) = @_;
        $hook_topic{$handler} = $handler;
}

# Delete a hook from the topic event.
sub hook_topic_del {
        my ($handler) = @_;
        undef $hook_topic{$handler};
}

### TOPIC Burst ###
our (%hook_stopic);

# When a topic is bursted, execute all topic burst hooks.
sub event_stopic {
        my ($nick, $chan, $topic) = @_;
        my ($hook);
        foreach $hook (%hook_stopic) {
                eval
                {
                        &{ $hook }($nick, $chan, $topic);
                };
        }
}

# Add a hook to the topic burst event.
sub hook_stopic_add {
        my ($handler) = @_;
        $hook_stopic{$handler} = $handler;
} 

# Delete a hook from the topic burst event.
sub hook_stopic_del {
        my ($handler) = @_;
        undef $hook_stopic{$handler};
}

### Perform During Sync ###
our (%hook_pds);

# After we create default services, execute all Perform During Sync hooks.
sub event_pds {
    foreach my $hook (%hook_pds) {
        eval { &{$hook}(); };
    }
}

# Add a hook to the Perform During Sync event.
sub hook_pds_add {
    my ($handler) = @_;
    $hook_pds{$handler} = $handler;
}

# Delete a hook from the Perform During Sync event.
sub hook_pds_del {
    my ($handler) = @_;
    undef $hook_pds{$handler};
}

### IDENTIFY ###
our (%hook_identify);

# When a user identifies, execute all identify hooks.
sub event_identify {
    my ( $user, $account ) = @_;
    my ($hook);
    foreach $hook (%hook_identify) {
        eval { &{$hook}( $user, $account ); };
    }
}

# Add a hook to the identify event.
sub hook_identify_add {
    my ($handler) = @_;
    $hook_identify{$handler} = $handler;
}

# Delete a hook from the identify event.
sub hook_identify_del {
    my ($handler) = @_;
    undef $hook_identify{$handler};
}

### NICKSERV REGISTER ###
our (%hook_ns_register);

# When a user registers, execute all nickserv register hooks.
sub event_ns_register {
    my ( $user, $email ) = @_;
    my ($hook);
    foreach $hook (%hook_ns_register) {
        eval { &{$hook}( $user, $email ); };
    }
}

# Add a hook to the nickserv register event.
sub hook_ns_register_add {
    my ($handler) = @_;
    $hook_ns_register{$handler} = $handler;
}

# Delete a hook from the nickserv register event.
sub hook_ns_register_del {
    my ($handler) = @_;
    undef $hook_ns_register{$handler};
}

### LOGOUT ###
our (%hook_logout);

# When a user logs out, execute all logout hooks.
sub event_logout {
    my ( $user, $account ) = @_;
    my ($hook);
    foreach $hook (%hook_logout) {
        eval { &{$hook}( $user, $account ); };
    }
}

# Add a hook to the logout event.
sub hook_logout_add {
    my ($handler) = @_;
    $hook_logout{$handler} = $handler;
}

# Delete a hook from the logout event.
sub hook_logout_del {
    my ($handler) = @_;
    undef $hook_logout{$handler};
}

### CHANSERV REGISTER ###
our (%hook_cs_register);

# When a user registers a channel, execute all chanserv register hooks.
sub event_cs_register {
    my ( $chan, $user, $desc ) = @_;
    my ($hook);
    foreach $hook (%hook_cs_register) {
        eval { &{$hook}( $chan, $user, $desc ); };
    }
}

# Add a hook to the chanserv register event.
sub hook_cs_register_add {
    my ($handler) = @_;
    $hook_cs_register{$handler} = $handler;
}

# Delete a hook from the chanserv register event.
sub hook_cs_register_del {
    my ($handler) = @_;
    undef $hook_cs_register{$handler};
}

### CTCP ###
our (%hook_ctcp);

# When a user ctcps a service, execute all ctcp hooks.
sub event_ctcp {
    my ( $user, $target, $type ) = @_;
    my ($hook);
    foreach $hook (%hook_ctcp) {
        eval { &{$hook}( $user, $target, $type ); };
    }
}

# Add a hook to the ctcp event.
sub hook_ctcp_add {
    my ($handler) = @_;
    $hook_ctcp{$handler} = $handler;
}

# Delete a hook from the ctcp event.
sub hook_ctcp_del {
    my ($handler) = @_;
    undef $hook_ctcp{$handler};
}

### CHGIDENT ###
our (%hook_chgident);

# When the server sends a CHGIDENT, execute all chgident hooks.
sub event_chgident {
    my ( $user, $old, $new ) = @_;
    my ($hook);
    foreach $hook (%hook_chgident) {
        eval { &{$hook}( $user, $old, $new ); };
    }
}

# Add a hook to the chgident event.
sub hook_chgident_add {
    my ($handler) = @_;
    $hook_chgident{$handler} = $handler;
}

# Delete a hook from the chgident event.
sub hook_chgident_del {
    my ($handler) = @_;
    undef $hook_chgident{$handler};
}

### CHGHOST ###
our (%hook_chghost);

# When the server sends a CHGHOST, execute all chghost hooks.
sub event_chghost {
    my ( $user, $old, $new ) = @_;
    my ($hook);
    foreach $hook (%hook_chghost) {
        eval { &{$hook}( $user, $old, $new ); };
    }
}

# Add a hook to the chghost event.
sub hook_chghost_add {
    my ($handler) = @_;
    $hook_chghost{$handler} = $handler;
}

# Delete a hook from the chghost event.
sub hook_chghost_del {
    my ($handler) = @_;
    undef $hook_chghost{$handler};
}

### MEMOSERV/SEND ###
our (%hook_ms_send);

# When a user sends a memo, execute all send hooks.
sub event_ms_send {
    my ( $user, $target, $msg ) = @_;
    my ($hook);
    foreach $hook (%hook_ms_send) {
        eval { &{$hook}( $user, $target, $msg ); };
    }
}

# Add a hook to the send event.
sub hook_ms_send_add {
    my ($handler) = @_;
    $hook_ms_send{$handler} = $handler;
}

# Delete a hook from the send event.
sub hook_ms_send_del {
    my ($handler) = @_;
    undef $hook_ms_send{$handler};
}

1;
