use File::Find;
use Mojo::Util qw(md5_sum);
find({no_chdir=>1,wanted=>sub{
    return if !-f $File::Find::name;
    print "md5=" . md5_sum(slurp($File::Find::name)) . " " . "file=" . $File::Find::name . "\n";
}},'./perl/');

sub slurp {
    my $path = shift;
    open my $file, '<', $path or Carp::croak qq{Can't open file "$path": $!};
    my $ret = my $content = '';
    while ($ret = $file->sysread(my $buffer, 131072, 0)) { $content .= $buffer }
    Carp::croak qq{Can't read from file "$path": $!} unless defined $ret;
    return $content;
}
