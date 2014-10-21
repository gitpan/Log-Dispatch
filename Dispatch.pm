package Log::Dispatch;

require 5.005;

use strict;
use vars qw[ $VERSION %LEVELS ];

use base qw( Log::Dispatch::Base );
use fields qw( outputs callbacks );

use Carp ();

$VERSION = '1.76';

1;

BEGIN
{
    no strict 'refs';
    foreach my $l ( qw( debug info notice warning err error crit critical alert emerg emergency ) )
    {
	*{$l} = sub { my Log::Dispatch $self = shift;
		      $self->log( level => $l, message => shift ); };
	$LEVELS{$l} = 1;
    }
}

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

    my @cb = $self->_get_callbacks(%params);
    $self->{callbacks} = \@cb if @cb;

    return $self;
}

sub add
{
    my Log::Dispatch $self = shift;
    my $object = shift;

    # Once 5.6 is more established start using the warnings module.
    if (exists $self->{outputs}{$object->name} && $^W)
    {
	Carp::carp("Log::Dispatch::* object ", $object->name, " already exists.");
    }

    $self->{outputs}{$object->name} = $object;
}

sub remove
{
    my Log::Dispatch $self = shift;
    my $name = shift;

    return delete $self->{outputs}{$name};
}

sub log
{
    my Log::Dispatch $self = shift;
    my %params = @_;

    $params{message} = $self->_apply_callbacks(%params)
	if $self->{callbacks};

    foreach (keys %{ $self->{outputs} })
    {
	$params{name} = $_;
	$self->_log_to(%params);
    }
}

sub log_to
{
    my Log::Dispatch $self = shift;
    my %params = @_;

    $params{message} = $self->_apply_callbacks(%params)
	if $self->{callbacks};

    $self->_log_to(%params);
}

sub _log_to
{
    my Log::Dispatch $self = shift;
    my %params = @_;
    my $name = delete $params{name};

    if (exists $self->{outputs}{$name})
    {
	$self->{outputs}{$name}->log(@_);
    }
    else
    {
	Carp::carp("Log::Dispatch::* object named '$name' not in dispatcher\n");
    }
}

sub level_is_valid
{
    shift;
    return $LEVELS{ shift() };
}

__END__

=head1 NAME

Log::Dispatch - Dispatches messages to multiple Log::Dispatch::* objects

=head1 SYNOPSIS

  use Log::Dispatch;

  my $dispatcher = Log::Dispatch->new;

  $dispatcher->add( Log::Dispatch::File->new( name => 'file1',
                                              min_level => 'debug',
                                              filename => 'logfile' ) );

  $dispatcher->log( level => 'info',
                    message => 'Blah, blah' );

  my $sub = sub { my %p = @_;  return reverse $p{message}; };
  my $reversing_dispatcher = Log::Dispatch->new( callbacks => $sub );

=head1 DESCRIPTION

This module manages a set of Log::Dispatch::* objects, allowing you to
add and remove output objects as desired.

=head1 METHODS

=over 4

=item * new

Returns a new Log::Dispatch object.  This method takes one optional
parameter:

=item -- callbacks( \& or [ \&, \&, ... ] )

This parameter may be a single subroutine reference or an array
reference of subroutine references.  These callbacks will be called in
the order they are given and passed a hash containing the following keys:

 ( message => $log_message, level => $log_level )

It's a hash in case I need to add parameters in the future.

The callbacks are expected to modify the message and then return a
single scalar containing that modified message.  These callbacks will
be called when either the C<log> or C<log_to> methods are called and
will only be applied to a given message once.  If they do not return
the message then you will get no output.  Make sure to return the
message!

=item * add( Log::Dispatch::* OBJECT )

Adds a new a Log::Dispatch::* object to the dispatcher.  If an object
of the same name already exists, then that object is replaced.  A
warning will be issued if the 'C<-w>' flag is set.

NOTE: This method can really take any object that has methods called
'name' and 'log'.

=item * remove($)

Removes the object that matches the name given to the remove method.
The return value is the object being removed or undef if no object
matched this.

=item * log( level => $, message => $ )

Sends the message (at the appropriate level) to all the
Log::Dispatch::* objects that the dispatcher contains (by calling the
C<log_to> method repeatedly).

=item * log_to( name => $, level => $, message => $ )

Sends the message only to the named object.

=item * level_is_valid( $string )

Returns true or false to indicate whether or not the given string is a
valid log level.  Can be called as either a class or object method.

=back

=head1 CONVENIENCE METHODS

Version 1.6 of Log::Dispatch adds a number of convenience methods for
logging.  You may now call any valid log level (including valid
abbreviations) as a method on the Log::Dispatch object with a single
argument that is the message to be logged.  This is converted into a
call to the C<log> method with the appropriate level.

For example:

 $dispatcher->alert('Strange data in incoming request');

translates to:

 $dispatcher->log( level => 'alert', message => 'Strange data in incoming request' );

One important caveat about these methods is that its not that forwards
compatible.  If I were to add more parameters to the C<log> call, it
is unlikely that these could be integrated into these methods without
breaking existing uses.  This probably means that any future
parameters to the C<log> method will never be integrated into these
convenience methods.  OTOH, I don't see any immediate need to expand
the parameters given to the C<log> method.

=head2 Log Levels

The log levels that Log::Dispatch uses are taken directly from the
syslog man pages (except that I expanded them to full words).  Valid
levels are:

 debug
 info
 notice
 warning
 error
 critical
 alert
 emergency

Alternately, the numbers 0 through 7 may be used (debug is 0 and
emergency is 7).  The syslog standard of 'err', 'crit', and 'emerg'
is also acceptable.

=head1 USAGE

This logging system is designed to be used as a one-stop logging
system.  In particular, it was designed to be easy to subclass so that
if you want to handle messaging in a way other than one of the modules
used here, you should be able to implement this with minimal effort.

The basic idea behind Log::Dispatch is that you create a Log::Dispatch
object and then add various logging objects to it (such as a file
logger or screen logger).  Then you call the C<log> method of the
dispatch object, which passes the message to each of the objects,
which in turn decide whether or not to accept the message and what to
do with it.

This makes it possible to call single method and send a message to a
log file, via email, to the screen, and anywhere else all in one
simple command.

The logging levels that Log::Dispatch uses are borrowed from the
standard UNIX syslog levels, except that where syslog uses partial
words ('err') Log::Dispatch also allows the use of the full word as
well ('error').

Please note that because this code uses pseudo-hashes and compile-time
object typing that it will only run under Perl 5.005 or greater.

=head2 Making your own logging objects

Making your own logging object is generally as simple as subclassing
Log::Dispatch::Output and overriding the C<new> and C<log> methods.
See the L<Log::Dispatch::Output> docs for more details.

If you would like to create your own subclass for sending email then
it is even simpler.  Simply subclass L<Log::Dispatch::Email> and
override the C<send_email> method.  See the L<Log::Dispatch::Email>
docs for more details.

=head2 Why doesn't Log::Dispatch add a newline to the message?

A few people have written email to me asking me to add something that
would tack a newline onto the end of all messages that don't have one.
This will never happen.  There are several reasons for this.  First of
all, Log::Dispatch was designed as a simple system to broadcast a
message to multiple outputs.  It does not attempt to understand the
message in any way at all.  Adding a newline implies an attempt to
understand something about the message and I don't want to go there.
Secondly, this is not very cross-platform and I don't want to go down
the road of testing Config values to figure out what to tack onto
messages based on OS.

I think people's desire to do this is because they are too focused on
just the logging to files aspect of this module.  In this case
newlines make sense.  However, imagine someone is using this module to
log to a remote server and the interactions between the client and
server use newlines as part of the control flow.  Casually adding a
newline could cause serious problems.

However, the 1.2 release adds the callbacks parameter for the
Log::Dispatch object which you can easily use to add newlines to
messages if you so desire.

=head1 RELATED MODULES

=head2 Log::Dispatch::Tk

Dominique Dumont has written Log::Dispatch::Tk which allows log
message to show up in a window.  This code is available from CPAN.

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch::ApacheLog, Log::Dispatch::Email,
Log::Dispatch::Email::MailSend, Log::Dispatch::Email::MailSendmail,
Log::Dispatch::Email::MIMELite, Log::Dispatch::File,
Log::Dispatch::Handle, Log::Dispatch::Output, Log::Dispatch::Screen,
Log::Dispatch::Syslog

=cut
