package Base;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

sub new {
    my $class = shift;
    my $self = {};
    return bless $self, $class;
}

1;
