package PrefixRC::Start;

use strict;
use warnings;
use POSIX qw(setsid setuid getuid setgid getgid);
use File::Spec;
use Moo;

use PrefixRC::Status;

has program    => ( is => 'rw' );
has pid_dir    => ( is => 'ro' );
has config_dir => ( is => 'ro' );

sub BUILD {
    my $self = shift;
    die "need pid_dir" unless $self->pid_dir;
    die "need pid_dir" unless $self->config_dir;
    $self->_parse_config( $self->program );
}

sub run {
    my $self = shift;
    $self->_double_fork;
    PrefixRC::Status->new(
        pid_dir => $self->pid_dir,
        program => $self->program,
    )->run('start');
}

sub _double_fork {
    my $self = shift;
    my $pid  = fork();
    if ( $pid == 0 ) {
        setsid();
        my $cpid = fork();
        if ( $cpid == 0 ) {
            open( STDIN, "<", File::Spec->devnull );
            $self->_redirect_filehandles;
            $self->_launch_program;
            exit(0);
        }
        else {
            $self->_write_pid($cpid);
            exit(0);
        }
    }
    else {
        waitpid( $pid, 0 );
    }
}

sub _redirect_filehandles {
    my $self = shift;
    if ( $ENV{'1'} ) {
        open STDOUT, ">>", $ENV{'1'} or die $!;
    }
    else {
        open STDOUT, ">>", File::Spec->devnull;
    }
    if ( $ENV{'2'} ) {
        open STDERR, ">>", $ENV{'2'} or die $!;
    }
    else {
        open STDERR, ">>", File::Spec->devnull;
    }
}

sub _launch_program {
    my $self = shift;
    exec( $ENV{'BIN'} . " " . $ENV{'ARGS'} ) or die $!;
}

sub _parse_config {
    my $self = shift;
    my $file = shift;

    open my $fh, "<", $self->config_dir . $file
      or die "could not open $file: $!";

    while (<$fh>) {
        chomp;
        my ( $k, $v ) = split /=/, $_, 2;
        $v =~ s/^(['"])(.*)\1/$2/;    #' fix highlighter
        $v =~ s/\$([a-zA-Z]\w*)/$ENV{$1}/g;
        $v =~ s/`(.*?)`/`$1`/ge;      #dangerous
        $ENV{$k} = $v;
    }
}

sub _write_pid {
    my $self = shift;
    my $pid  = shift;
    open my $wh, '>', $self->pid_dir . $self->program or die "$!";
    print $wh $pid;
    close($wh);
}

1;
