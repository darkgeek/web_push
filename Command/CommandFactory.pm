package Command::CommandFactory;

use strict;
use warnings;

use Exporter qw(import);

sub create {
    my $class = shift;
    my $request_message = shift;
    my $needed_type = $request_message->{messageType};
    say "[messageType] shouldn't be empty" unless defined $needed_type;

    $needed_type = _get_command_name($needed_type);
    my $location = "Command/$needed_type"."Command.pm";
    my $clazz = "Command::$needed_type"."Command";

    require $location;

    return $clazz->new($request_message);
}

sub _get_command_name {
    my $message_type = shift;

    return ucfirst $message_type;
}

1;
