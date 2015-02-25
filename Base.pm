package Base;

use strict;
use warnings;
use 5.010;

use Mojo::Log;
use Exporter qw(import);

sub new {
    my $class = shift;
    my $self = {};
    return bless $self, $class;
}

1;
