package Store::DataAccessFacade;

use strict;
use warnings;
use 5.010;

use Store::RedisStoreProvider qw(get_connection commit_transaction);

use Exporter qw(import);

use parent 'Base';

sub add_channel {
    my $this = shift;

    my $chanid = shift;
    my $uaid = shift;
    my $conn = get_connection();
    my $action = sub {
                        $conn->hset("chanid:$chanid", 'uaid' => $uaid);
                        $conn->sadd("uaid:$uaid", $chanid);
                 };
    
    commit_transaction($action, $conn);
}

sub remove_channel {
    my $this = shift;

    my $chanid = shift;
    my $uaid = shift;
    my $conn = get_connection();
    my $action = sub {
                        $conn->del("chanid:$chanid");
                        $conn->srem("uaid:$uaid", $chanid);
                 };
    
    commit_transaction($action, $conn);
}

sub update_channel_version {
    my $this = shift;

    my $chanid = shift;
    my $version = shift;
    my $conn = get_connection();

    $conn->hset("chanid:$chanid", 'version' => $version);
}

sub remove_user_agent {
    my $this = shift;

    my $uaid = shift;
    my $conn = get_connection();
    my @chanids = $conn->smembers("uaid:$uaid");
    my $action = sub {
                        foreach my $chanid (@chanids) {
                            $conn->del("chanid:$chanid");
                        }
                        $conn->del("uaid:$uaid");
                 };
    
    commit_transaction($action, $conn);
}

sub is_user_agent_exists {
    my $this = shift;

    my $uaid = shift;
    my $conn = get_connection();
    
    return $conn->exists("uaid:$uaid");
}

sub get_user_agent_by_channel {
    my $this = shift;

    my $chanid = shift;
    my $conn = get_connection();

    return _get_attribute_by_channel($chanid, 'uaid');
}

sub get_channel_version {
    my $this = shift;

    my $chanid = shift;
    my $conn = get_connection();

    return _get_attribute_by_channel($chanid, 'version');
}

sub _get_attribute_by_channel {
    my $chanid = shift;
    my $attr = shift;
    my $conn = get_connection();

    return $conn->hget("chanid:$chanid", $attr);
}

1;
