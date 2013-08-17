package PrefixRC::Status;

use strict;
use warnings;
use Moo;

has pid_dir => ( is => 'rw' );
has program => ( is => 'rw' );

sub BUILD {
    my $self = shift;
}

sub run {
    my $self   = shift;
    my $action = shift;
    $action = '' unless $action;
    if ( $action eq 'start' ) {
        $self->_print_process($action);
    }
    elsif ( $action eq 'stop' ) {
        $self->_print_process( $action, shift );
    }
    elsif ( $action eq 'pid' ) {
        return $self->_read_pid;
    }
    elsif ( $action eq 'check' ) {
        return $self->_check_okay;
    }
    else {
        $self->_print_system;
    }
}

sub get_pid {
    my $self = shift;
    return $self->_read_pid;
}

sub _print_system {
    my $self = shift;
    opendir( my $dh, $self->pid_dir );
    while ( readdir($dh) ) {
        next if $_ =~ /^\./;
        $self->_print_status($_);
    }
    close($dh);
}

sub _print_status {
    my $self = shift;
    $self->program(shift);
    if ( !$self->_read_pid ) {
        $self->_pretty_print( 33, 'stopped' );
    }
    else {
        my $okay   = $self->_check_okay;
        my $code   = $okay ? 32 : 31;
        my $status = $okay ? 'started' : 'crashed';
        $self->_pretty_print( $code, $status );
    }
}

sub _print_process {
    my $self   = shift;
    my $action = shift;
    my $okay   = shift;
    $okay = $self->_check_okay unless $okay;
    my $code = $okay ? 32 : 31;
    $action .= $okay ? ' success' : ' failed';
    $self->_pretty_print( $code, $action );
}

sub _pretty_print {
    my $self   = shift;
    my $code   = shift;
    my $action = shift;
    printf( "%-49s %30s\n",
        $self->program, "\033[$code" . "m[$action]\033[0m" );
}

sub _read_pid {
    my $self = shift;
    if ( -f $self->pid_dir . $self->program ) {
        open my $rh, '<', $self->pid_dir . $self->program or die "$!";
        my $pid = <$rh>;
        close($rh);
        return $pid;
    }
    else {
        $self->_pretty_print( 31, "no process found" );
        exit 1;
    }
}

sub _check_okay {
    my $self = shift;
    my $pid  = $self->_read_pid;
    return kill 0, $pid;
}

1;
