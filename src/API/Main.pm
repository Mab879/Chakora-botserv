# api/main by The Chakora Project. Core of Chakora's module API.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

sub module_init {
    my ($name, $author, $version, $init_handler, $void_handler, $ircd) = @_;
    print("[MODULES] Attempting to load module: ".$name." v".$version." by ".$author."\n");
    svsflog("chakora", "[MODULES] Attempting to load module: ".$name." v".$version." by ".$author);
    $ircd = lc($ircd);
    if ($ircd ne 'all' and $ircd ne lc(config('server', 'ircd'))) {
        print("[MODULES] Module ".$name." refusing to load: Protocol not supported.\n");
        svsflog("chakora", "[MODULES] Module ".$name." refusing to load: Protocol not supported.");
        return "MODLOAD_BADPROTO";
    } else {
        eval
        {
            &{ $init_handler }();
            print("[MODULES] ".$name.": Module successfully loaded.\n");
            svsflog("chakora", "[MODULES] ".$name.": Module successfully loaded.");
            $MODULE{$name}{name} = $name;
            $MODULE{$name}{author} = $author;
            $MODULE{$name}{version} = $version;
            $MODULE{$name}{void} = $void_handler;
            return "MODLOAD_SUCCESS";
            1;	
        } or print("[MODULES] ".$name.": Module failed to load. $@\n") and svsflog("chakora", "[MODULES] ".$name.": Module failed to load.") and return "MODLOAD_FAIL";
    }
}

sub module_exists {
	my ($module) = @_;
	my $exists = 0;
	foreach my $mod (keys %MODULE) {
		if ($mod eq $module) {
			$exists = 1;
		}
	}
	return $exists;
}

sub module_void {
	my ($module) = @_;
	svsflog("chakora", "[MODULES] ".$module.": Attempting to unload module. . .");
	if (defined($MODULE{$module})) {
		my $void_handler = $MODULE{$module}{void};
		eval
        {
            &{ $void_handler }();
            delete_sub $void_handler;
            print("[MODULES] ".$module.": Module successfully unloaded.\n");
            svsflog("chakora", "[MODULES] ".$module.": Module successfully unloaded.");
			delete $MODULE{$module};
            return "MODUNLOAD_SUCCESS";
			1;	
        } or print("[MODULES] ".$module.": Module failed to unload.\n") and svsflog("chakora", "[MODULES] ".$module.": Module failed to unload.") and return "MODUNLOAD_FAIL";
	} else {
		print("[MODULES] ".$module.": Module failed to unload. No such module?\n");
		svsflog("chakora", "[MODULES] ".$module.": Module failed to unload. No such module?");
		return "MODUNLOAD_NOEXIST";
	}	
}

sub cmd_add {
    my ($name, $shelp, $fhelp, $handler) = @_;
    my @rname = split('/', $name);
    $COMMANDS{$rname[0]}{$rname[1]}{name} = $name;
    $COMMANDS{$rname[0]}{$rname[1]}{handler} = $handler;
    $HELP{$name}{shelp} = $shelp;
    $HELP{$name}{fhelp} = $fhelp;
}

sub cmd_del {
	my ($cmd) = @_;
	my @scmd = split('/', $cmd);
	undef $COMMANDS{$scmd[0]}{$scmd[1]};
	undef $HELP{$cmd};
}
