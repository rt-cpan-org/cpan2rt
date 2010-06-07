#!/usr/bin/perl

use strict;
use warnings;

use CPAN2RT::Test tests => 28;
my $test_class = 'CPAN2RT::Test';

ok( my $importer = CPAN2RT->new( ), "created importer" );

# user has no email and no other user with his cpan email
{
    my $user = $test_class->load_or_create_user(
        Name => 'A',
        Privileged => 1,
    );
    $importer->load_or_create_user(
        A => 'A A' => 'A@xxx.com',
    );
    $user = RT::User->new( $RT::SystemUser );
    $user->Load('A');
    is( $user->Name, 'A', 'Name is correct' );
    is( $user->RealName, 'A A', 'Real name updated' );
    is( $user->EmailAddress, 'A@cpan.org', 'Email address is set to cpan\'s' );
}

# user has email and it's no his cpan's
{
    my $user = $test_class->load_or_create_user(
        Name => 'B',
        EmailAddress => 'B@xxx.com',
        Privileged => 1,
    );
    $importer->load_or_create_user(
        B => 'B B' => 'B@yyy.com',
    );
    $user = RT::User->new( $RT::SystemUser );
    $user->Load('B');
    is( $user->Name, 'B', 'Name is correct' );
    is( $user->RealName, 'B B', 'Real name updated' );
    is( $user->EmailAddress, 'B@xxx.com', 'Email address left alone' );

    my $merged_user = RT::User->new( $RT::SystemUser );
    $merged_user->LoadByEmail('B@cpan.org');

    is( $merged_user->id, $user->id, 'merged user with email B@cpan.org has been created' );

}


# no 'C' user, but user with 'C@cpan.org'
{
    my $user = $test_class->load_or_create_user(
        Name => 'C@cpan.org',
        EmailAddress => 'C@cpan.org',
        Privileged => 1,
    );
    $importer->load_or_create_user(
        C => 'C C' => 'C@xxx.com',
    );
    $user = RT::User->new( $RT::SystemUser );
    $user->Load('C');
    is( $user->Name, 'C', 'Name is correct' );
    is( $user->RealName, 'C C', 'Real name updated' );
    is( $user->EmailAddress, 'C@cpan.org', 'Email address is correct' );
}

# user has email @cpan.org, but it doesn't match his CPANID
# some people use it as spam protection
{
    my $user = $test_class->load_or_create_user(
        Name => 'D',
        EmailAddress => 'QWE@cpan.org',
        Privileged => 1,
    );
    $importer->load_or_create_user(
        D => 'D D' => 'QWE@cpan.org',
    );
    $user = RT::User->new( $RT::SystemUser );
    $user->Load('D');
    is( $user->Name, 'D', 'Name is correct' );
    is( $user->RealName, 'D D', 'Real name updated' );
    is( $user->EmailAddress, 'D@cpan.org', 'Email address has been changed' );

    $user = RT::User->new( $RT::SystemUser );
    $user->LoadByEmail('QWE@cpan.org');
    ok(!$user->id, "no more fake user");
}

