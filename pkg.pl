use File::Find;
use Mojo::Util qw(md5_sum slurp);
find({no_chdir=>1,wanted=>sub{
    return if !-f $File::Find::name;
    print "md5=" . md5_sum(slurp($File::Find::name)) . " " . "file=" . $File::Find::name . "\n";
}},'./perl/');
