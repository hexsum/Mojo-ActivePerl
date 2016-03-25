#!/usr/bin/perl -w

BEGIN {
    # fix up @INC path so we can run from the unpacked tarball
    s,^/tmp/perl----[^/]*,perl, for @INC;
}

use strict;

use ActiveState::Prompt qw(prompt yes);
use ActiveState::Run qw(run);
use Getopt::Long qw(GetOptions);
use Config qw(%Config);

$| = 1;

my $product = "ActivePerl";
my $prefix;
my $install_html = 0;
my $license_accepted = 1;
my $manicheck = 1;

GetOptions(
    'prefix=s' => \$prefix,
    'install-html!' => \$install_html,
    'license-accepted' => \$license_accepted,
    'manifest-check!' => \$manicheck,
) && !@ARGV || usage();

$ActiveState::Prompt::USE_DEFAULT++ if $prefix;
$prefix ||= do {
    my $DEFAULT_PREFIX = sprintf "/opt/%s-%vd", $product, $^V;
    $DEFAULT_PREFIX =~ s/(5\.\d+)\.\d+$/$1/; # cut off revision
    $DEFAULT_PREFIX =~ s/\s/-/g;  # can't have space in name
    if ($^O eq "hpux") {
	$DEFAULT_PREFIX = "/opt/perl";
	$DEFAULT_PREFIX .= "_64" if $Config{use64bitall};
    }
    $DEFAULT_PREFIX;
};

if ($manicheck) {
    print "Checking package...";
    my $errors = 0;
    if (!open(my $manifh, "support/MANIFEST")) {
	print "\n- MANIFEST is missing\n";
	$errors++;
    }
    else {
	while (<$manifh>) {
	    chomp;
	    my %h = map { s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg; $_ }
                    map { /=/ ? split(/=/, $_, 2) : ($_ => 1) }
                    split(" ", $_);

	    if (my $f = $h{file}) {
		my $fh;
		unless (open($fh, "<", $f) && -f $fh) {
		    print "\n" unless $errors;
		    print "- file '$f' missing.\n";
		    $errors++;
		    next;
		}
	    binmode($fh);
		if (my $exp_md5 = $h{md5}) {
		    require Digest::MD5;
		    my $md5 = Digest::MD5->new->addfile($fh)->hexdigest;
		    unless ($md5 eq $exp_md5) {
			print "\n" unless $errors;
			print "- file '$f' corrupt.\n";
			$errors++;
			next;
		    }
		}
	    }
	}
	continue {
	    if ($errors > 10) {
		print "Giving up.\n";
		last;
	    }
	}
    }
    if ($errors) {
	print <<"EOT";

    This installer package does not have the expected content.  Please
    try to download a fresh copy of $product from ActiveState's website
    at <http://www.activestate.com>.  If you still have problems please
    contact us at <support\@activestate\.com>.

EOT
	exit;
    }
    else {
	print "done\n";
    }
}

print <<"EOT";

Welcome to $product

EOT

if (open(my $f, "LICENSE.txt")) {
    my $title = <$f>;
    chomp($title);
    close($f);

    if ($ActiveState::Prompt::USE_DEFAULT) {
	if (!$license_accepted) {
	    die <<EOT;
    In order to install $product you need to agree to the
    $title.  Please read the included
    LICENSE.txt file and confirm agreement by passing the
    --license-accepted option to this installer.

EOT
	}
    }
    local $ActiveState::Prompt::USE_DEFAULT = 1 if $license_accepted;

    print <<"EOT";
    ActivePerl is ActiveState's quality-assured binary build of
    Perl.  In order to install $product you need to agree to
    the $title.

EOT
    if (!yes("Did you read the LICENSE.txt file?", $license_accepted)) {
	if (yes("Do you want to read it now?", 1)) {
	    my $pager = $ENV{PAGER} || "more";
	    print "\n";
	    run("\@$pager", "LICENSE.txt");
	    print "\n";
	}
	else {
	    print "Ok. Aborting installer.\n\n";
	    exit;
	}
    }

    if (!yes("Do you agree to the $title?", $license_accepted)) {
	print "Ok. Aborting installer.\n\n";
	exit;
    }
}

print <<"EOT";

    This installer can install $product in any location of your
    choice. You do not need root privileges.  However, please make sure
    that you have write access to this location.

EOT

GET_PREFIX:
{
    $prefix = prompt("Enter top level directory for install?", $prefix);
    unless ($prefix) {
	print "No directory given, aborting!\n";
	exit 1;
    }

    $prefix =~ s/^\s+//;
    $prefix =~ s/\s+$//;
    $prefix =~ s,^~/,$ENV{HOME}/,;  # expand ~/...

    unless ($prefix =~ m,^/,) {
	print "The given directory must be abosolute, i.e. start with a \"/\".
Please try again!\n\n";
	$prefix = undef;
	redo;
    }

    if ($prefix =~ /\s/) {
        print "The install directory can't have spaces in it.  Please try again!\n\n";
        $prefix = undef;
        redo;
    }

    $prefix =~ s,/+$,,;
    unless (length $prefix) {
	print "Not a valid install directory.  Please try again!\n\n";
	$prefix = undef;
	redo;
    }

    if (-e $prefix) {
	if (-d $prefix) {
	    print <<EOT;
The directory $prefix already exists!

    It is not recommended to install $product on top of an
    earlier installation or mix its location with other products.

EOT
            if (yes("Really install to $prefix?")) {
		print "Ok, but I warned you!\n";
	    }
	    else {
		$prefix = undef;
		print "Ok.\n\n";
		redo;
	    }
	}
	else {
	    print "There is already a file at $prefix, please try again!\n\n";
	    $prefix = undef;
	    redo;
	}
    }
    print "\n";
}

$install_html = (-d "perl/html") && do {
    print <<"EOT";
    The ActivePerl documentation is available in HTML format.  If installed
    it will be available from file://$prefix/html/index.html.
    If not installed you will still be able to read all the basic perl and
    module documentation using the man or perldoc utilities.

EOT

    my $ans = yes("Install HTML documentation", $install_html);
    print "Ok.\n\n";
    $ans;
};

print <<"EOT";
    The typical $product software installation requires 200 megabytes.
    Please make sure enough free space is available before continuing.

EOT

if (yes("Proceed?", 1)) {
    print "Ok.\n\nInstalling $product...\n";
}
else {
    print "Ok. Installation aborted!\n\n";
    exit 1;
}


eval {
    do_install($prefix);
};
if ($@) {
    print "\nInstall of $product to $prefix failed:\n\n";
    print "    $@";

    print <<"EOT";

    Sorry about the inconvenience.  If this looks like a problem with
    the installer please report it to the $product bug database,
    available online at:

        http://bugs.ActiveState.com/$product/

    For general questions or comments about $product, please contact
    us at <support\@activestate\.com>.

    Thank you for trying to install $product!

EOT

    exit 1;
}

print <<"EOT";

$product has been successfully installed at $prefix.

Please modify your startup environment by adding:

   $prefix/site/bin:$prefix/bin to PATH
   $prefix/site/man:$prefix/man to MANPATH

For general questions or comments about $product, please
contact us at <support\@activestate\.com>.

Thank you for using $product!

EOT


sub do_install {
    my $prefix = shift;
    require ActiveState::RelocateTree;
    ActiveState::RelocateTree::relocate2("perl", $prefix);

    # unset these so that perl picks up the installed libperl.so instead of
    # the unrelocated version found in the installer tarball.  These variables
    # are set by 'install.sh' before this script is invoked.
    delete $ENV{LD_LIBRARY_PATH};
    delete $ENV{DYLD_LIBRARY_PATH};

    # Generate the HTML documentation
    if ($install_html) {
	print "Generating HTML documentation...";
	run("\@$prefix/bin/perl", "-MActivePerl::DocTools", "-eUpdateHTML(1)");
	print "done\n";
    }
    else {
	require File::Path;
	File::Path::rmtree("$prefix/html");  # tells DocTools not to update it
    }

    local $ENV{ACTIVEPERL_PPM_SETUP_TIME} = 1;
    run("\@$prefix/bin/perl", "-MActivePerl::PPM::InstallArea", "-e", "ActivePerl::PPM::InstallArea->new('perl')->sync_db(keep_package_version => 1)");

}

sub usage {
    my $msg = <<EOT;
Usage: install.sh [options]

The following options are recognized:

    --prefix <path>     where to install to
    --license-accepted  confirm agreement with terms of LICENSE.txt
    --no-install-html   don't install the HTML documentation
    --no-manifest-check don't check the integrity of this package

If --prefix is specified try to install non-interactively to the given
location, otherwise prompt for install location and options.

EOT
    $msg =~ s/--no-/--no/g if $Getopt::Long::VERSION < 2.33;
    print $msg;
    exit 1;
}
