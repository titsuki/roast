use v6;
use Test;

# L<S29/"OS"/"=item run">
# system is renamed to run, so link there. 

plan 18;

my $res;

$res = run($*EXECUTABLE,'-e', '');
ok($res,"run() to an existing program does not die (and returns something true)");
isa-ok($res, Proc, 'run() returns a Proc');
is($res.exitcode, 0, 'run() exit code when successful is zero');

$res = shell("$*EXECUTABLE -e \"\"");
ok($res, "shell() to an existing program does not die (and returns something true)");
isa-ok($res, Proc, 'shell() returns a Proc');
is($res.exitcode, 0, 'shell() exit code when successful is zero');

# RT #117039
$res = run("program_that_does_not_exist_ignore_this_error_please.exe");
ok(!$res, "run() to a nonexisting program does not die (and returns something false)");
isa-ok($res, Proc, 'run() returns a Proc even when not successful');
ok($res.exitcode != 0, 'run() exit code is not zero on failure');

$res = run("program_that_does_not_exist_ignore_errors_please.exe","a","b");
ok(!$res, "run() to a nonexisting program with an argument list does not die (and returns something false)");

$res = shell("program_that_does_not_exist_ignore_this_error_please.exe");
ok(!$res, "shell() to a nonexisting program does not die (and returns something false)");
isa-ok($res, Proc, 'shell() returns a Proc even when not successful');
ok($res.exitcode != 0, 'shell() exit code is not zero on failure');

# RT #104794
{
    use lib 't/spec/packages';
    use Test::Util;

    is_run 'my $a = qx{echo woot>&2}; say "___ $a ___"',
        {
            out => "___  ___\n",
            err => / ^ "woot" [\r]? \n $ /,
        },
        'qx{} does not capture stderr';
}

# RT #115390
{
    my $rt115390;
    for 1..100 -> $i {
        $rt115390 += $i.perl;
        run "$*EXECUTABLE", "-v";
        1;
    }
    is $rt115390, 5050, 'no crash with run() in loop; run() in sink context';
    $rt115390 = 0;
    for 1..100 -> $i {
        $rt115390 += $i.perl;
        my $var = run "$*EXECUTABLE", "-v";
        1;
    }
    is $rt115390, 5050, 'no crash with run() in loop; run() not in sink context';
}

# all these tests feel like bogus, what are we testing here???
chdir "t";
my $cwd;
BEGIN { $cwd = $*DISTRO.is-win ?? 'cd' !! 'pwd' };
ok((qqx{$cwd} ne BEGIN qqx{$cwd}), 'qqx{} is affected by chdir()');
isnt run("dir", "t"), BEGIN { run("dir", "t") }, 'run() is affected by chdir()';

# vim: ft=perl6
