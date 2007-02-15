package POE::Wheel::Multicast;

=head1 NAME

POE::Wheel::Multicast - POE Wheel for multicast handling.

=head1 SYNOPSIS

  use POE;
  use POE::Wheel::Multicast;
  
  POE::Session->create(
    inline_states => {
      _start => sub {
        my $wheel = $_[HEAP]->{wheel} = POE::Wheel::Multicast->new(
	  LocalAddr => '10.0.0.1',
	  LocalPort => 1234,
	  PeerAddr => '10.0.0.2',
	  PeerPort => 1235,
	  InputEvent => 'input',
	);
	$wheel->put(
	  {
            payload => 'This datagram will go to the default address.',
	  },
	  {
            payload => 'This datagram will go to the explicit address and port I have paired with it.',
	    addr => '10.0.0.3',
	    port => 1236,
	  },
	);
      },
      input => sub {
      	my ($wheel_id, $input) = @_[ARG0, ARG1];
	print "Incoming datagram from $input->{addr}:$input->{port}: '$input->{payload}'\n";
      },
    }
  );

  POE::Kernel->run;

=head1 DESCRIPTION

POE Wheel for multicast handling. This is a subclass of POE::Wheel::UDP

=cut

use 5.006; # I don't plan to support old perl
use strict;
use warnings;

use base 'POE::Wheel::UDP';

use POE;
use Carp;
use Socket;
use Socket::Multicast qw(:all);
use Fcntl;

BEGIN {
	my $ip = getprotobyname( 'ip' );
	eval "sub SOL_IP () { $ip }";
}

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

=head1 Object Methods

=head2 $wheel->mcast_add( MADDR [, IFADDR] )

=cut

sub mcast_add {
	my $self = shift;
	my $mcast_addr = shift;
	my $if_addr = shift;

	$if_addr = "0.0.0.0" unless defined $if_addr;

	my $ip_mreq = pack_ip_mreq( inet_aton( $mcast_addr ), inet_aton( $if_addr ) );

	my $sock = $self->{sock};

	setsockopt( $sock, SOL_IP, IP_ADD_MEMBERSHIP, $ip_mreq )
		or die( "setsockopt IP_ADD_MEMBERSHIP failed: $!" );

	return;
}

sub mcast_drop {
	my $self = shift;
	my $mcast_addr = shift;
	my $if_addr = shift;

	$if_addr = "0.0.0.0" unless defined $if_addr;

	my $ip_mreq = pack_ip_mreq( inet_aton( $mcast_addr ), inet_aton( $if_addr ) );

	my $sock = $self->{sock};

	setsockopt( $sock, SOL_IP, IP_DROP_MEMBERSHIP, $ip_mreq )
		or die( "setsockopt IP_DROP_MEMBERSHIP failed: $!" );

	return;
}


sub mcast_loopback {
	my $self = shift;
	my $loop = shift;

	my $sock = $self->{sock};

	setsockopt( $sock, SOL_IP, IP_MULTICAST_LOOP, pack( 'C', $loop ) )
		or die( "setsockopt IP_MULTICAST_LOOP failed: $!" );

	return;
}

sub mcast_ttl {
	my $self = shift;
	my $ttl = shift;

	my $sock = $self->{sock};

	setsockopt( $sock, SOL_IP, IP_MULTICAST_TTL, pack( 'C', $ttl ) )
		or die( "setsockopt IP_MULTICAST_TTL failed: $!" );

	return;
}

1;
__END__

=head1 Events

=head2 InputEvent

=over

=item ARG0

Contains a hashref with the following keys:

=over

=item addr

=item port

Specifies the address and port from which we received this datagram.

=item payload

The actual contents of the datagram.

=back

=item ARG1

The wheel id for the wheel that fired this event.

=back

=head1 UPCOMING FEATURES

=over

=item *

CFEDDE would like to see filter support in the UDP wheel... I would love to have a piece of pie. Let's see who gets what they want first.

=item *

IPV6 support.

=item *

TTL changing support.

=back

=head1 SEE ALSO

POE

=head1 AUTHOR

Jonathan Steinert E<lt>hachi@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Jonathan Steinert... or Six Apart... I don't know who owns me when I'm at home. Oh well.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
