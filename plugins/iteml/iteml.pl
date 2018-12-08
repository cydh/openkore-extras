#############################################################################
# Just simply ITEML generator
# @author https://github.com/cydh/
#
# This source code is licensed under the
# GNU General Public License, Version 3.
# See http://www.gnu.org/licenses/gpl.html
#############################################################################
package iteml;

use Plugins;
use Log qw(message error);
use Globals;
use Misc qw(sendMessage itemName itemNameToID containsItemNameToIDList);

use constant {
    PLUGINNAME  => "iteml",
    PLUGINDESC  => "just create some numer or string into <ITEML></ITEML> message",
};

#my @block_items = qw(22314 12360 23187 23188 23189 542 543 7912 11060);
my @block_items = qw();

# Plugin
Plugins::register(PLUGINNAME, PLUGINDESC, \&unload);

my $chooks = Commands::register(
    ['makeiteml', "Create <ITEML></ITEML> message", \&commandIteml],
    ['fmakeiteml', "Create <ITEML></ITEML> message", \&commandIteml],
);

# Plugin unload
sub unload {
    message "Unloading ".PLUGINNAME." - ".PLUGINDESC."\n", "info";
}

# makeiteml <itemid> <pm|c|g|p> [<target>]
sub commandIteml {
    my ($cmd, $params) = @_;
    my $force = 1 if ($cmd eq "fmakeiteml"); #force mode will ignore if the item exists in $items_lut or not
    my ($id, $type, @target, $target, $msg);

    # Eg: makeiteml 1201
    # Result: <Knife [3]>
    if ($params =~ /^\d+/) {
        ($id, $type, @target) = split(/\s+/, $params);
        $target = join(' ', @target);
    # Eg: makeiteml "knife"
    # Result: <Knife [3]>
    # Eg: makeiteml "knife" PlayerName
    # Eg: makeiteml 1201 PlayerName
    # Result by PM to PlayerName: <Knife [3]>
    } elsif ($params =~ /^"([^"]*)"([ ]*)(.*)/) {
        $id = $1;
        ($type, @target) = split(/\s+/, $3);
        $target = join(' ', @target);
    } else {
        error "Usage: ".$cmd." <itemid> <pm|c|g|p> [<target>]\nor: ".$cmd." \"<item name>\" <pm|c|g|p> [<target>]\n";
        return 1;
    }

    if (!defined $id || !$id) {
        error "Usage: ".$cmd." <itemid> <pm|c|g|p> [<target>]\nor: ".$cmd." \"<item name>\" <pm|c|g|p> [<target>]\n";
        return 0;
    }

    if (!defined $type || ($type ne "pm" && $type ne "c" && $type ne "g" && $type ne "p")) {
        $type = "d"; # for self, only show the result as console message
    }

    if (!($id =~ /^(\d+)$/)) { # Change item string to ID
        my $itemid = itemNameToID($id);
        my @item_list = containsItemNameToIDList($id);
        message "".$cmd.": Found similar:".(join(',',@item_list))."\n", "info";
        if (!$itemid) { # Nothing found
            if ($type ne "d") {
                sendMessage($messageSender, $type, "Item $id is not found in item list", $target);
            }
            return 1;
        }
        $id = $itemid;
    }

    my $id62 = toBase62($id);
    $msg = "".$id.": <ITEML>000001".$id62."&00(00</ITEML>";
    if (!$force && !defined $items_lut{$id}) { #invalid item
        message "".$cmd.": $id is not found in item list. ITEML: $msg\n", "info";
        $msg = "$id is not found";
    } elsif (!$force && (grep { $id eq $_ } @block_items)) {
        message "".$cmd.": $id is not found in item list. ITEML: $msg\n", "info";
        $msg = "Cannot display the requested item";
    } else {
        message "".$cmd.": $id -> $msg\n", "info";
    }
    if (!defined $type || $type ne "d") {
        sendMessage($messageSender, $type, $msg, $target);
    }
    return 1;
}

# Taken from https://gist.github.com/lututui/32d5304a16c9ea7ff947ce5f652bbb70
# Thanks to lututui
my @dictionary = qw(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
my %map = map { $dictionary[$_] => $_ } 0..$#dictionary;

sub toBase62 {
    my ($k) = @_;
    my @result;

    return "0" if ($k == 0);

    while ($k != 0) {
        use integer;
        unshift (@result, $dictionary[$k % 62]);
        $k /= 62;
    }

    return join "", @result;
}

1;
