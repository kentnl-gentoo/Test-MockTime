#! /usr/bin/perl -wT

my ($result) = 0;
$ENV{'PATH'} = '/bin';
while($result == 0) {
	$result = system("/usr/bin/perl -I/home/dave/Test-MockTime-0.01/lib /home/dave/Test-MockTime-0.01/t/test.t");
}
