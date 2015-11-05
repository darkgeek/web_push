package Store::DataAccessFacade;

use strict;
use warnings;
use 5.010;

use Store::RedisStoreProvider qw(get_connection commit_transaction);
use Utils::WebUtils qw(get_logger);

use Exporter qw(import);

use parent 'Base';

sub add_channel {
    my $this = shift;

    my $chanid = shift;
    my $uaid = shift;
    use constant {
        RESULT_CODE_SUCCESS => 0,
        RESULT_CODE_FAILED_TRANSACTION_ERROR => 1,
        RESULT_CODE_CONFLICT_CHANNELID_ERROR => 2,
    };
    my $conn = get_connection();
    my $is_chanid_exists = $conn->exists("chanid:$chanid");

    if ($is_chanid_exists) {
        return RESULT_CODE_CONFLICT_CHANNELID_ERROR;
    }

    my $action = sub {
                        $conn->hmset("chanid:$chanid", 'uaid' => $uaid, 'version' => 0);
                        $conn->sadd("uaid:$uaid", $chanid);
                 };
    
    my @replies = commit_transaction($action, $conn);

    get_logger()->debug("Replies: @replies");

    if (_has_failure(@replies)) {
        return RESULT_CODE_FAILED_TRANSACTION_ERROR;
    }

    return RESULT_CODE_SUCCESS;
}

sub remove_channel {
    my $this = shift;

    my $chanid = shift;
    my $uaid = $this->get_user_agent_by_channel($chanid);
    use constant {
        RESULT_CODE_SUCCESS => 0,
        RESULT_CODE_FAILED_TRANSACTION_ERROR => 1,
    };
    unless (defined $uaid) {
        return RESULT_CODE_FAILED_TRANSACTION_ERROR;
    }

    my $conn = get_connection();
    my $action = sub {
                        $conn->del("chanid:$chanid");
                        $conn->srem("uaid:$uaid", $chanid);
                 };
    
    my @replies = commit_transaction($action, $conn);

    get_logger()->debug("Replies: @replies");

    if (_has_failure(@replies)) {
        return RESULT_CODE_FAILED_TRANSACTION_ERROR;
    }

    return RESULT_CODE_SUCCESS;
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

sub get_channels_by_user_agent {
    my $this = shift;

    my $uaid = shift;
    my $conn = get_connection();
    my @chanids = $conn->smembers("uaid:$uaid");

    return @chanids;
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

sub subscribe_on_topics {
    my $this = shift;

    my $topics = shift;
    my $callback = shift;
    my $conn = get_connection();

    $conn->subscribe(
            @$topics,
            $callback
    );

    return $conn;
}

sub publish_to_topic {
    my $this = shift;
    my ($topic, $message) = @_;
    my $conn = get_connection();

    $conn->publish($topic, $message);
}

sub _get_attribute_by_channel {
    my $chanid = shift;
    my $attr = shift;
    my $conn = get_connection();

    return $conn->hget("chanid:$chanid", $attr);
}

sub _has_failure {
    my $has_failure = 0;

    for my $reply (@_) {
        unless ($reply) {
            $has_failure = 1;
            last;
        }
    }

    return $has_failure;
}

1;
