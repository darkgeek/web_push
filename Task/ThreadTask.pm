package Task::ThreadTask;

use strict;
use warnings;
use 5.010;
use threads;
use parent 'Base';

use Exporter qw(import);
use Utils::WebUtils qw(set_object_field);

sub start {
    my $this = shift;
    my $task_subroutine = shift;
    my $thr = threads->create($task_subroutine);
    
    $this->_thread($thr);
}

sub stop {
    my $this = shift;

    my $thr = $this->_thread;

    $thr->kill('KILL')->detach if defined $thr;
}

sub _thread {
    return set_object_field(shift, '_thread', shift);
}

1;
