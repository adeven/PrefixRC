package PrefixRC::Stop;

use strict;
use warnings;
use Moo;

use PrefixRC::Status;

has pid_dir => ( is => 'rw' );
has program => ( is => 'rw' );
has status  => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->status(
        PrefixRC::Status->new(
            pid_dir => $self->pid_dir,
            program => $self->program,
        )
    );
}

sub run {
    my $self = shift;
    if ( !$self->status->run('check') ) {
        $self->status->run( 'stop', 0 );
    }
    else {
        $self->_kill_process;
    }
}

sub _kill_process {
    my $self = shift;
    my $success = kill 'TERM', $self->status->run('pid');
    $self->status->run( 'stop', $success );
    $self->_null_pid;
}

sub _null_pid {
    my $self = shift;
    open my $wh, '>', $self->pid_dir . $self->program or die $!;
    print $wh 0;
    close $wh;
}

1;
