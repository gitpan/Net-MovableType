use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME                => 'Net::MovableType',
    VERSION_FROM	    => 'MovableType.pm',
    PREREQ_PM		    => {
        'SOAP::Lite'        => undef,
        'XML::Simple'       => undef
    },
    ABSTRACT_FROM       => 'MovableType.pm',
    AUTHOR              => 'Sherzod B. Ruzmetov <sherzodr@handalak.com>'
);

