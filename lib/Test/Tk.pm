package Test::Tk;


use strict;
use warnings;
our $VERSION = '3.04';

use Config;
use Test::More;
use Test::Deep;
use Tk;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(
	$app
	$delay
	$quitdelay
	$mwclass
	@tests
	$show
	createapp
	hashcompare
	listcompare
	pause
	starttesting
	testaccessors
);

our $app;
our $mwclass = 'Tk::MainWindow';
our @tests = ();
our $show = 0;
our $delay = 100;
our $quitdelay = 200;

my $arg = shift @ARGV;
$show = 1 if (defined($arg) and ($arg eq 'show'));

sub createapp {
	if (($Config{'osname'} eq 'MSWin32') or (exists $ENV{'DISPLAY'})) {
		eval "use $mwclass";
		$app = new $mwclass(
			-width => 200,
			-height => 125,
			-title => 'TestSuite',
			@_
		);
		ok(defined $app, "app created");
	}
}

sub dotests {
	if (defined $app) {
		ok(1, "main loop runs");
		for (@tests) {
			my ($call, $expected, $comment) = @$_;
			my $result = &$call;
			cmp_deeply($result, $expected, $comment); 
		}
		$app->after($quitdelay, sub { $app->destroy }) unless $show
	}
}

sub hashcompare {
	my ($h1, $h2) = @_;
	warn "Depricated 'hashcompare', use Test::Deep";
	my @l1 = sort keys %$h1;
	my @l2 = sort keys %$h2;
	return 0 unless listcompare(\@l1, \@l2);
	for (@l1) {
		my $test1 = $h1->{$_};
		unless (defined $test1) { $test1 = 'UNDEF' }
		my $test2 = $h2->{$_};
		unless (defined $test2) { $test2 = 'UNDEF' }
		if ($test1 =~ /^ARRAY/) {
			return 0 unless listcompare($test1, $test2)
		} elsif ($test1 =~ /^HASH/) {
			return 0 unless hashcompare($test1, $test2)
		} else {
			return 0 if $test1 ne $test2
		}
	}
	return 1
}

sub listcompare {
	my ($l1, $l2) = @_;;
	warn "Depricated 'listcompare', use Test::Deep";
	my $size1 = @$l1;
	my $size2 = @$l2;
	if ($size1 ne $size2) { return 0 }
	foreach my $item (0 .. $size1 - 1) {
		my $test1 = $l1->[$item];
		unless (defined $test1) { $test1 = 'UNDEF' }
		my $test2 = $l2->[$item];
		unless (defined $test2) { $test2 = 'UNDEF' }
		if ($test1 =~ /^ARRAY/) {
			return 0 unless listcompare($test1, $test2)
		} elsif ($test1 =~ /^HASH/) {
			return 0 unless hashcompare($test1, $test2)
		} else {
			return 0 if $test1 ne $test2
		}
	}
	return 1
}

sub pause {
	return unless defined $app;
	my $milisecs = shift;
	my $var = 1;
	$app->after($milisecs, sub { $var = 0 });
	$app->waitVariable(\$var);
}

sub starttesting {
	if (defined $app) {
		$app->after($delay, \&dotests);
		$app->MainLoop;
	} else {
		my $size = @tests + 2;
		SKIP: {
			skip 'No XServer running for this user', $size;
		}
	}
}

sub testaccessors {
	my $obj = shift;
	for (@_) {
		my $method = $_;
		push @tests, [sub {
			my $default = $obj->$method;
			$obj->$method('blieb');
			my $res1 = $obj->$method;
			$obj->$method('quep');
			my $res2 = $obj->$method;
			$obj->$method($default);
			return (($res1 eq 'blieb') and ($res2 eq 'quep'));
		}, 1, "Accessor $method"];
	}
}

1;
__END__

=head1 NAME

Test::Tk - Testing Tk widgets.

=head1 SYNOPSIS

 use Test::More tests => 5;
 use Test::Tk;
 
 BEGIN { use_ok('Tk::MyWidget') };
 
 createapp(@options);
 
 my $widget;
 if (defined $app) {
    $widget = $app->MyWidget->pack;
 }
 
 push @tests,
    [sub { return defined $widget }, 1, 'Created MyWidget'],
    [sub { return 1 }, 1, 'A demo test'],
 ;
 
 starttesting;

=head1 DESCRIPTION

This module aims to assist in the testing of Perl/Tk widgets.

B<createapp> creates a MainWindow widget and places it in the variable B<$app>.
It sets a timer with delay B<$delay> to start the internal test routine.

B<starttesting> launches the main loop and sets a timer with delay B<$delay> to start the internal test routine.

When testing is done the MainWindow is destroyed and the test script continues.

You can set a command line parameter B<show> to test command on the command line.
eg I<perl -Mblib t/My-Test.t show>. The application will not terminate so you 
can visually inspect it.

It will perform two tests. You need to account for these 
when you set your number of tests.

If you are not on Windows and no XServer is running, all tests will be skipped.

=head1 EXPORT

=over 4

=item B<$app>

Holds the reference to the MainWindow object. If you are not on Windows and no 
XServer is running, the MainWindow will not be created and B<$app> remains 
undefined. Do not change this variable.

=item B<$delay>

Default value 100. The delay time between creating the test app and
start of the testing. You may want to increase this value in case 
all tests succeed but your test program still throws an error.

=item B<$mwclass>

Default value Tk::MainWindow.
You can set it to a derived class.

=item B<$quitdelays>

Default value 200.
This is the delay set between the termination of tests and the desctruction of the main widow.
If your desktop goes bonkers while testing, you main want to increase this value. 
But I think you're good.

=item B<@tests>

Each element of B<@tests > should contain a list of three elements.

=over 4

=item B<A reference to a sub>

The sub should return the expected value for the test to succeed. It should
always return something in scalar context.

=item B<Expected value>

This can be a simple scalar but also the reference to a list or a hash. You may even 
specify a complexer data structure.

=item B<Description>

A brief description of the test so you know which test passed or failed.

=back

=item B<$show>

By default 0. Is set when the B<show> option is given at the command line.
You can overwrite this by setting or clearing this yourself.

=item B<createapp>I<(@options)>

Creates the MainWindow object and tests if successfull. 
Places the object in B>$app>.

=item B<hashcompare>I<(\%hash1, \%hash2)>

Depricated, use Test::Deep or Data::Compare.

=item B<listcompare>I<(\@list1, \@list2)>

Depricated, use Test::Deep or Data::Compare.

=item B<pause>I<($miliseconds)>

Pauses the app for $miliseconds, allowing background processes to finish.

=item B<starttesting>

Launches the main loop and sets a timer with delay B<$delay> to start
the internal test routine.

=item B<testaccessors>I<($obj, 'method1, 'method2', ...)>

Quickly set up accessor tests. Just to be clear, an accessor is something like this.

 sub Value {
    my $self = shift;
    $self->{VALUE} = shift if @_;
    return $self->{VALUE}
 }

=back

=head1 SEE ALSO

L<Test::More>
L<Test::Deep>

=head1 AUTHOR

Hans Jeuken, E<lt>hanje at cpan dot org@E<gt>

=head1 TODO

This should also work for Tcl::pTk widgets. However,
the testing of this module during install is done with
Tk. So this is set as a prerequisite.
A duplicate module with slightly different defaults
for Tcl::pTk is thinkable.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 - 2024 by Hans Jeuken

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

