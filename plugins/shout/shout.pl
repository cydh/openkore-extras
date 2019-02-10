# Plugin to 'shout' using megaphone [Cydh]
package shout;

use Plugins;
use Log qw(warning message error);
use Globals;

use constant {
	PLUGINNAME  => "shout",
	PLUGINDESC  => "Shout a text after using item as Megaphones",
};

my $megaphone_consumed;
my $megaphone_text;
# Items identified as Megaphones
# or use shout_useItem in config.txt file
my @megaphones = (12221);

# Plugin
Plugins::register(PLUGINNAME, PLUGINDESC, \&unload);

my $chooks = Commands::register(
	['shout', "Send 'talk text' after using Megaphone", \&cmdShoutText],
	['shout2', "Send 'talk text' after using Megaphone automatically", \&cmdShoutText],
);

my $hooks = Plugins::addHooks(
	['packet_useitem', \&onItemRemoved],
);

# Plugin unload
sub unload {
	message "Unloading ".PLUGINNAME." - ".PLUGINDESC.".\n", "info";
	$megaphone_consumed = 0;
	undef $megaphone_text;
	Plugins::delHooks($hooks);
	Commands::unregister($chooks);
}

sub onItemRemoved {
	my ($self, $args) = @_;
	my $item = $args->{item};
	
	if ($ID ne $accountID) {
		return;
	}

	if (($config{shout_useItem} ne "" && $item->{nameID} == $config{shout_useItem}) || grep { $item->{nameID} eq $_ } @megaphones) {
		if ($megaphone_text ne "") {
			$messageSender->sendTalkText(undef, $megaphone_text);
			$megaphone_consumed = 0;
			undef $megaphone_text;
			return;
		} else {
			$megaphone_consumed = 1;
			undef $megaphone_text;
			message "Item identified as Megaphone is consumed. Use shout <type the message here> to continue.\n", "info";
		}
	}
	return 0;
}

# shout <message>  => After self consumption
# shout2 <message> => Delayed shout, use the item automatically
sub cmdShoutText {
	my ($command, $arg1) = @_;

	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", $command);
		return 1;
	}

	if ($arg1 eq "") {
		error "You need to use item [Megaphone] before using this command.\nUsage: $command <type the message here>\n";
		return 1;
	}
	message "Text to shout: ".$arg1."\n";
	if ($command eq "shout2") { # Consume it then shout
		my $item;
		if (defined $config{shout_useItem}) {
			$item = $char->inventory->getByNameID($config{shout_useItem});
		} else {
			foreach my $id (@megaphones) {
				$item = $char->inventory->getByNameID($id);
				last if ($item);
			}
		}
		if (!$item) {
			error "You don't have megaphone items\n";
			return 1;
		}
		my $conitem = Actor::Item::get($item->{name});
		if ($conitem) {
			$megaphone_consumed = 1;
			$megaphone_text = $arg1;
			$conitem->use;
		} else {
			error "Item ".$item->{name}." cannot be consumed\n";
		}
		return 0;
	}

	if ($megaphone_consumed != 1) {
		error "You need to use item [Megaphone] before using this command.\nUsage: shout <type the message here>\n";
	} else {
		$megaphone_consumed = 0;
		undef $megaphone_text;
		$messageSender->sendTalkText(undef, $arg1);
	}
	return 0;
}

1;
