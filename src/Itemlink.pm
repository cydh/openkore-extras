##
# Solve message with itemlink
#
# Pre-requisite: https://github.com/OpenKore/openkore/pull/2541 for fromBase62
#
# Usage:
# use Itemlink;
# $message = "... <ITEML>000co11rK&8M(16d(00(00(00</ITEML> ...";
# $itemlink = new Itemlink($message);
# message $itemlink->getMessage()."\n";
package Itemlink;

use strict;
use Misc qw(itemName itemNameSimple fromBase62);

##
# Itemlink->new("raw message sent by server");
# 
sub new {
	my $class = shift;
	my ($raw_message, $external_url) = @_;
	my %self;

    $self{raw_message} = $raw_message;
    $self{message} = $raw_message;
    $self{items} = ();

    my $self = bless \%self, $class;
    if ($raw_message =~ /<ITEML>([a-zA-Z0-9\%\&\(\,\+\*]*)<\/ITEML>/) {
        $self{message} =~ s/<ITEML>([a-zA-Z0-9\%\&\(\,\+\*]*)<\/ITEML>/$self->solveItemLink($1)/eg;
    }
    return $self;
}

sub solveItemLink {
	my ($self, $itemlstr) = @_;

	# Item ID as minimum requirement
	if (!($itemlstr =~ /^([\d\w]+)(.*)/)) {
		return $itemlstr;
	}

	my ($itemstr, $infostr) = ($1, $2);
	my ($loc, $showslots, $id) = $itemstr =~ /([\d\w]{5})(\d)([\d\w]+)/;
	my ($refine) = $infostr =~ /%([\d\w]+)/;
	my ($itemtype) = $infostr =~ /&([\d\w]+)/;
	my $item_info = {
		nameID => fromBase62($id),
		upgrade => fromBase62($refine),
	};

    my $item_data = {
        nameID => $item_info->{nameID},
        name => itemNameSimple($item_info->{nameID}),
        upgrade => $item_info->{upgrade},
    };

    my $i = 0;
	foreach my $card (map { $_ } $infostr =~ /\(([\d\w]+)/g) {
        my $cardid = fromBase62($card);
		$item_info->{cards} .= pack('v', $cardid);
        if ($cardid) {
            $item_data->{cards}[$i] = {
                name => itemNameSimple($cardid),
                nameID => $cardid,
            };
        }
        $i++;
	}

    $i = 0;
	foreach my $opt (map { $_ } $infostr =~ /\*([\d\w\+,]+)/g) {
		# The Random Option's order from client is type-param-value, itemName needs type-value-param
		my ($type, $param, $value) = $opt =~ /([a-zA-Z0-9]+)\+([a-zA-Z0-9]+),([a-zA-Z0-9]+)/;
        $type = fromBase62($type);
        $param = fromBase62($param);
        $value = fromBase62($value);
		$item_info->{options} .= pack 'vvC', ( $type, $value, $param );
        if ($type) {
            $item_data->{options}[$i] = {
                type => $type,
                value => $value,
                param => $param,
            };
        }
        $i++;
	}

    $item_data->{name} = itemName($item_info);
    push @{$self->{items}}, $item_data;

	return "<".$item_data->{name}.">";
}

##
# $Itemlink->getMessage()
#
# Return the solved message from itemlink as message string
sub getMessage {
	my ($self) = @_;
	return $self->{message};
}

##
# $Itemlink->getItems()
#
# Returns list of solved item(s)
# $items = [
#    {
#        'nameID' => '2589',
#        'name' => 'Fallen Angel Wing',
#        'upgrade' => '9',
#        'cards' => [
#            {
#                'name' => 'Noxious Card',
#                'nameID' => '4334',
#            },
#            {
#                'name' => 'Expert Archer 4',
#                'nameID' => '4835',
#            }, # if empty, the slot will be undef
#            {
#                'name' => 'Expert Archer 2',
#                'nameID' => '4833',
#            },
#            {
#                'name' => 'Expert Archer 1',
#                'nameID' => '4832',
#            },
#        ],
#        'options' => [
#            {
#                'type' => '1',
#                'value' => '3',
#                'param ''=> '0',
#            },
#        ],
#    },
#    {
#        'nameID' => '22082',
#        'name' => 'Polyhedron Shoes',
#        'upgrade' => '8',
#    },
#];
sub getItems {
	my ($self) = @_;
	return $self->{items};
}

1;
