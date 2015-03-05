package Service::TaskService;

use strict;
use warnings;
use 5.010;

use Store::DataAccessFacade;
use Utils::WebUtils qw(get_logger);
use Utils::Constants;
use Task::TaskFactory;
use Command::NotificationCommand;
use DateTime;

use Exporter qw(import);

use parent 'Base';

my $data_access_facade = Store::DataAccessFacade->new();
my $message_service = Service::MessageService->new();

sub start_message_resend_task {
    my $this = shift;

    my ($message_queue, $clients) = @_;
    my $task = Task::TaskFactory->create('IOLoop');
    my $task_routiune = sub {
        my $message = $message_queue->remove();

        while ((defined $message) and $message->is_acked) {
            get_logger()->info("Message [chanid => ".$message->chanid.", version => ".$message->version."] is acked. Try next.");
            $message = $message_queue->remove();
        }

        unless (defined $message)  {
            get_logger()->info("Empty queue.");
            return;
        }
        
        my $now_time = DateTime->now;
        my $cmp = DateTime->compare($message->next_send_time, $now_time);

        # Add the message to $message_queue again since it has not reached the time to resend
        if ($cmp eq 1) {
            get_logger()->info("Readd to message queue: [chanid => ".$message->chanid.", version => ".$message->version."]");
            $message_queue->add($message);
            return;
        }

        # Resend the message
        my $uaid = $message_service->get_uaid_by_chanid($message->chanid);
        my $client = $clients->{$uaid};

        return unless defined $client;
        my $command = Command::NotificationCommand->new;
        $command->ws_client($client);
        $command->chanid($message->chanid);
        $command->version($message->version);
        $command->message_queue($message_queue);
        $command->execute();
    };
    
    $task->start($task_routiune, 10);
    get_logger()->debug("message resend task started...");
}

sub start_new_message_listener_task {
    my $this = shift;

    my $topics = [Utils::Constants::NEW_MESSAGE_LISTENER_TOPIC];
    my $conn = $message_service->listen_on_new_messages($topics, sub {
        my ($message, $topic, $subscribed_topic) = @_;
        get_logger()->debug("Get message from $topic: $message");
    });
    my $task = Task::TaskFactory->create('Thread');
    my $task_routiune = sub {
        # Respond to KILL signal
        local $SIG{KILL} = sub { threads->exit };
        $conn->wait_for_messages(10) while 1;
    };

    $task->start($task_routiune);
    get_logger()->debug("Listen on new messages...");
}

1;
