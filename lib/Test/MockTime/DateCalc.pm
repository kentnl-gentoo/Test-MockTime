# Copyright 2009 Kevin Ryde

# This file is part of Test-MockTime.
#
# Test-MockTime is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

package Date::Calc;

package Test::MockTime::DateCalc;
use strict;
use warnings;
use Test::MockTime;

our $VERSION = '0.11';

BEGIN {
  # Week_of_Year() here is just a representative func, present in Date::Calc
  # 4.0 and up, and not one that's mangled here (so as not to risk hitting
  # that if something goes badly wrong)
  if (Date::Calc->can('Week_of_Year')) {
    die "Date::Calc already loaded, cannot fake after imports may have aliased its functions";
  }
}

# Date::Calc had a big rewrite in 4.0 of May 1998, no attempt to fake
# anything earlier than that here go to Test::MockTime::time() for the
# current time, and stay in Date::Calc for conversions to d/m/y etc.
#
use Date::Calc 4.0;

package Date::Calc;
use strict;
use warnings;
no warnings 'redefine';

# Calc.xs in Date::Calc calls to the C time() func from its internal
# DateCalc_system_clock(), and directly in Gmtime(), Localtime(), Timezone()
# and Time_to_Date().  In each case that of course misses any fakery on the
# perl level time().  The replacements here
#

sub System_Clock {
  my ($gmt) = @_;
  return ($gmt ? Gmtime() : Localtime());
}
sub Today {
  return (System_Clock(@_))[0,1,2];
};
sub Now {
  return (System_Clock(@_))[3,4,5];
}
sub Today_and_Now {
  return (System_Clock(@_))[0,1,2, 3,4,5];
}
sub This_Year {
  return (System_Clock(@_))[0];
}

{ my $default_time = sub {
    my ($func, $time) = @_;
    if (! defined $time) {
      $time = Test::MockTime::time();
    }
    return $func->($time);
  };
  { my $orig = \&Gmtime;
    *Gmtime = sub { return $default_time->($orig, @_) };
  }
  { my $orig = \&Localtime;
    *Localtime = sub { return $default_time->($orig, @_) };
  }
  { my $orig = \&Timezone;
    *Timezone = sub { return $default_time->($orig, @_) };
  }
  { my $orig = \&Time_to_Date;
    *Time_to_Date = sub { return $default_time->($orig, @_) };
  }
}

1;
__END__

=head1 NAME

Test::MockTime::DateCalc -- fake time for Date::Calc functions

=head1 SYNOPSIS

 use Test::MockTime;
 use Test::MockTime::DateCalc; # before Date::Calc loads
 ...
 use My::Module::Using::Date::Calc;

=head1 DESCRIPTION

C<Test::MockTime::DateCalc> arranges for the functions in
L<C<Date::Calc>|Date::Calc> to follow the fake date/time of
L<C<Test::MockTime>|Test::MockTime>.  It affects the following C<Date::Calc>
functions

    System_Clock
    Today
    Now
    Today_and_Now
    This_Year

    Gmtime
    Localtime
    Timezone
    Time_to_Date

C<Gmtime>, C<Localtime>, C<Timezone> and C<Time_to_Date> default to the
MockTime fake system time, but when called with an explicit time they're
unchanged.

=head2 Load Order

C<Test::MockTime::DateCalc> must be loaded before C<Date::Calc>.

If C<Date::Calc> is already loaded then its functions might have been
imported into other modules and such imports are not affected by the
redefinitions made here.  For that reason C<Test::MockTime::DateCalc>
demands that it be the one to load C<Date::Calc> for the first time.
Usually this simply means having C<Test::MockTime::DateCalc> at the start of
your test script, before the things you're going to test.

    use strict;
    use warnings;
    use Test::MockTime ':all';
    use Test::MockTime::DateCalc;

    use My::Foo::Bar;

    set_fixed_time('1981-01-01T00:00:00Z');
    is (My::Foo::Bar::something(), 1981);
    restore_time();

Load order is the reason the main C<Test::MockTime> doesn't automatically
apply itself to C<Date::Calc>.  It's only done optionally, with this
C<Test::MockTime::DateCalc> module.

In a test script it's often good to have your own modules first so as to
check they they load all their pre-requisites.  You might want to have a
separate test script to check your code loads C<Date::Calc> when needed, not
just using what C<Test::MockTime::DateCalc> loads.

=head1 SEE ALSO

L<Date::Calc>, L<Test::MockTime>

=head1 COPYRIGHT

Test-MockTime is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
