#!/usr/bin/perl
use File::Data;
use Term::Prompt;

if (-d 'etc') { 
`mkdir etc.old`;
`cp -R etc/* etc.old/`;
`rm -rf etc/`;
print('Removing etc/ to prevent conflicts, contents copied into etc.old/'."\n");
}
else {
`mkdir etc`;
my $file = './etc/chakora.conf';
`touch $file`;
my $conf = File::Data->new($file);

$conf->prepend("# Chakora configuration file\n");
$conf->append("\n\nme {\n");

my $name = prompt('x', 'What is the linkname for this server?', 'eg. some.server.tld', '');
print("\n");
$conf->append("\tname = ".$name."\n");

my $info = prompt('x', 'What should be the description for this server?', '', 'Chakora IRC Services');
print("\n");
$conf->append("\t".'info = "'.$info."\"\n");

my $sid = prompt('x', 'What should be the SID for this server?', '', '34R');
print("\n");
$conf->append("\tsid = ".$sid."\n");

$conf->append("}\n\nserver {\n");

my $ircd = prompt('a', 'What is the IRCd of the remote server?', 'inspircd or charybdis', 'inspircd');
print("\n");
$conf->append("\tircd = ".$ircd."\n");

my $host = prompt('x', 'What is the hostname of the remote server?', 'eg. some.server.tld', '');
print("\n");
$conf->append("\thost = ".$host."\n");

my $vhost = prompt('x', 'What should be the vHost (ip to bind to) of this server?', 'Mainly for multi-homed hosts.', '0.0.0.0');
print("\n");
$conf->append("\tvhost = ".$vhost."\n");

my $port = prompt('n', 'What port shall we connect on?', '', '7000');
print("\n");
$conf->append("\tport = ".$port."\n");

my $pass = prompt('x', 'What is the linkpass for this server?', '', 'linkage');
print("\n");
$conf->append("\tpassword = ".$pass."\n");

$conf->append("}\n\nnetwork {\n");

my $name = prompt('x', 'What is the name of the network we are linking to?', '', 'freenode');
print("\n");
$conf->append("\t".'name = "'.$name."\"\n");

my $admin = prompt('x', 'Who is the admin of these services?', '', 'starcoder');
print("\n");
$conf->append("\t".'admin = "'.$admin."\"\n");

$conf->append("}\n\nlog {\n\n");

$conf->append("\n");
$conf->append("\t# Logging flags:\n");
$conf->append("\t# 	debug - Log all debug\n");
$conf->append("\t# 	commands - Log all command usuage\n");
$conf->append("\t# 	error - Log critical errors\n");
$conf->append("\t# 	set - Log all SET commands for an user/channel\n");
$conf->append("\t#	register - Log all registrations\n");
$conf->append("\t#	soper - Log all service oper usuage\n");
$conf->append("\t#	request - Logs anything thats requested (mainly vHosts)\n");
$conf->append("\n");
#$conf->append("\t# Logs registrations and use of the SET command.\n");
#$conf->append("\tlogfile = \"var/user.log register set\"\n");
#$conf->append("\n");
#$conf->append("\t# Logs all command usuage.\n");
#$conf->append("\tlogfile = \"var/cmds.log commands\"\n");
#$conf->append("\n");
$conf->append("\t# Log channel.\n");
$conf->append("\tlogchan = \"#services\"\n");
$conf->append("\tlogchanf = \"error soper request register\"\n");

$conf->append("}\n\nservices {\n");
my $email = prompt('x', 'What is the admin email?', '', '');
$conf->append("email = \'".$email."\'\n");
$conf->append("autoload = \"\"\n}\n\n");

my $svs = 'ChanServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Channel Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\thost = ".$host."\n");
$conf->append("\treal = \"".$real."\"\n}\n\n");

my $svs = 'NickServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Nickname Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\thost = ".$host."\n");
$conf->append("\treal = \"".$real."\"\n}\n\n");

my $svs = 'OperServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Oper Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\thost = ".$host."\n");
$conf->append("\treal = \"".$real."\"\n}\n\n");

my $svs = 'HostServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "vHost Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\thost = ".$host."\n");
$conf->append("\treal = \"".$real."\"\n}\n\n");

my $svs = 'MemoServ';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Memo Services");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\thost = ".$host."\n");
$conf->append("\treal = \"".$real."\"\n}\n\n");

my $svs = 'Global';
$conf->append(lc($svs)." {\n");

my $nick = prompt('x', 'What nick should '.$svs.' use?', '', $svs);
print("\n");

my $user = prompt('x', 'What username should '.$svs.' use?', '', $svs);
print("\n");

my $host = prompt('x', 'What host should '.$svs.' use?', '', $name."/Services/".$svs);
print("\n");

my $real = prompt('x', 'What realname should '.$svs.' use?', '', "Global Noticer");
print("\n");

$conf->append("\tnick = ".$nick."\n");
$conf->append("\tuser = ".$user."\n");
$conf->append("\thost = ".$host."\n");
$conf->append("\treal = \"".$real."\"\n}\n\n");

my $sras = prompt('x', 'Who should have SRA Status?', 'Separate nicks with spaces.', "starcoder MattB");
print("\n");
$conf->append("operators {\n\tsra = \"".$sras."\"\n}\n");

$conf->append("xmlrpc {\n");
my $xmlrpc_use = prompt('y', 'Do you want to use the XML-RPC', 'Good for web services and remote control for services', 'y');
print ("\n");
$conf->append("\tuse = ".$xmlrpc_use."\n");
if ($xmlrpc_use) {
my $xmlrpc_host = prompt('x', 'What IP should the XML-RPC bind to?', 'Mainly for multi-homed hosts.', '0.0.0.0');
print("\n");
my $xmlrpc_port = prompt('x', 'What port should the XML-RPC bind to?', '', '8080');
print("\n");
$conf->append("\thost = ".$xmlrpc_host."\n");
$conf->append("\tport = ".$xmlrpc_port."\n");
}
else { print("\nSince you didn't want the XML-RPC enabled, we didn't include the config options for it, if you want XML-RPC enabled later, rerun this setup wizard"); }
$conf->append("\n# End configuration file");


print("\nAll done! Please configure the logging and autoload portion of the config in\netc/chakora.conf then run ./bin/chakora to start her up!\n");
}
