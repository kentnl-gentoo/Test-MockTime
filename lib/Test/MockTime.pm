package Test::MockTime;

use strict;
use warnings;
use Carp();
our ($VERSION) = '0.01';
our ($offset) = 0;
our ($fixed) = undef;

BEGIN {
	*CORE::GLOBAL::time = \&Test::MockTime::time;
	*CORE::GLOBAL::localtime = \&Test::MockTime::localtime;
	*CORE::GLOBAL::gmtime = \&Test::MockTime::gmtime;
}

sub set_relative_time {
	unless (@_ == 1) {
		if ($^W) {
			Carp::carp("Test::MockTime::set_relative_time called incorrectly\n");
		}
	}
	$offset = $_[-1]; # last argument. might have been called in a OO syntax?
}

sub set_absolute_time {
	unless (@_ == 1) {
		if ($^W) {
			Carp::carp("Test::MockTime::set_relative_time called incorrectly\n");
		}
	}
	$offset = (CORE::time * -1) + $_[-1]; # last argument. might have been called in a OO syntax?
}

sub set_fixed_time {
	unless (@_ == 1) {
		if ($^W) {
			Carp::carp("Test::MockTime::set_relative_time called incorrectly\n");
		}
	}
	$fixed = $_[-1]; # last argument. might have been called in a OO syntax?
}

sub time { 
	if (defined $fixed) {
		return $fixed;
	} else {
		return (CORE::time + $Test::MockTime::offset);
	}
}

sub localtime {
	my ($time) = @_;
	unless (defined $time) {
		$time = Test::MockTime::time();
	}
	return CORE::localtime($time);
}

sub gmtime {
	my ($time) = @_;
	unless (defined $time) {
		$time = Test::MockTime::time();
	}
	return CORE::gmtime($time);;
}

sub restore {
	$offset = 0;
	$fixed = undef;
}
