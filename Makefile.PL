use 5.034000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	NAME              => 'Test::Tk',
	VERSION_FROM      => 'lib/Test/Tk.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
	PREREQ_PM         => {}, # e.g., Module::Name => 1.1
	ABSTRACT_FROM     => 'lib/Test/Tk.pm', # retrieve abstract from module
	AUTHOR            => 'Hans Jeuken <hanje@cpan.org>',
	LICENSE           => 'perl',
	(eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url  => 'git://github.com/haje61/Test-Tk.git',
				web  => 'https://github.com/haje61/Test-Tk',
			},
		}}) : ()
	),
);
