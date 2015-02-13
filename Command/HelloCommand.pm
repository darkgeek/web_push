package Command::HelloCommand;

use strict;
use warnings;

use parent 'BaseCommand';

use Exporter qw(import);

sub execute {
    my $this = shift;
    my $request_message = $this->{request_message};
    my $ws = $this->{ws_client};

    unless (defined $ws) {
        say "ws_client is needed and shouldn't be empty. Aborted."
        return;
    }
}
