# api/main by The Chakora Project. Core of Chakora's module API.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

sub module_init {
    my ( $name, $author, $version, $init_handler, $void_handler, $ircd ) = @_;
    print(  "[MODULES] Attempting to load module: " 
          . $name . " v" 
          . $version . " by "
          . $author
          . "\n" );
    svsflog( "chakora",
            "[MODULES] Attempting to load module: " 
          . $name . " v" 
          . $version . " by "
          . $author );
    $ircd = lc($ircd);
    if ( $ircd ne 'all' and $ircd ne lc( config( 'server', 'ircd' ) ) ) {
        print(  "[MODULES] Module " 
              . $name
              . " refusing to load: Protocol not supported.\n" );
        svsflog( "chakora",
                "[MODULES] Module " 
              . $name
              . " refusing to load: Protocol not supported." );
        return "MODLOAD_BADPROTO";
    }
    else {
        eval {
            &{$init_handler}();
            print( "[MODULES] " . $name . ": Module successfully loaded.\n" );
            svsflog( "chakora",
                "[MODULES] " . $name . ": Module successfully loaded." );
            $Chakora::MODULE{$name}{name}    = $name;
            $Chakora::MODULE{$name}{author}  = $author;
            $Chakora::MODULE{$name}{version} = $version;
            $Chakora::MODULE{$name}{void}    = $void_handler;
            return "MODLOAD_SUCCESS";
            1;
        }
          or print( "[MODULES] " . $name . ": Module failed to load. $@\n" )
          and svsflog( "chakora",
            "[MODULES] " . $name . ": Module failed to load." )
          and return "MODLOAD_FAIL";
    }
}

sub module_exists {
    my ($module) = @_;
    my $exists = 0;
    foreach my $mod ( keys %Chakora::MODULE ) {
        if ( $mod eq $module ) {
            $exists = 1;
        }
    }
    return $exists;
}

sub module_void {
    my ($module) = @_;
    svsflog( "chakora",
        "[MODULES] " . $module . ": Attempting to unload module. . ." );
    if ( defined( $Chakora::MODULE{$module} ) ) {
        my $void_handler = $Chakora::MODULE{$module}{void};
        eval {
            &{$void_handler}();
            delete_sub $void_handler;
            print(
                "[MODULES] " . $module . ": Module successfully unloaded.\n" );
            svsflog( "chakora",
                "[MODULES] " . $module . ": Module successfully unloaded." );
            delete $Chakora::MODULE{$module};
            return "MODUNLOAD_SUCCESS";
            1;
        }
          or print( "[MODULES] " . $module . ": Module failed to unload.\n" )
          and svsflog( "chakora",
            "[MODULES] " . $module . ": Module failed to unload." )
          and return "MODUNLOAD_FAIL";
    }
    else {
        print(  "[MODULES] " 
              . $module
              . ": Module failed to unload. No such module?\n" );
        svsflog( "chakora",
                "[MODULES] " 
              . $module
              . ": Module failed to unload. No such module?" );
        return "MODUNLOAD_NOEXIST";
    }
}

sub cmd_add {
    my ( $name, $shelp, $fhelp, $handler ) = @_;
    my @rname = split( '/', $name );
    $Chakora::COMMANDS{ $rname[0] }{ $rname[1] }{name}    = $name;
    $Chakora::COMMANDS{ $rname[0] }{ $rname[1] }{handler} = $handler;
    $Chakora::HELP{$name}{shelp}                          = $shelp;
    $Chakora::HELP{$name}{fhelp}                          = $fhelp;
}

sub cmd_del {
    my ($cmd) = @_;
    my @scmd = split( '/', $cmd );
    undef $Chakora::COMMANDS{ $scmd[0] }{ $scmd[1] };
    undef $Chakora::HELP{$cmd};
}

sub flaglist_add {
	my ($flag, $description) = @_;
	if (!defined($Chakora::FLAGS{$flag}{name})) {
		$Chakora::FLAGS{$flag}{name} = $flag;
		$Chakora::FLAGS{$flag}{description} = $description;
	}
}

sub create_core_flags {
        if (defined $Chakora::PROTO_SETTINGS{owner}) {
		flaglist_add("Q", "Auto-owner");
        }
        if (defined $Chakora::PROTO_SETTINGS{admin}) {
	 	flaglist_add("A", "Auto-protect");
        }
        if (defined $Chakora::PROTO_SETTINGS{halfop}) {
                flaglist_add("H", "Auto-halfop");
        }

	flaglist_add("F", "Channel founder");
	flaglist_add("s", "Allows the use of SET");
	flaglist_add("O", "Auto-op");
	flaglist_add("b", "Auto kickban");
	flaglist_add("t", "Allows the use of TOPIC commands");
	flaglist_add("V", "Auto-voice");
	flaglist_add("k", "Allows the use of the KICK,BAN,and KICKBAN commands");
	flaglist_add("m", "Allows editing the access list");
}

sub flaglist_del {
	my ($flag) = @_;
	if (defined($Chakora::FLAGS{$flag})) {
		delete $Chakora::FLAGS{$flag} and return 1 or return 0;
	}
	else {
		return 0;
	}
}

sub flag_exists {
	my ($flag) = @_;
	my $return;
	foreach my $key (keys %Chakora::FLAGS) {
		if ($Chakora::FLAGS{$key}{name} eq $flag) {
			$return = 1;
		}
	}
	return $return;
}
		
sub create_cmdtree {
    my ($service) = @_;
    $service = lc($service);
    $Chakora::CMDTREE{$service} = 1;
}

sub delete_cmdtree {
    my ($service) = @_;
    $service = lc($service);
    delete $Chakora::CMDTREE{$service};
}

sub metadata_add {
    my ( $type, $loc, $name, $value ) = @_;

    # Metadata for an account.
    if ( $type == 1 ) {
        metadata_del( 1, $loc, $name );
        $Chakora::DBADLAST += 1;
        $Chakora::DB_accdata{$Chakora::DBADLAST}{name}    = lc($name);
        $Chakora::DB_accdata{$Chakora::DBADLAST}{account} = lc($loc);
        $Chakora::DB_accdata{$Chakora::DBADLAST}{value}   = $value;
    }

    # Metadata for a channel.
    elsif ( $type == 2 ) {
        metadata_del( 2, $loc, $name );
        $Chakora::DBCDLAST += 1;
        $Chakora::DB_chandata{$Chakora::DBCDLAST}{name}  = lc($name);
        $Chakora::DB_chandata{$Chakora::DBCDLAST}{chan}  = lc($loc);
        $Chakora::DB_chandata{$Chakora::DBCDLAST}{value} = $value;
    }
}

sub metadata_del {
    my ( $type, $loc, $name ) = @_;

    # Metadata for an account.
    if ( $type == 1 ) {
        foreach my $key ( keys %Chakora::DB_accdata ) {
            if ( lc( $Chakora::DB_accdata{$key}{name} ) eq lc($name) ) {
                if ( lc( $Chakora::DB_accdata{$key}{account} ) eq lc($loc) ) {
                    delete $Chakora::DB_accdata{$key};
                }
            }
        }
    }

    # Metadata for a channel.
    elsif ( $type == 2 ) {
        foreach my $key ( keys %Chakora::DB_chandata ) {
            if ( lc( $Chakora::DB_chandata{$key}{name} ) eq lc($name) ) {
                if ( lc( $Chakora::DB_chandata{$key}{chan} ) eq lc($loc) ) {
                    delete $Chakora::DB_chandata{$key};
                }
            }
        }
    }
}

sub metadata {
    my ( $type, $loc, $name ) = @_;

    # Metadata for an account.
    if ( $type == 1 ) {
        foreach my $key ( keys %Chakora::DB_accdata ) {
            if ( lc( $Chakora::DB_accdata{$key}{name} ) eq lc($name) ) {
                if ( lc( $Chakora::DB_accdata{$key}{account} ) eq lc($loc) ) {
                    return $Chakora::DB_accdata{$key}{value};
                }
            }
        }
        return 0;
    }

    # Metadata for a channel.
    elsif ( $type == 2 ) {
        foreach my $key ( keys %Chakora::DB_chandata ) {
            if ( lc( $Chakora::DB_chandata{$key}{name} ) eq lc($name) ) {
                if ( lc( $Chakora::DB_chandata{$key}{chan} ) eq lc($loc) ) {
                    return $Chakora::DB_chandata{$key}{value};
                }
            }
        }
        return 0;
    }
    return 0;
}

sub timer_add {
    my ( $name, $ttime, $handler ) = @_;
    $Chakora::TIMER{ lc($name) }{name}    = $name;
    $Chakora::TIMER{ lc($name) }{ttime}   = $ttime;
    $Chakora::TIMER{ lc($name) }{handler} = $handler;
}

sub timer_del {
    my ($name) = @_;
    delete $Chakora::TIMER{ lc($name) };
}

1;
