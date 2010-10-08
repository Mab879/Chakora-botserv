# protocol/inspircd12 by The Chakora Project. Link with InspIRCd 1.2.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

# This is a cheap hack, but it'll work --Matthew
$Chakora::MODULE{protocol}{name}    = 'protocol/inspircd12';
$Chakora::MODULE{protocol}{version} = '0.8';
$Chakora::MODULE{protocol}{author}  = 'The Chakora Project';

######### Core #########

our %rawcmds = (
    'UID'      => { handler => \&raw_uid, },
    'PING'     => { handler => \&raw_ping, },
    'QUIT'     => { handler => \&raw_quit, },
    'FJOIN'    => { handler => \&raw_fjoin, },
    'NICK'     => { handler => \&raw_nick, },
    'PART'     => { handler => \&raw_part, },
    'FHOST'    => { handler => \&raw_fhost, },
    'SETIDENT' => { handler => \&raw_setident, },
    'VERSION'  => { handler => \&raw_version, },
    'PRIVMSG'  => { handler => \&raw_privmsg, },
    'NOTICE'   => { handler => \&raw_notice, },
    'OPERTYPE' => { handler => \&raw_opertype, },
    'MODE'     => { handler => \&raw_mode, },
    'ERROR'    => { handler => \&raw_error, },
    'ENDBURST' => { handler => \&raw_endburst, },
    'SQUIT'    => { handler => \&raw_squit, },
    'RSQUIT'   => { handler => \&raw_squit, },
    'AWAY'     => { handler => \&raw_away, },
    'KILL'     => { handler => \&raw_kill, },
    'SVSNICK'  => { handler => \&raw_svsnick, },
    'KICK'     => { handler => \&raw_kick, },
    'TOPIC'    => { handler => \&raw_topic, },
    'FTOPIC'   => { handler => \&raw_ftopic, },
    'MOTD'     => { handler => \&raw_motd, },
    'ADMIN'    => { handler => \&raw_admin, },
    'FMODE'    => { handler => \&raw_fmode, },
    'METADATA' => { handler => \&raw_metadata, },
    'CHGHOST'  => { handler => \&raw_chghost, },
    'CHGIDENT' => { handler => \&raw_chgident, },
);

%Chakora::PROTO_SETTINGS = (
    name    => 'InspIRCd 1.2',
    op      => 'o',
    voice   => 'v',
    cmodes => {
		'b'  => 2,
		'i'  => 1,
		'k'  => 2,
		'l'  => 2,
		'm'  => 1,
		'n'  => 1,
		'p'  => 1,
		's'  => 1,
		't'  => 1,
	},
);

our ( %uid, %channel, %sid );
my $lastid = 0;

sub irc_connect {
    if ( length( config( 'me', 'sid' ) ) != 3 ) {
        error( 'chakora', 'Services SID have to be 3 characters' );
    }
    else {
                $Chakora::sid{config('me', 'sid')}{'name'} = config('me', 'name');
                $Chakora::sid{config('me', 'sid')}{'info'} = config('me', 'info');
                $Chakora::sid{config('me', 'sid')}{'sid'} = config('me', 'sid');
		if (config('services', 'updatets')) {
			foreach my $key (keys %Chakora::DB_chan) {
				$Chakora::channel{$key}{'ts'} = $Chakora::DB_chan{$key}{ts};
			}
		}
        send_sock( "SERVER "
              . config( 'me',     'name' ) . " "
              . config( 'server', 'password' ) . " 0 "
              . config( 'me',     'sid' ) . " :"
              . config( 'me',     'info' ) );
    }
}

# Get service UID
sub svsUID {
    my ($svs) = @_;
    if ( lc($svs) eq 'chakora::server' ) {
        return config( 'me', 'sid' );
    }
    else {
        return $Chakora::svsuid{$svs};
    }
}

# Get UID info
sub uidInfo {
    my ( $ruid, $section ) = @_;
    if ( $section == 1 ) {
        return $Chakora::uid{$ruid}{'nick'};
    }
    elsif ( $section == 2 ) {
        return $Chakora::uid{$ruid}{'user'};
    }
    elsif ( $section == 3 ) {
        return $Chakora::uid{$ruid}{'host'};
    }
    elsif ( $section == 4 ) {
        return $Chakora::uid{$ruid}{'mask'};
    }
    elsif ( $section == 5 ) {
        return $Chakora::uid{$ruid}{'ip'};
    }
    elsif ( $section == 6 ) {
        return $Chakora::uid{$ruid}{'pnick'};
    }
    elsif ( $section == 7 ) {
        return $Chakora::uid{$ruid}{'oper'};
    }
    elsif ( $section == 8 ) {
        return $Chakora::uid{$ruid}{'server'};
    }
    elsif ( $section == 9 ) {
        return $Chakora::uid{$ruid}{'account'};
    }
    elsif ( $section == 10 ) {
        return $Chakora::uid{$ruid}{'chans'};
    }
    else {
        return 0;
    }
}

# Get SID info
sub sidInfo {
    my ( $id, $section ) = @_;
    if ( $section == 1 ) {
        return $Chakora::sid{$id}{'name'};
    }
    elsif ( $section == 2 ) {
        return $Chakora::sid{$id}{'info'};
    }
    elsif ( $section == 3 ) {
        return $Chakora::sid{$id}{'sid'};
    }
    elsif ( $section == 4 ) {
        return $Chakora::sid{$id}{'hub'};
    }
    else {
        return 0;
    }
}

# Find UID by nick
sub nickUID {
    my ($nick) = @_;
    foreach my $key ( keys %Chakora::uid ) {
        if ( lc( $Chakora::uid{$key}{'nick'} ) eq lc($nick) ) {
            return $Chakora::uid{$key}{'uid'};
        }
    }
    return 0;
}

# Check if a user is on a channel
sub isonchan {
    my ( $user, $chan ) = @_;
    $chan = lc($chan);
    $user = uc($user);
    my $i = 0;
    my @members = split( ' ', $Chakora::channel{$chan}{'members'} );
    foreach my $member (@members) {
        if ( $member eq $user ) {
            $i = 1;
        }
    }
    return $i;
}

######### Sending data #########

# Send raw data to server in full compliance with the API
sub serv_ {
    my ( $svs, $data ) = @_;
    send_sock( ":" . svsUID($svs) . " $data" );
}

# Handle client creation
sub serv_add {
    my ( $svs, $user, $nick, $host, $modes, $real ) = @_;
    $svs = lc($svs);
    $lastid += 1;
    my $calc = 6 - length($lastid);
    print $calc. "\n";
    my ($ap);
    while ( $calc != 0 ) {
        $ap .= '0';
        $calc -= 1;
    }
    $Chakora::svsuid{$svs} = config( 'me', 'sid' ) . $ap . $lastid;
    my $ruid = config( 'me', 'sid' ) . $ap . $lastid;
    $Chakora::svsnick{$svs} = $nick;
    send_sock( ":"
          . svsUID('chakora::server') . " UID "
          . $ruid . " "
          . time() . " "
          . $nick . " "
          . $host . " "
          . $host . " "
          . $user
          . " 0.0.0.0 "
          . time() . " "
          . $modes . " :"
          . $real );
    send_sock( ":" . $ruid . " OPERTYPE Service" );
    if ($Chakora::synced) { serv_join( $svs, config( 'log', 'logchan' ) ); }
}

# Handle client deletion
sub serv_del {
    my ($svs) = @_;
    if ( defined $Chakora::svsuid{ lc($svs) } ) {
        logchan( 'operserv', "\002!!!\002 Deleting service: \002$svs\002" );
        serv_quit( lc($svs), "Service unloaded" );
        delete $Chakora::svsuid{ lc($svs) };
        delete $Chakora::svsnick{ lc($svs) };
    }
}

# Handle PRIVMSG
sub serv_privmsg {
    my ( $svs, $target, $msg ) = @_;
    send_sock( ":" . svsUID($svs) . " PRIVMSG " . $target . " :" . $msg );
}

# Handle NOTICE
sub serv_notice {
    my ( $svs, $target, $msg ) = @_;
    send_sock( ":" . svsUID($svs) . " NOTICE " . $target . " :" . $msg );
}

# Handle TOPIC 
sub serv_topic {
	my ( $svs, $chan, $topic ) = @_;
	send_sock(":".svsUID($svs)." TOPIC ".$chan." :".$topic);
}

# Handle JOIN/FJOIN
sub serv_join {
    my ( $svs, $chan ) = @_;

# If a channel has no TS, we're obviously creating that channel, set TS to current time --Matthew
    if ( !$Chakora::channel{ lc($chan) }{'ts'} ) {
        $Chakora::channel{ lc($chan) }{'ts'} = time();
    }
    my $modes = '+';
    if ( defined $Chakora::DB_chan{ lc($chan) }{mlock} ) {
        $modes = $Chakora::DB_chan{ lc($chan) }{mlock};
    }
    send_sock( ":"
          . svsUID("chakora::server")
          . " FJOIN "
          . $chan . " "
          . $Chakora::channel{ lc($chan) }{'ts'}
          . " $modes :o,"
          . svsUID($svs) );
}

# Handle Client MODE
sub serv_cmode {
    my ( $svs, $target, $modes ) = @_;
    send_sock( ":" . svsUID($svs) . " MODE " . $target . " " . $modes );
}

# Handle FMODE
sub serv_mode {
    my ( $svs, $target, $modes ) = @_;

    # This should never happen, but just in case, have a check.
    if ( !$Chakora::channel{ lc($target) }{'ts'} ) {
        $Chakora::channel{ lc($target) }{'ts'} = time();
    }
    send_sock( ":"
          . svsUID($svs)
          . " FMODE "
          . $target . " "
          . $Chakora::channel{ lc($target) }{'ts'} . " "
          . $modes );
    # This is a cheap hack, but it'll work for now --Matthew
    raw_fmode( ":"
          . svsUID($svs)
          . " FMODE "
          . $target . " "
          . $Chakora::channel{ lc($target) }{'ts'} . " "
          . $modes );

}

# Handle ERROR
sub serv_error {
    my ($error) = @_;
    send_sock( ":" . svsUID('chakora::server') . " ERROR :" . $error );
}

# Handle INVITE
sub serv_invite {
    my ( $svs, $target, $chan ) = @_;
    send_sock( ":" . svsUID($svs) . " INVITE " . $target . " " . $chan );
}

# Handle KICK
sub serv_kick {
    my ( $svs, $chan, $user, $msg ) = @_;
    send_sock(
        ":" . svsUID($svs) . " KICK " . $chan . " " . $user . " :" . $msg );
}

# Handle PART
sub serv_part {
    my ( $svs, $chan, $msg ) = @_;
    send_sock( ":" . svsUID($svs) . " PART " . $chan . " :" . $msg );
}

# Handle QUIT
sub serv_quit {
    my ( $svs, $msg ) = @_;
    send_sock( ":" . svsUID($svs) . " QUIT :" . $msg );
}

# Handle CHGHOST
sub serv_chghost {
    my ( $user, $newhost ) = @_;
    send_sock( ":"
          . svsUID('chakora::server')
          . " CHGHOST "
          . $user . " "
          . $newhost );
}

# Handle CHGIDENT
sub serv_chgident {
    my ( $user, $newident ) = @_;
    send_sock( ":"
          . svsUID('chakora::server')
          . " CHGIDENT "
          . $user . " "
          . $newident );
}

# Handle CHGNAME
sub serv_chgname {
    my ( $user, $newname ) = @_;
    send_sock( ":"
          . svsUID('chakora::server')
          . " CHGNAME "
          . $user . " :"
          . $newname );
}

# Handle WALLOPS
sub serv_wallops {
    my ($msg) = @_;
    send_sock( ":" . svsUID('chakora::server') . " WALLOPS :" . $msg );
}

# Set account name
sub serv_accountname {
    my ( $user, $name ) = @_;
    send_sock( ":"
          . svsUID('chakora::server')
          . " METADATA "
          . $user
          . " accountname :"
          . $name );
	$Chakora::uid{$user}{'account'} = $name;
}

# Handle when a user logs out of NickServ
sub serv_logout {
    my ($user) = @_;
    send_sock( ":"
          . svsUID('chakora::server')
          . " METADATA "
          . $user
          . " accountname" );
	delete $Chakora::uid{$user}{'account'};
}

# Handle KILL
sub serv_kill {
    my ( $svs, $user, $reason ) = @_;
    if ( length($reason) == 0 ) {
        send_sock( ":" . svsUID($svs) . " KILL " . $user );
    }
    else {
        send_sock( ":" . svsUID($svs) . " KILL " . $user . " :" . $reason );
    }
	delete $Chakora::uid{$user};
}

# Handle SQUIT
sub serv_squit {
    my ( $server, $reason ) = @_;
    send_sock( ":" . svsUID("chakora::server") . " SQUIT $server :$reason" );
    if ($server eq config('me', 'sid')) {
		return;
	}
    my ($ssid);
	foreach my $key (keys %Chakora::sid) {
		if ($Chakora::sid{$key}{'name'} eq $server) {
			delete $Chakora::sid{$key};
			$ssid = $key;
		}
	}
	foreach my $key (keys %Chakora::uid) {
		if ($Chakora::uid{$key}{'server'} eq $ssid) {
			delete $Chakora::uid{$key};
		}
	}
}

# Handle jupes
sub serv_jupe {
        my ($server, $reason) = @_;
	my $sid = gen_sid(0); 
	my ($ssid);
	if (!$sid) {
		logchan("operserv", "UNABLE TO GENERATE SID FOR JUPE!!");
	}
	else {
        send_sock(":".svsUID('os')." SQUIT ".$server." :".$reason);
		foreach my $key (keys %Chakora::sid) {
			if ($Chakora::sid{$key}{'name'} eq $server) {
				$ssid = $key;
			}
		}
        send_sock(":".svsUID('chakora::server')." SERVER ".$server." 2 :(JUPED) ".$reason);
		$Chakora::sid{$sid}{'sid'} = $sid;
		$Chakora::sid{$sid}{'name'} = $server;
		$Chakora::sid{$sid}{'hub'} = config('me', 'sid');	
		$Chakora::sid{$sid}{'info'} = "(JUPED) ".$reason;
		foreach my $key (keys %Chakora::uid) {
			if ($Chakora::uid{$key}{'server'} eq $ssid) {
				delete $Chakora::uid{$key};
			}
		}
	}
}

# Handle GLOBAL
sub serv_global {
        my ($svs, $msg) = @_;
        foreach my $key ( keys %uid ) {
                serv_notice($svs, $Chakora::uid{$key}{'uid'}, $msg);
        }
}

# Send global messages
sub send_global {
    my ($msg) = @_;
    my $svs = 'operserv';
    if (module_exists("global/main")) {
	$svs = 'global';
    }
    foreach my $key ( keys %uid ) {
        serv_notice($svs, $Chakora::uid{$key}{'uid'}, $msg);
    }
}

# Handle enforcement
sub serv_enforce {
    my ( $user, $newnick ) = @_;
    if ( defined $Chakora::uid{$user}{'nick'} ) {
        send_sock( ":"
              . svsUID('chakora::server')
              . " SVSNICK $user $newnick "
              . time() );
    }
}

# Handle network bans
sub serv_netban {
	my ($user, $host, $duration, $reason) = @_;
	my $mask = $user.'@'.$host;
	send_sock(":".svsUID("chakora::server")." ADDLINE G $mask ".config('me', 'name')." ".time." $duration :$reason");
}

######### Receiving data #########

# Handle CAPAB
sub raw_capab {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	
	if ($rex[1] eq 'CAPABILITIES') {
		foreach my $std (@rex) {
			if (substr($std, 0, 6) eq 'PREFIX') {
				$std =~ s/PREFIX=//g;
				$std =~ s/\)/\|/g;
				$std =~ s/\(//g;
				my @stix = split('\|', $std);
				if ($stix[0] !~ m/o/ or $stix[0] !~ m/v/) {
					error("chakora", "Op (+o) and voice (+v) are required by Chakora. These were not found in the IRCd.");
				}
				my $lix = $stix[0];
				$lix =~ s/o//g;
				$lix =~ s/v//g;
				if ($lix =~ m/q/) {
					$Chakora::PROTO_SETTINGS{owner} = 'q';
					$lix =~ s/q//g;
				}
				if ($lix =~ m/a/) {
					$Chakora::PROTO_SETTINGS{admin} = 'a';
					$lix =~ s/a//g;
				}
				if ($lix =~ m/h/) {
					$Chakora::PROTO_SETTINGS{halfop} = 'h';
					$lix =~ s/h//g;
				}
				if (defined $lix) {
					if ($lix ne "") {
						$Chakora::PROTO_SETTINGS{ukprefix} = $lix;
					}
				}
			}
		}
	}
	if ($rex[1] eq 'MODULES') {
		$Chakora::PROTO_SETTINGS{modules} .= $rex[2];
	}
	if ($rex[1] eq 'END') {
		my $modules = $Chakora::PROTO_SETTINGS{modules};
		if ($modules =~ 'm_invisible.so') {
			taint("InspIRCd: m_invisible.so is loaded. We do not support this for ethical reasons.");
		}
		if ($modules !~ 'm_services_account.so') {
			error("chakora", "When using Chakora with InspIRCd, m_services_account.so is needed, please load it and try again!");
		}
		if ($modules !~ 'm_servprotect.so') {
			print("[PROTOCOL] m_servprotect.so isn't loaded, it isn't required, but is recommended.\n");
		} else { $Chakora::PROTO_SETTINGS{god} = 'k'; }
		if ($modules =~ 'm_muteban.so') {
			$Chakora::PROTO_SETTINGS{mute} = 'b m:';
		}
		
		# Store modular channel modes
		if ($modules =~ 'm_allowinvite.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'A'} = 1;
		}
		if ($modules =~ 'm_blockcaps.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'B'} = 1;
		}
		if ($modules =~ 'm_blockcolor.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'c'} = 1;
		}
		if ($modules =~ 'm_noctcp.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'C'} = 1;
		}
		if ($modules =~ 'm_delayjoin.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'D'} = 1;
		}
		if ($modules =~ 'm_banexception.so') {
			$Chakora::PROTO_SETTINGS{bexcept} = 'e';
			$Chakora::PROTO_SETTINGS{cmodes}{'e'} = 2;
		}
		if ($modules =~ 'm_messageflood.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'f'} = 2;
		}
		if ($modules =~ 'm_nickflood.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'F'} = 2;
		}
		if ($modules =~ 'm_chanfilter.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'g'} = 2;
		}
		if ($modules =~ 'm_censor.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'G'} = 1;
		}
		if ($modules =~ 'm_inviteexception.so') {
			$Chakora::PROTO_SETTINGS{iexcept} = 'I';
			$Chakora::PROTO_SETTINGS{cmodes}{'I'} = 2;
		}
		if ($modules =~ 'm_joinflood.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'j'} = 2;
		}
		if ($modules =~ 'm_kicknorejoin.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'J'} = 2;
		}
		if ($modules =~ 'm_knock.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'K'} = 1;
		}
		if ($modules =~ 'm_redirect.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'L'} = 2;
		}
		if ($modules =~ 'm_services_account.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'M'} = 1;
			$Chakora::PROTO_SETTINGS{cmodes}{'R'} = 1;
		}
		if ($modules =~ 'm_nonicks.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'N'} = 1;
		}
		if ($modules =~ 'm_operchans.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'O'} = 1;
		}
		if ($modules =~ 'm_permchannels.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'P'} = 1;
		}
		if ($modules =~ 'm_nokicks.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'Q'} = 1;
		}
		if ($modules =~ 'm_stripcolor.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'S'} = 1;
		}
		if ($modules =~ 'm_nonotice.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'T'} = 1;
		}
		if ($modules =~ 'm_auditorium.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'u'} = 1;
		}
		if ($modules =~ 'm_sslmodes.so') {
			$Chakora::PROTO_SETTINGS{cmodes}{'z'} = 1;
		}
		
		my $modes = '+io';
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		send_sock( ":" . config( 'me', 'sid' ) . " BURST" );
		send_sock( ":"
			. config( 'me', 'sid' )
			. " VERSION :"
			. $Chakora::SERVICES_VERSION . " "
			. config( 'me', 'sid' ) );
		serv_add('operserv', config( 'operserv', 'user' ), config( 'operserv', 'nick' ), config( 'operserv', 'host' ), $modes, config( 'operserv', 'real' ));
		create_cmdtree("operserv");
		event_pds();
		send_sock( ":" . config( 'me', 'sid' ) . " ENDBURST" );
	}
}

# Handle UID
sub raw_uid {
    my ($raw) = @_;
    my (@rex);
    @rex = split( ' ', $raw );
    my $ruid = $rex[2];
    $Chakora::uid{$ruid}{'uid'}    = $rex[2];
    $Chakora::uid{$ruid}{'nick'}   = $rex[4];
    $Chakora::uid{$ruid}{'host'}   = $rex[5];
    $Chakora::uid{$ruid}{'mask'}   = $rex[6];
    $Chakora::uid{$ruid}{'user'}   = $rex[7];
    $Chakora::uid{$ruid}{'ip'}     = $rex[8];
    $Chakora::uid{$ruid}{'ts'}     = $rex[3];
    $Chakora::uid{$ruid}{'server'} = substr( $rex[0], 1 );
    $Chakora::uid{$ruid}{'pnick'}  = 0;
    $Chakora::uid{$ruid}{'away'}   = 0;
    my $svs = 'operserv';
    if (module_exists("global/main")) {
              $svs = 'global';
    }
    if ($Chakora::IN_DEBUG) { serv_notice($svs, $ruid, "Services are in debug mode, be careful when sending messages to services.");
    }
    event_uid( $ruid, $rex[4], $rex[7], $rex[5], $rex[6], $rex[8],
        substr( $rex[0], 1 ) );
}

# Handle PING
sub raw_ping {
    my ($raw) = @_;
    my (@rex);
    @rex = split( ' ', $raw );
    send_sock(
        ":" . svsUID("chakora::server") . " PONG " . $rex[3] . " " . $rex[2] );
}

# Handle QUIT
sub raw_quit {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $ruid = substr( $rex[0], 1 );
    my ($i);
    my $args = substr( $rex[2], 1 );
    for ( $i = 3 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    my @chns = split( ' ', $Chakora::uid{$ruid}{'chans'} );
    foreach my $chn (@chns) {
        my @members = split( ' ', $Chakora::channel{$chn}{'members'} );
        my ($newmem);
        foreach my $member (@members) {
            unless ( $member eq $ruid ) {
                $newmem .= ' ' . $member;
            }
        }
        $Chakora::channel{$chn}{'members'} = $newmem;
    }
    event_quit( $ruid, $args );
    undef $Chakora::uid{$ruid};
}

# Handle FJOIN
sub raw_fjoin {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $chan = $rex[2];
    if ( !defined( $Chakora::channel{ lc($chan) }{'ts'} ) ) {
        $Chakora::channel{ lc($chan) }{'ts'} = $rex[3];
    }

	my $bmodes = $rex[4];
	my @smodes = split(//, $bmodes);
	my ($cargs, $modes);
	my $margs = 0;
	foreach my $r (@smodes) {
		if (defined $Chakora::PROTO_SETTINGS{cmodes}{$r}) {
			if ($Chakora::PROTO_SETTINGS{cmodes}{$r} > 1) {
				$margs += $Chakora::PROTO_SETTINGS{cmodes}{$r} - 1;
				$cargs .= ' '.$r.'|'.$Chakora::PROTO_SETTINGS{cmodes}{$r};
			}
			else {
				$modes .= $r;
			}	
		}
	}
	my ($as);
	if (defined $cargs) {
		my (@sargs);
		my $calc = $margs;
		while ($calc > 0) {
			$sargs[$calc] = $rex[$calc+4];
			$calc -= 1;
		}
		my @ms = split(' ', $cargs);
		my $c = 1;
		foreach my $m (@ms) {
			my @t = split('\|', $m);
			$modes .= $t[0];
			$as .= ' '.$sargs[$c];
			$c += 1;
		}
	}
	my ($cmodes);
	if (defined $as) {
		$cmodes = $modes.$as;
	} else {
		$cmodes = $modes;
	}
	$Chakora::channel{lc($chan)}{modes} = $cmodes;

    my ( $args, $i, @users, $juser, @rjuser );
    for ( $i = $margs + 5; $i < count(@rex) ; $i++ ) { $args .= $rex[$i] . ' '; }
    @users = split( ' ', $args );
    foreach $juser (@users) {
        undef, @rjuser = split( ',', $juser );
        $Chakora::channel{ lc($chan) }{'members'} .= ' ' . $rjuser[1];
        $Chakora::uid{ $rjuser[1] }{'chans'} .= ' ' . lc($chan);
        event_join( $rjuser[1], $chan );
    }
}

# Handle FMODE
sub raw_fmode {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    
	# [IRC] :623AAAAAA FMODE #home 1284436198 +l 10
	my $chan = $rex[2];
	my $bmodes = $rex[4];
	my @smodes = split(//, $bmodes);
	my ($cargs, $modes);
	my $margs = 0;
	my $op = 0;
	my (@nomo);
	foreach my $r (@smodes) {
		if ($r eq '+') {
			$op = 1;
		}
		if ($r eq '-') {
			$op = 0;
		}
		if (defined $Chakora::PROTO_SETTINGS{cmodes}{$r} and $op) {
			if ($Chakora::PROTO_SETTINGS{cmodes}{$r} > 1) {
				$margs += $Chakora::PROTO_SETTINGS{cmodes}{$r} - 1;
				$cargs .= ' '.$r.'|'.$Chakora::PROTO_SETTINGS{cmodes}{$r};
			}
			else {
				$modes .= $r;
			}	
		}
		elsif (defined $Chakora::PROTO_SETTINGS{cmodes}{$r} and $op == 0) {
			$nomo[count(@nomo) + 1] = $r;
		}
	}
	my ($as);
	if (defined $cargs) {
		my (@sargs);
		my $calc = $margs;
		while ($calc > 0) {
			$sargs[$calc] = $rex[$calc+4];
			$calc -= 1;
		}
		my @ms = split(' ', $cargs);
		my $c = 1;
		foreach my $m (@ms) {
			my @t = split('\|', $m);
			$modes .= $t[0];
			$as .= ' '.$sargs[$c];
			$c += 1;
		}
	}
	my @curmo = split(' ', $Chakora::channel{lc($chan)}{modes});
	my ($acs);
	my $curmos = $curmo[0];
	foreach my $xc (@nomo) {
		if ($curmos =~ m/($xc)/) {
			if ($Chakora::PROTO_SETTINGS{cmodes}{$xc} > 1) {
				my @cmta = split(//, $curmos);
				my $cmtb = 0;
				my $cmtd = 1;
				foreach my $cmtc (@cmta) {
					if ($cmtc eq $xc) {
						$cmtd = 0;
					}
					elsif ($Chakora::PROTO_SETTINGS{cmodes}{$cmtc} > 1 and $cmtd != 0) {
						$cmtb += $Chakora::PROTO_SETTINGS{cmodes}{$cmtc};
					}
				}
				undef $curmo[$cmtb + 1];
			}
			$curmos =~ s/($xc)//g;
		}
		if ($modes =~ m/($xc)/) {
			if ($Chakora::PROTO_SETTINGS{cmodes}{$xc} > 1) {
				my @cmtx = split(' ', $as);
				my @cmta = split(//, $curmos);
				my $cmtb = 0;
				my $cmtd = 1;
				foreach my $cmtc (@cmta) {
					if ($cmtc eq $xc) {
						$cmtd = 0;
					}
					elsif ($Chakora::PROTO_SETTINGS{cmodes}{$cmtc} > 1 and $cmtd != 0) {
						$cmtb += $Chakora::PROTO_SETTINGS{cmodes}{$cmtc};
					}
				}
				undef $cmtx[$cmtb + 1];
				undef $as;
				for (my $i = 1; $i < count(@cmtx); $i++) { if (defined $cmtx[$i]) { $as .= ' '.$cmtx[$i]; } }
			}
			$modes =~ s/($xc)//g;
		}
	}
	if (defined $curmo[1]) {
		for (my $i = 1; $i < count(@curmo); $i++) { if (defined $curmo[$i]) { $acs .= ' '.$curmo[$i]; } }
	}
	$Chakora::channel{lc($chan)}{modes} = $curmos.$modes.$acs.$as;
}

# Handle NICK
sub raw_nick {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $ruid = substr( $rex[0], 1 );
    $Chakora::uid{$ruid}{'pnick'} = uidInfo( $ruid, 1 );
    $Chakora::uid{$ruid}{'nick'}  = $rex[2];
    $Chakora::uid{$ruid}{'ts'}    = substr( $rex[3], 1 );
    event_nick( $ruid, $rex[2] );
}

# Handle MODE
sub raw_mode {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    if ( $Chakora::uid{ $rex[2] }{'oper'} and parse_mode( $rex[3], '-', 'o' ) )
    {
        undef $Chakora::uid{ $rex[2] }{'oper'};
        event_deoper( $rex[2] );
    }
}

# Handle PART
sub raw_part {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $user = substr( $rex[0], 1 );
    my $args = 0;
    if ( $rex[3] ) {
        my $args = substr( $rex[3], 1 );
        my ($i);
        for ( $i = 4 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    }
    my @members = split( ' ', $Chakora::channel{ lc( $rex[2] ) }{'members'} );
    my ($newmem);
    foreach my $member (@members) {
        unless ( $member eq $user ) {
            $newmem .= ' ' . $member;
        }
    }
    my @chns = split( ' ', $Chakora::uid{$user}{'chans'} );
    my ($newchns);
    foreach my $chn (@chns) {
        unless ( $chn eq lc( $rex[2] ) ) {
            $newchns .= ' ' . $chn;
        }
    }
    $Chakora::uid{$user}{'chans'} = $newchns;
    $Chakora::channel{ lc( $rex[2] ) }{'members'} = $newmem;
    event_part( $user, $rex[2], $args );
}

# Handle FHOST
sub raw_fhost {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $ruid = substr( $rex[0], 1 );
    my $ohost = uidInfo($ruid, 4);
    $Chakora::uid{$ruid}{'mask'} = $rex[2];
    event_chghost($ruid, $ohost, $rex[2]);
}

# Handle SETIDENT
sub raw_setident {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $ruid = substr( $rex[0], 1 );
    my $ouser = uidInfo($ruid, 2);
    $Chakora::uid{$ruid}{'user'} = substr( $rex[2], 1 );
    event_chgident($ruid, $ouser, substr($rex[2], 1));
}

# Handle VERSION
sub raw_version {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
}

# Handle SERVER
sub raw_server {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );

    # :490 SERVER test.server password 0 491 :test server
    $Chakora::sid{ $rex[5] }{'sid'}  = $rex[5];
    $Chakora::sid{ $rex[5] }{'name'} = $rex[2];
    $Chakora::sid{ $rex[5] }{'hub'}  = substr( $rex[0], 1 );
    my $args = substr( $rex[6], 1 );
    my ($i);
    for ( $i = 7 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    $Chakora::sid{ $rex[5] }{'info'} = $args;
    event_sid( $rex[2], $args );
}

# Handle SERVER while linking
sub raw_lserver {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );

    # SERVER test.server password 0 491 :test server
    $Chakora::sid{ $rex[4] }{'sid'}  = $rex[4];
    $Chakora::sid{ $rex[4] }{'name'} = $rex[1];
    $Chakora::sid{ $rex[4] }{'hub'}  = 0;
    $Chakora::sid{config('me', 'sid')}{'hub'} = $rex[4];
    my $args = substr( $rex[5], 1 );
    my ($i);
    for ( $i = 6 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    $Chakora::sid{ $rex[4] }{'info'} = $args;
    event_sid( $rex[1], $args );
}

# Handle PRIVMSG
sub raw_privmsg {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $args = substr( $rex[3], 1 );
    my ($i);
    for ( $i = 4 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    event_privmsg( substr( $rex[0], 1 ), $rex[2], $args );
}

# Handle NOTICE
sub raw_notice {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $args = substr( $rex[3], 1 );
    my ($i);
    for ( $i = 4 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    event_notice( substr( $rex[0], 1 ), $rex[2], $args );
}

# Handle OPERTYPE
sub raw_opertype {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $user = substr( $rex[0], 1 );
    $Chakora::uid{$user}{'oper'} = 1;
    event_oper($user);
}

# Handle ERROR without a source server
sub raw_nosrcerror {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $args = substr( $rex[1], 1 );
    my $i;
    for ( $i = 2 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    error( "chakora", "[Server Error] " . $args );
}

# Handle ERROR with a source server
sub raw_error {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $args = substr( $rex[2], 1 );
    my $i;
    for ( $i = 3 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    svsflog( "chakora", "[Server Error] " . $args );
}

# Handle ENDBURST
sub raw_endburst {
    unless ($Chakora::synced) {
        foreach my $key ( sort keys %Chakora::svsuid ) {
            serv_join( $key, config( 'log', 'logchan' ) );
        }
        $Chakora::synced = 1;
        event_eos();
    }
}

# Handle SQUIT/RSQUIT
sub raw_squit {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $args = substr( $rex[3], 1 );
    my ($i);
    for ( $i = 4 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    netsplit( $rex[2], $args, substr( $rex[0], 1 ) );
}

# Handle netsplits
sub netsplit {
    my ( $server, $reason, $source ) = @_;
    event_netsplit( $server, $reason, $source );
    foreach my $key ( keys %Chakora::uid ) {
        if ( $Chakora::uid{$key}{'server'} eq $server ) {

#logchan("os", "Deleting user ".uidInfo($Chakora::uid{$key}{'uid'}, 1)." due to ".sidInfo($server, 1)." splitting from ".sidInfo($source, 1));
            undef $Chakora::uid{$key};
        }
    }
        foreach my $key (keys %Chakora::sid) {
                if ($Chakora::sid{$key}{'hub'} eq $server) {
                        foreach my $user (keys %Chakora::uid) {
                                if($Chakora::uid{$user}{'server'} eq $Chakora::sid{$key}{'sid'}) {
                                        delete $Chakora::uid{$user};
                                }
                        }
                        event_netsplit($Chakora::sid{$key}{'sid'}, "Servers hub split...", $source);
                        delete $Chakora::sid{$key};
                }
        }

        foreach my $key (keys %Chakora::sid) {
                if (!defined($Chakora::sid{$Chakora::sid{$key}{'hub'}}{'sid'})) {
                        foreach my $user (keys %Chakora::uid) {
                                if ($Chakora::uid{$user}{'server'} eq $Chakora::sid{$key}{'sid'}) {
                                        delete $Chakora::uid{$user};
                                }
                        }
                        event_netsplit($Chakora::sid{$key}{'sid'}, "Servers hub split...", $source);
                        delete $Chakora::sid{$key};
                }
        }


    undef $Chakora::sid{$server};
}

# Handle AWAY
sub raw_away {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $user = substr( $rex[0], 1 );

    # Going away: [IRC] :42XAAAAAC AWAY :bbiab
    if ( $rex[2] ) {
        my $args = substr( $rex[2], 1 );
        my ($i);
        for ( $i = 3 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
        $Chakora::uid{$user}{'away'} = 1
          ; # We don't want someone to return away 500 times and log flood --Matthew
        event_away( $user, $args );
    }
    else {

        # Returning [IRC] :42XAAAAAC AWAY
        if ( $Chakora::uid{$user}{'away'} ) {
            event_back($user);
            $Chakora::uid{$user}{'away'} = 0;
        }
    }
}

# Handle KILL
sub raw_kill {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $user   = substr( $rex[0], 1 );
    my $target = $rex[2];
    my $args   = substr( $rex[3], 1 );
    my ($i);
    for ( $i = 4 ; $i < count(@rex) ; $i++ ) { $args .= ' ' . $rex[$i]; }
    my @chns = split( ' ', $Chakora::uid{$user}{'chans'} );

    foreach my $chn (@chns) {
        my @members = split( ' ', $Chakora::channel{$chn}{'members'} );
        my ($newmem);
        foreach my $member (@members) {
            unless ( $member eq $user ) {
                $newmem .= ' ' . $member;
            }
        }
        $Chakora::channel{$chn}{'members'} = $newmem;
    }
    event_kill( $user, $target, "(" . $args . ")" );
	if (defined $Chakora::uid{$user}) {
		undef $Chakora::uid{$user};
	}
    if ($target eq svsUID("operserv")) {
		serv_del("operserv");
		my $modes = '+io';
		if (defined $Chakora::PROTO_SETTINGS{god}) { $modes .= $Chakora::PROTO_SETTINGS{god}; }
		serv_add('operserv', config( 'operserv', 'user' ), config( 'operserv', 'nick' ), config( 'operserv', 'host' ), $modes, config( 'operserv', 'real' ));
	}
}

# Handle SVSNICK
sub raw_svsnick {
    my ($raw) = @_;
    my @rex = split( ' ', $raw );
    my $i = 0;
    foreach my $key ( keys %Chakora::svsuid ) {
        if ( $rex[2] eq $Chakora::svsuid{$key} ) {
            $Chakora::svsnick{ lc($key) } = $rex[3];
            $i = 1;
        }
    }
    if ( $i == 0 ) {
        $Chakora::uid{ $rex[2] }{'nick'} = $rex[3];
    }
}

# Handle TOPIC
sub raw_topic {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $user = substr($rex[0], 1);
        my $chan = $rex[2];
        my $args = substr($rex[3], 1);
        my ($i);
        for ($i = 4; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        event_topic($user, $chan, $args);
	if (is_registered(2, $chan)) {
        	if (metadata(2, $chan, "option:topiclock")) {
                	if (has_flag(uidInfo($user, 1), $chan, "t")) {
                                metadata_add(2, $chan, "data:topic", $args);
                        }
                }
                else {
                        metadata_add(2, $chan, "data:topic", $args);
                }
        }
}

# Handle FTOPIC
sub raw_ftopic {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        # [IRC] :921 FTOPIC #services 1284442741 starcoder :.
        my $nick = $rex[4];
        my $chan = $rex[2];
        my $args = substr($rex[5], 1);
        my ($i);
        for ($i = 6; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
        event_stopic($nick, $chan, $args);
        if (is_registered(2, $chan)) {
                metadata_add(2, $chan, "data:topic", $args);
        }
}

# Handle KICK
sub raw_kick {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	my $chan = $rex[2];
	my $target = $rex[3];
	my $args = substr($rex[4], 1);
	my ($i);
	for ($i = 5; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
    my @members = split( ' ', $Chakora::channel{ lc( $chan ) }{'members'} );
    my ($newmem);
    foreach my $member (@members) {
        unless ( $member eq $target ) {
            $newmem .= ' ' . $member;
        }
    }
    my @chns = split( ' ', $Chakora::uid{$target}{'chans'} );
    my ($newchns);
    foreach my $chn (@chns) {
        unless ( $chn eq lc( $chan ) ) {
            $newchns .= ' ' . $chn;
        }
    }
    $Chakora::uid{$user}{'chans'} = $newchns;
    $Chakora::channel{ lc( $chan ) }{'members'} = $newmem;
	event_kick($user, $chan, $target, $args);
}

# Handle MOTD
sub raw_motd {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $user = substr($rex[0], 1);
        # [IRC] :48XAAAAAB MOTD dot.technoirc.com
        if ($rex[2] eq config('me', 'name')) {
                my $net = config('network', 'name');
                my $ed = config('nickserv', 'enforce_delay');
                my $name = config('me', 'name');
                send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 375 ".uidInfo($user, 1)." :- ".config('me', 'name')." Message of the Day -");
                send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 372 ".uidInfo($user, 1)." :-");
                if ( -e "$Chakora::ROOT_SRC/../etc/chakora.motd" ) {
                        open FILE, "<$Chakora::ROOT_SRC/../etc/chakora.motd";
                        my @lines = <FILE>;
                        foreach my $line (@lines) {
                                chomp($line);
                                $line =~ s/%NAME%/$name/g;
                                $line =~ s/%VERSION%/$Chakora::SERVICES_VERSION/g;
                                $line =~ s/%NETWORK%/$net/g;
                                $line =~ s/%EDELAY%/$ed/g;
                                send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 372 ".uidInfo($user, 1)." :- ".$line);
                        }
                }
                else {
                        send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 372 ".uidInfo($user, 1)." :- Chakora MOTD file missing");
                }
                send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 372 ".uidInfo($user, 1)." :-");
                send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 376 ".uidInfo($user, 1)." :End of the message of the day");
        }
}

# Handle ADMIN
sub raw_admin {
        my ($raw) = @_;
        my @rex = split(' ', $raw);
        my $user = substr($rex[0], 1);
        # [IRC] :48XAAAAAB ADMIN dot.technoirc.com
        if ($rex[2] eq config('me', 'name')) {
                send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 256 ".uidInfo($user, 1)." :Administrative info about ".config('me', 'name'));
                send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 257 ".uidInfo($user, 1)." :".config('network', 'admin')." - Services Administrator");
                send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 258 ".uidInfo($user, 1)." :".$Chakora::SERVICES_VERSION." for ".config('network', 'name'));
                send_sock(":".svsUID('chakora::server')." PUSH ".$user." ::".config('me', 'name')." 259 ".uidInfo($user, 1)." :".config('services', 'email'));
        }
}

# Handle METADATA
sub raw_metadata {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $server = substr($rex[0], 1);
	if ($server eq sidInfo(config('me', 'sid'), 4) and $rex[2] eq '*' and $rex[3] eq 'modules') {
		my $opera = substr($rex[4], 1, 1);
		my $mod = substr($rex[4], 2);
		
		if ($mod eq 'm_servprotect.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{god};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{god} = 'k';
			}
		}
		elsif ($mod eq 'm_allowinvite.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'A'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'A'} = 1;
			}
		}
		elsif ($mod eq 'm_blockcaps.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'B'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'B'} = 1;
			}
		}
		elsif ($mod eq 'm_blockcolor.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'c'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'c'} = 1;
			}
		}
		elsif ($mod eq 'm_noctcp.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'C'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'C'} = 1;
			}
		}
		elsif ($mod eq 'm_delayjoin.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'D'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'D'} = 1;
			}
		}
		elsif ($mod eq 'm_banexception.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{bexcept};
				delete $Chakora::PROTO_SETTINGS{cmodes}{'e'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{bexcept} = 'e';
				$Chakora::PROTO_SETTINGS{cmodes}{'e'} = 2;
			}
		}
		elsif ($mod eq 'm_messageflood.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'f'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'f'} = 2;
			}
		}
		elsif ($mod eq 'm_nickflood.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'F'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'F'} = 2;
			}
		}
		elsif ($mod eq 'm_chanfilter.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'g'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'g'} = 2;
			}
		}
		elsif ($mod eq 'm_censor.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'G'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'G'} = 1;
			}
		}
		elsif ($mod eq 'm_inviteexception.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{iexcept};
				delete $Chakora::PROTO_SETTINGS{cmodes}{'I'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{iexcept} = 'I';
				$Chakora::PROTO_SETTINGS{cmodes}{'I'} = 2;
			}
		}
		elsif ($mod eq 'm_joinflood.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'j'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'j'} = 2;
			}
		}
		elsif ($mod eq 'm_kicknorejoin.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'J'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'J'} = 2;
			}
		}
		elsif ($mod eq 'm_knock.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'K'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'K'} = 1;
			}
		}
		elsif ($mod eq 'm_redirect.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'L'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'L'} = 2;
			}
		}
		elsif ($mod eq 'm_services_account.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'M'};
				delete $Chakora::PROTO_SETTINGS{cmodes}{'R'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'M'} = 1;
				$Chakora::PROTO_SETTINGS{cmodes}{'R'} = 1;
			}
		}
		elsif ($mod eq 'm_nonicks.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'N'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'N'} = 1;
			}
		}
		elsif ($mod eq 'm_operchans.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'O'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'O'} = 1;
			}
		}
		elsif ($mod eq 'm_permchannels.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'P'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'P'} = 1;
			}
		}
		elsif ($mod eq 'm_nokicks.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'Q'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'Q'} = 1;
			}
		}
		elsif ($mod eq 'm_stripcolor.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'S'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'S'} = 1;
			}
		}
		elsif ($mod eq 'm_nonotice.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'T'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'T'} = 1;
			}
		}
		elsif ($mod eq 'm_auditorium.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'u'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'u'} = 1;
			}
		}
		elsif ($mod eq 'm_sslmodes.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{cmodes}{'z'};
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{cmodes}{'z'} = 1;
			}
		}
		elsif ($mod eq 'm_chanprotect.so') {
			if ($opera eq '-') {
				delete $Chakora::PROTO_SETTINGS{owner};
				delete $Chakora::PROTO_SETTINGS{admin};
				if (flag_exists("Q")) {
					flaglist_del("Q");
				}
				if (flag_exists("A")) {
					flaglist_del("A");
				}
				if (module_exists("chanserv/owner")) {
					logchan('operserv', "\002!!!\002 Unloading module \002chanserv/owner\002 as \002m_chanprotect.so\002 no longer exists!");
					module_void("chanserv/owner");
				}
				if (module_exists("chanserv/protect")) {
					logchan('operserv', "\002!!!\002 Unloading module \002chanserv/protect\002 as \002m_chanprotect.so\002 no longer exists!");
					module_void("chanserv/protect");
				}	
			}
			elsif ($opera eq '+') {
				$Chakora::PROTO_SETTINGS{owner} = 'q';
				$Chakora::PROTO_SETTINGS{admin} = 'a';
				if (!flag_exists("Q")) {
					flaglist_add("Q", "Auto owner.");
				}
				if (!flag_exists("A")) {
					flaglist_add("A", "Auto protect.");
				}
			}
		}
		
		if ($opera eq '-') {
			$Chakora::PROTO_SETTINGS{modules} =~ s/($mod)//g;
		}
		elsif ($opera eq '+') {
			$Chakora::PROTO_SETTINGS{modules} .= ','.$mod;
		}
	}
}

1;

