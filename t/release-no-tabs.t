
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.08

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Log/Dispatch.pm',
    'lib/Log/Dispatch/ApacheLog.pm',
    'lib/Log/Dispatch/Base.pm',
    'lib/Log/Dispatch/Code.pm',
    'lib/Log/Dispatch/Conflicts.pm',
    'lib/Log/Dispatch/Email.pm',
    'lib/Log/Dispatch/Email/MIMELite.pm',
    'lib/Log/Dispatch/Email/MailSend.pm',
    'lib/Log/Dispatch/Email/MailSender.pm',
    'lib/Log/Dispatch/Email/MailSendmail.pm',
    'lib/Log/Dispatch/File.pm',
    'lib/Log/Dispatch/File/Locked.pm',
    'lib/Log/Dispatch/Handle.pm',
    'lib/Log/Dispatch/Null.pm',
    'lib/Log/Dispatch/Output.pm',
    'lib/Log/Dispatch/Screen.pm',
    'lib/Log/Dispatch/Syslog.pm',
    't/00-compile.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/01-basic.t',
    't/02-email-exit.t',
    't/03-short-syntax.t',
    't/04-binmode.t',
    't/05-close-after-write.t',
    't/06-syslog.t',
    't/author-pod-spell.t',
    't/email-exit-helper.pl',
    't/lib/Log/Dispatch/TestUtil.pm',
    't/release-cpan-changes.t',
    't/release-eol.t',
    't/release-no-tabs.t',
    't/release-pod-coverage.t',
    't/release-pod-no404s.t',
    't/release-pod-syntax.t',
    't/release-portability.t',
    't/sendmail'
);

notabs_ok($_) foreach @files;
done_testing;
