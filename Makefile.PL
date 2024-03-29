use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'POE::Wheel::Multicast',
    VERSION_FROM      => 'lib/POE/Wheel/Multicast.pm', # finds $VERSION
    PREREQ_PM         => {
    	'Carp'		=> 0,
	'Socket'	=> 0,
	'Fcntl'		=> 0,
	'POE'		=> 0,
	'POE::Wheel::UDP' => 0,
	'Socket::Multicast' => 0,
	
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/POE/Wheel/Multicast.pm', # retrieve abstract from module
       AUTHOR         => 'Jonathan Steinert <hachi@cpan.org>') : ()),
);
