package Command::CommandFactory;

use strict;
use warnings;

use Exporter qw(import);

sub get_instance {
    my $class = shift;
    my $needed_type = shift;
    my $location = "Command/$needed_type"."Command.pm";
    my $clazz = "Command::$needed_type"."Command";

    require $location;

    return $clazz->new(@_);
}

1;
