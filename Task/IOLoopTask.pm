package Task::IOLoopTask;

use strict;
use warnings;
use 5.010;
use parent 'Base';

use Exporter qw(import);
use Utils::WebUtils qw(set_object_field);
use Mojo::IOLoop;

sub start {
    my $this = shift;

    my $task_subroutine = shift;
    my $interval = shift;
    
    # Default to 10 seconds
    $interval = 10 unless defined $interval;
    my $ioloop_task = Mojo::IOLoop->recurring($interval => $task_subroutine);

    $this->_task($ioloop_task);
}

sub stop {
    my $this = shift;
    
    my $task = $this->_task;

    Mojo::IOLoop->remove($task) if defined $task;
}

sub _task {
    return set_object_field(shift, '_task', shift);
}

1;
