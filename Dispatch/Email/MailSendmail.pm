package Log::Dispatch::Email::MailSendmail;

use strict;

use Log::Dispatch::Email;

use base qw( Log::Dispatch::Email );

use Carp ();
use Mail::Sendmail ();

use vars qw[ $VERSION ];

$VERSION = sprintf "%d.%03d", q$Revision: 1.1.1.1 $ =~ /: (\d+)\.(\d+)/;

1;

sub send_email
{
    my Log::Dispatch::Email::MailSendmail $self = shift;
    my %params = @_;

    my %mail = ( To      => join ',', @{ $self->{to} },
		 Subject => $self->{subject},
		 Message => $params{message},
	       );

    $mail{From} = $self->{from} if defined $self->{from};

    Mail::Sendmail::sendmail(%mail)
	or Carp::carp("Error sending mail: $Mail::Sendmail::error");
}

__END__

=head1 NAME

Log::Dispatch::Email::MailSendmail - Subclass of Log::Dispatch::Email
that uses the Mail::Sendmail module

=head1 SYNOPSIS

  use Log::Dispatch::Email::MailSendmail;

  my $email = Log::Dispatch::Email::MailSendmail->new( name => 'email',
                                                       min_level => 'emerg',
                                                       to => [ qw( foo@bar.com bar@baz.org ) ],
                                                       subject => 'Oh no!!!!!!!!!!!', );

  $email->log( message => 'Something bad is happening', level => 'emerg' );

=head1 DESCRIPTION

This is a subclass of Log::Dispatch::Email that implements the
send_email method using the Mail::Sendmail module.

=head1 METHODS

=over 4

=item * new

This method takes a hash of parameters.  The following options are
valid:

=item -- name ($)

The name of the object (not the filename!).  Required.

=item -- min_level ($)

The minimum logging level this object will accept.  See the
Log::Dispatch documentation for more information.  Required.

=item -- max_level ($)

The maximum logging level this obejct will accept.  See the
Log::Dispatch documentation for more information.  This is not
required.  By default the maximum is the highest possible level (which
means functionally that the object has no maximum).

=item -- subject ($)

The subject of the email messages which are sent.  Defaults to "$0:
log email"

=item -- to ($ or \@)

Either a string or a list reference of strings containing email
addresses.  Required.

=item -- from ($)

A string containing an email address.  This is optional and may not
work with all mail sending methods.

=item -- buffered (0 or 1)

This determines whether the object sends one email per message it is
given or whether it stores them up and sends them all at once.  The
default is to buffer messages.

=item * log( level => $, message => $ )

Sends a message if the level is greater than or equal to the object's
minimum level.

=back

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch, Log::Dispatch::Email, Log::Dispatch::Email::MailSend,
Log::Dispatch::Email::MIMELite, Log::Dispatch::File,
Log::Dispatch::Handle, Log::Dispatch::Output, Log::Dispatch::Screen,
Log::Dispatch::Syslog

=cut
