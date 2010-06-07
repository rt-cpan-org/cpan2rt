#!/usr/bin/perl

use strict;
use warnings;

use CPAN2RT::Test tests => 28;
ok( my $importer = CPAN2RT->new( ), "created importer" );

