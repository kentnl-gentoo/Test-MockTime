#!/usr/bin/perl

# Copyright 2009 Kevin Ryde

# This file is part of Test-MockTime.
#
# Test-MockTime is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

use strict;
use warnings;
use Test::More tests => 19;

use Test::MockTime;
use POSIX ();

#------------------------------------------------------------------------------

sub my_tzset {
  my ($tzstr) = @_;
  $ENV{'TZ'} = $tzstr;
  # tzset() dies with "not implemented" if no such C library func
  if (! eval { POSIX::tzset(); 1 }) {
    diag "POSIX::tzset() skipped: $@";
  }
}

my ($date_calc_loaded);
my ($problem_in_test_mocktime_datecalc);
eval { require Test::MockTime::DateCalc; };
if ($@) {
  my ($exception) = $@;
  eval { require Date::Calc; };
  unless ($@) {
    $problem_in_test_mocktime_datecalc = 1;
  }
} else {
  $date_calc_loaded = 1;
}
SKIP: {
  if ($problem_in_test_mocktime_datecalc) {
     ok(0, "Failed to load Test::MockTime::DateCalc, even though Date::Calc was loadable");
     skip("Date::Calc cannot be loaded", 9);
  } else {
     skip("Date::Calc cannot be loaded", 10) unless ($date_calc_loaded);
  }
  require Test::MockTime::DateCalc;
  is (Test::MockTime::DateCalc->VERSION, Test::MockTime->VERSION,
      'same version number as main MockTime');

  my_tzset ('GMT');

  Test::MockTime::set_fixed_time ('1981-01-01T12:34:56Z');

  is_deeply ([Date::Calc::System_Clock()], [1981,1,1, 12,34,56, 1,4,0],
       'System_Clock');
  is_deeply ([Date::Calc::Today()], [1981,1,1],
       'Today');
  is_deeply ([Date::Calc::Now()], [12,34,56],
       'Now');
  is_deeply ([Date::Calc::Today_and_Now()], [1981,1,1, 12,34,56],
       'Today_and_Now');
  is (Date::Calc::This_Year(), 1981,
      'This_Year');

  is_deeply ([Date::Calc::Gmtime()],    [1981,1,1, 12,34,56, 1,4,0],
       'Gmtime');
  is_deeply ([Date::Calc::Localtime()], [1981,1,1, 12,34,56, 1,4,0],
       'Localtime');
  is_deeply ([Date::Calc::Timezone()], [0,0,0, 0,0,0, 0],
       'Timezone');
  is_deeply ([Date::Calc::Time_to_Date()], [1981,1,1, 12,34,56],
       'Time_to_Date');
}


sub localtime_differs_from_gmt {
  my $time = time();
  my $local_hour = (localtime($time))[2];
  my $gmt_hour   = (gmtime($time))[2];
  return ($local_hour != $gmt_hour);
}

SKIP: {
  skip("Date::Calc cannot be loaded", 9) unless ($date_calc_loaded);
  my_tzset ('BST+1');
  localtime_differs_from_gmt()
    or skip "due to localtime() not influenced by TZ=BST+1", 9;

  Test::MockTime::set_fixed_time ('1981-01-01T12:00:00Z');

  is_deeply ([Date::Calc::System_Clock()], [1981,1,1, 11,0,0, 1,4,0],
             'System_Clock');
  is_deeply ([Date::Calc::Today()], [1981,1,1],
             'Today');
  is_deeply ([Date::Calc::Now()], [11,0,0],
             'Now');
  is_deeply ([Date::Calc::Today_and_Now()], [1981,1,1, 11,0,0],
             'Today_and_Now');
  is (Date::Calc::This_Year(), 1981,
      'This_Year');

  is_deeply ([Date::Calc::Gmtime()],    [1981,1,1, 12,0,0, 1,4,0],
             'Gmtime');
  is_deeply ([Date::Calc::Localtime()], [1981,1,1, 11,0,0, 1,4,0],
             'Localtime');
  is_deeply ([Date::Calc::Timezone()], [0,0,0, -1,0,0, 0],
             'Timezone');
  is_deeply ([Date::Calc::Time_to_Date()], [1981,1,1, 12,0,0], # gmtime
             'Time_to_Date');
}

exit 0;
