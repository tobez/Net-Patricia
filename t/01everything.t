#!/usr/bin/perl -w

use Test::More;

use strict qw(vars);
use diagnostics;

plan tests => 32;

use Net::Patricia;

our $debug = 1;

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $t = new Net::Patricia;

isa_ok($t, 'Net::Patricia', 'creating base object');

ok($t->add_string('127.0.0.0/8'), 'adding 127.0.0.0/8');

is($t->match_string("127.0.0.1"), '127.0.0.0/8', 'looking for 127.0.0.1');

is($t->match_integer(2130706433), '127.0.0.0/8', 'looking for 2130706433');

ok(!$t->match_string("10.0.0.1"), 'looking for 10.0.0.1');

ok(!$t->match_integer(42), 'looking for 42');

{
   my $ten = new Thingy 10;
   my $twenty = new Thingy 20;
ok($t->add_string('10.0.0.0/8', $ten), 'adding 10.0.0.0/8');
}

diag "Destructor 10 should *not* have run yet.\n" if $debug;

foreach my $subnet (qw(10.42.42.0/31 10.42.42.0/26 10.42.42.0/24 10.42.42.0/32 10.42.69.0/24)) {
   ok($t->add_string($subnet), "adding $subnet");
}

my $str1 = $t->match_string('10.42.42.0/24');
my $str2 = $t->match_string('10.42.69.0/24');

isnt($str1, $str2, 'compare matches from 10.42.42.0/24 and 10.42.69.0/24');

is(${$t->match_integer(168430090)}, 10, 'looking for 168430090');

ok($t->match_string("10.0.0.1"), 'looking for 10.0.0.1');

ok(!$t->match_exact_integer(167772160), 'looking for 167772160');

ok($t->match_exact_integer(167772160, 8), 'looking for 167772160, 8');

is(${$t->match_exact_string("10.0.0.0/8")}, 10, 'looking for 10.0.0.0/8');

ok(!$t->remove_string("42.0.0.0/8"), 'removing 42.0.0.0/8');

is(${$t->remove_string("10.0.0.0/8")}, 10, 'removing 10.0.0.0/8');

diag "Destructor 10 should have just run.\n" if $debug;

ok(!$t->match_exact_integer(167772160, 8), 'looking for exact 167772160, 8');

# print "YOU SHOULD SEE A USAGE ERROR HERE:\n";
# $t->match_exact_integer(167772160, 8, 10);

is($t->climb_inorder(sub { diag "climbing at $_[0]\n" }), 6, 'climb inorder');

ok($t->climb, 'climb');

eval '$t->add_string("_")'; # invalid key
like($@, qr/invalid/, 'adding "_"');

ok($t->add_string('0/0'), 'add 0/0');

ok($t->match_string("10.0.0.1"), 'lookup 10.0.0.1');

my @a = $t->add_cidr('211.200.0.0-211.205.255.255', 'cidr block!');

is(@a, 2, 'adding cidr block');

is($t->match_string('211.202.0.1'), 'cidr block!', 'looking for 211.202.0.1');

@a = $t->remove_cidr('211.200.0.0-211.205.255.255');

is(@a, 2, 'removing cidr block');

undef $t;

$t = new Net::Patricia(AF_INET6);

isa_ok($t, 'Net::Patricia::AF_INET6', 'constructing a Net::Patrica::AF_INET6');

ok($t->add_string('2001:220::/35', 'hello, world'), 'adding 2001:220::/35');

is($t->match_string('2001:220::/128'), 'hello, world', 'looking for 2001:220::/128');

undef $t;

done_testing();

package Thingy;

use diagnostics;

sub new {
   my $class = shift(@_);
   my $self = shift(@_);
   return bless \$self, $class;
}

sub DESTROY {
   my $self = shift(@_);
   print STDERR "$$self What a world, what a world...\n";
}
