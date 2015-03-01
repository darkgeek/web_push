package Service::MessageService;

use strict;
use warnings;
use 5.010;

use Store::DataAccessFacade;

use Exporter qw(import);

use parent 'Base';

my $data_access_facade = Store::DataAccessFacade->new();

sub get_chanids_by_uaid {
    my $this = shift;

    my $uaid = shift;

    return $data_access_facade->get_channels_by_user_agent($uaid);
}

sub remove_chanid {
    my $this = shift;

    my $chanid = shift;
    
    return $data_access_facade->remove_channel($chanid);
}

sub add_chanid {
    my $this = shift;

    my $chanid = shift;
    my $uaid = shift;

    return $data_access_facade->add_channel($chanid, $uaid);
}

sub get_uaid_by_chanid {
    my $this = shift;

    my $chanid = shift;
    
    return $data_access_facade->get_user_agent_by_channel($chanid);
}

sub get_channel_version {
    my $this = shift;

    my $chanid = shift;

    return $data_access_facade->get_channel_version($chanid);
}

sub update_channel_version {
    my $this = shift;

    my $chanid = shift;
    my $version = shift;

    return $data_access_facade->update_channel_version($chanid, $version);
}

1;
