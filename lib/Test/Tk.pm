package Test::Tk;


use strict;
use warnings;
our $VERSION = '1.00';

use Test::More;
use Tk;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(
	$app
	$delay
	$mwclass
	@tests
	$show
	createapp
	hashcompare
	listcompare
);

our $app;
our $mwclass = 'Tk::MainWindow';
our @tests = ();
our $show = 0;
our $delay = 100;

my $arg = shift @ARGV;
$show = 1 if (defined($arg) and ($arg eq 'show'));

sub createapp {
	eval "use $mwclass";
	$app = new $mwclass(
		-width => 200,
		-height => 125,
		-title => 'TestSuite',
		@_
	);
	ok(defined $app, "can create");
	$app->after($delay, \&dotests);
}

sub dotests {
	ok(1, "main loop runs");
	for (@tests) {
		my ($call, $expected, $comment) = @$_;
		my $result = &$call;
		if ($expected =~ /^ARRAY/) {
			ok(ListCompare($expected, $result), $comment)
		} elsif ($expected =~ /^HASH/) {
			ok(HashCompare($expected, $result), $comment)
		} else {
			ok(($expected eq $result), $comment)
		}
	}
	$app->after(5, sub { $app->CommandExecute('quit') }) unless $show
}

sub hashcompare {
	my ($h1, $h2) = @_;
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
	my ($l1, $l2) = @_;
# 	use Data::Dumper; print Dumper $l2;
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

1;
__END__

=head1 NAME

Test::Tk - Testing Perl/Tk widgets

=head1 SYNOPSIS

 use Test::More tests => 3;
 
 createapp(
 );
 
 @tests = (
    [sub { return 1 }, 1, 'A demo test'],
 );
 
 $app->MainLoop;

=head1 DESCRIPTION


=head1 EXPORT

=over 4

=item B<$app>

=over 4

=back

=item B<$delay>

=over 4

=back

=item B<$mwclass>

=over 4

=back


=item B<@tests>

=over 4

=back


=item B<$show>

=over 4

=back

=item B<createapp>

=over 4

=back

=item B<hashcompare>

=over 4

=back

=item B<listcompare>

=over 4

=back

=back

=head1 SEE ALSO


=head1 AUTHOR

Hans Jeuken, E<lt>hanje at cpan dot org@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 by Hans Jeuken

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.34.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
