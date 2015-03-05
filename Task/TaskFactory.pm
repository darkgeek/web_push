package Task::TaskFactory;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

sub create {
    my $class = shift;
    my $needed_type = shift;

    my $location = "Task/$needed_type"."Task.pm";
    my $clazz = "Task::$needed_type"."Task";

    require $location;

    return $clazz->new(@_);
}

1;
