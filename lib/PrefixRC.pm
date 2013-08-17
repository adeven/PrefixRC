package PrefixRC;

use strict;
use warnings;
use Moo;

use PrefixRC::Start;
use PrefixRC::Status;
use PrefixRC::Stop;

our $VERSION = '0.01';

has prefix     => ( is => 'rw' );
has pid_dir    => ( is => 'rw' );
has config_dir => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $ENV{'EPREFIX'} = $self->prefix if $self->prefix;
    $self->prefix( $ENV{'EPREFIX'} );
    die "need \$EPREFIX environment var" unless $ENV{'EPREFIX'};
    $self->pid_dir( $self->prefix . "/var/run/" );
    $self->config_dir( $self->prefix . "/etc/conf.d/" );
}

sub run {
    my $self   = shift;
    my $action = shift;
    $action =~ s/\b(\w)/\U$1/;
    my $prog = shift;
    "PrefixRC::$action"->new(
        pid_dir    => $self->pid_dir,
        config_dir => $self->config_dir,
        program    => $prog,
    )->run();
}

1;
