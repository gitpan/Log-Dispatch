#!perl

BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

# This file was automatically generated by Dist::Zilla::Plugin::Test::Pod::Coverage::Configurable.

use Test::Pod::Coverage 1.08;
use Test::More 0.88;
use Pod::Coverage::TrustPod;

my %skip = map { $_ => 1 } qw( Log::Dispatch::ApacheLog Log::Dispatch::Conflicts );

my @modules;
for my $module ( all_modules() ) {
    next if $skip{$module};

    push @modules, $module;
}

plan skip_all => 'All the modules we found were excluded from POD coverage test.'
    unless @modules;

plan tests => scalar @modules;

my %trustme = (
             'Log::Dispatch::File' => [
                                      qr/APPEND$/
                                    ],
             'Log::Dispatch' => [
                                qr/^(?:warn|err|crit|emerg)$/,
                                qr/^is_\w+$/
                              ],
             'Log::Dispatch::Output' => [
                                        qr/^new$/
                                      ]
           );

for my $module ( sort @modules ) {
    pod_coverage_ok(
        $module,
        {
            coverage_class => 'Pod::Coverage::TrustPod',
            trustme        => $trustme{$module} || [],
        },
        "pod coverage for $module"
    );
}

done_testing();
