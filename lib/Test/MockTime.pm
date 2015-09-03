package Test::MockTime;

use strict;
use warnings;
use Carp();
use Exporter();
*import = \&Exporter::import;
our @EXPORT_OK = qw(
  set_relative_time
  set_absolute_time
  set_fixed_time
  restore_time
);
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK, );
our $VERSION     = '0.14';
our $offset      = 0;
our $fixed       = undef;

BEGIN {
    *CORE::GLOBAL::time      = \&Test::MockTime::time;
    *CORE::GLOBAL::localtime = \&Test::MockTime::localtime;
    *CORE::GLOBAL::gmtime    = \&Test::MockTime::gmtime;
}

sub set_relative_time {
    my ($relative) = @_;
    if (   ( $relative eq __PACKAGE__ )
        || ( UNIVERSAL::isa( $relative, __PACKAGE__ ) ) )
    {
        Carp::carp("Test::MockTime::set_relative_time called incorrectly\n");
    }
    $offset = $_[-1];    # last argument. might have been called in a OO syntax?
    return $offset;
}

sub _time {
    my ( $time, $spec ) = @_;
    if ( $time !~ /\A -? \d+ \z/xms ) {
        $spec ||= '%Y-%m-%dT%H:%M:%SZ';
    }
    if ($spec) {
        require Time::Piece;
        $time = Time::Piece->strptime( $time, $spec )->epoch();
    }
    return $time;
}

sub set_absolute_time {
    my ( $time, $spec ) = @_;
    if ( ( $time eq __PACKAGE__ ) || ( UNIVERSAL::isa( $time, __PACKAGE__ ) ) )
    {
        Carp::carp("Test::MockTime::set_absolute_time called incorrectly\n");
    }
    $time = _time( $time, $spec );
    $offset = $time - CORE::time;
    return $offset;
}

sub set_fixed_time {
    my ( $time, $spec ) = @_;
    if ( ( $time eq __PACKAGE__ ) || ( UNIVERSAL::isa( $time, __PACKAGE__ ) ) )
    {
        Carp::carp("Test::MockTime::set_fixed_time called incorrectly\n");
    }
    $time = _time( $time, $spec );
    $fixed = $time;
    return $fixed;
}

sub time() {
    if ( defined $fixed ) {
        return $fixed;
    }
    else {
        return ( CORE::time + $offset );
    }
}

sub localtime (;$) {
    my ($time) = @_;
    if ( !defined $time ) {
        $time = Test::MockTime::time();
    }
    return CORE::localtime($time);
}

sub gmtime (;$) {
    my ($time) = @_;
    if ( !defined $time ) {
        $time = Test::MockTime::time();
    }
    return CORE::gmtime($time);
}

sub restore {
    $offset = 0;
    $fixed  = undef;
    return;
}
*restore_time = \&restore;

1;
