package Log::Dispatch::Handle;

use strict;

use Log::Dispatch::Output;

use base qw( Log::Dispatch::Output );
use fields qw( handle );

use vars qw[ $VERSION ];

$VERSION = sprintf "%d.%02d", q$Revision: 1.13 $ =~ /: (\d+)\.(\d+)/;

1;

sub new
{
    my $proto = shift;
    my $class = ref $proto || $proto;

    my %params = @_;

    my $self;
    {
	no strict 'refs';
	$self = bless [ \%{"${class}::FIELDS"} ], $class;
    }

    $self->_basic_init(%params);
    $self->{handle} = $params{handle};

    return $self;
}

sub log_message
{
    my Log::Dispatch::Handle $self = shift;
    my %params = @_;

    $self->{handle}->print($params{message});
}

__END__

=head1 NAME

Log::Dispatch::Handle - Object for logging to IO::Handle objects (and
subclasses thereof)

=head1 SYNOPSIS

  use Log::Dispatch::Handle;

  my $handle = Log::Dispatch::Handle->new( name      => 'a handle',
                                           min_level => 'emerg',
                                           handle    => $io_socket_object );

  $handle->log( level => 'emerg', message => 'I am the Lizard King!' );

=head1 DESCRIPTION

This module supplies a very simple object for logging to some sort of
handle object.  Basically, anything that implements a C<print()>
method can be passed the object constructor and it should work.

=head1 METHODS

=over 4

=item * new(%PARAMS)

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

=item -- handle ($)

The handle object.  This object must implement a C<print()> method.

=item -- callbacks( \& or [ \&, \&, ... ] )

This parameter may be a single subroutine reference or an array
reference of subroutine references.  These callbacks will be called in
the order they are given and passed a hash containing the following keys:

 ( message => $log_message, level => $log_level )

The callbacks are expected to modify the message and then return a
single scalar containing that modified message.  These callbacks will
be called when either the C<log> or C<log_to> methods are called and
will only be applied to a given message once.

=item * log_message( message => $ )

Sends a message to the appropriate output.  Generally this shouldn't
be called directly but should be called through the C<log()> method
(in Log::Dispatch::Output).

=back

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch, Log::Dispatch::ApacheLog, Log::Dispatch::Email,
Log::Dispatch::Email::MailSend, Log::Dispatch::Email::MailSendmail,
Log::Dispatch::Email::MIMELite, Log::Dispatch::File,
Log::Dispatch::Output, Log::Dispatch::Screen, Log::Dispatch::Syslog

=cut
