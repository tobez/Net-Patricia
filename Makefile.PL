use 5.008;
use ExtUtils::MakeMaker;

my $mm_ver = $ExtUtils::MakeMaker::VERSION;
if ($mm_ver =~ /_/) { # dev version
    $mm_ver = eval $mm_ver;
    die $@ if $@;
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Net::Patricia',
    'VERSION_FROM' => 'Patricia.pm', # finds $VERSION
    'LIBS'	=> [],     # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',     # e.g., '-I/usr/include/other' 
    'MYEXTLIB'	=> 'libpatricia/libpatricia$(LIB_EXT)',     # e.g., '-I/usr/include/other' 
    'dist'      => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz'},
    'PREREQ_PM'	=> {'Socket6' => 0,
		    'version' => 0,
		    'Test::More' => '0.88',
		    'Net::CIDR::Lite' => '0.20',
		   },
    ($mm_ver <= 6.45 ? () : (META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            bugtracker  =>      'http://rt.cpan.org/Public/Dist/Display.html?Name=Net-Patricia',
            repository  => {
                type => 'git',
                web  => 'https://github.com/tobez/Net-Patricia',
                url  => 'git://github.com/tobez/Net-Patricia.git',
            },
        },
    })),
);

sub MY::postamble {
'
$(MYEXTLIB): libpatricia/Makefile
	cd libpatricia && $(MAKE) $(PASTHRU)
';
}
