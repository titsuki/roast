use v6;
use Test;

plan 4;

# RT #123520
# This test comes first in the file so it's the first to start any threads;
# this means we can test the actual bug in the ticket.
{
    my @order;
    await Promise.anyof(
        start { sleep 3; @order.push(3) },
        Promise.in(1).then({ @order.push(1) }));
    sleep 1;
    @order.push(2);
    sleep 2;
    #?rakudo.jvm todo 'got: "3, 1, 2", RT #123520'
    is @order, (1, 2, 3), 'Scheduler did not cause things to run in wrong order';
}

{
    my $start = now;
    my $p = Promise.in(1);
    is $p.result, True, "Promise.in result is True";
    ok now - $start >= 1, "Promise.in took long enough";
}

subtest 'Promise.in with negative value works' => {
    plan 1;
    await Promise.in(-rand).then: { pass ".then'ed code ran" }
}
