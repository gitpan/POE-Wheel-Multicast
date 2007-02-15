package POE::Filter::DNS;

use strict;
use warnings;

use base 'POE::Filter';

use Net::DNS::Packet;

sub new {
	my $class = shift;

	my $self = bless {
		buffer => '',
	}, (ref $class || $class);

	return $self;
}

sub get_one_start {
	my $self = shift;
	my $blocks = shift;

	my $buffer = join '', @$blocks;
	if (defined($POE::Filter::DATAGRAM) && $POE::Filter::DATAGRAM) {
		$self->{buffer} = $buffer;
	}
	else {
		$self->{buffer} .= $buffer;
	}
	return;
}

sub get_one {
	my $self = shift;
	my $bufferref = \$self->{buffer};
	while (length( $$bufferref )) {
		my ($packet, $err) = Net::DNS::Packet->new( $bufferref, 0 );
		if ($err) {
			warn "$err\n";
			return [];
		}
		my $size = length( $packet->data );
		unless($size) {
			warn "Bad size";
			return [];
		}
		substr( $$bufferref, 0, $size ) = "";

		return [$packet];
	}
	# No more bytes left.
	return [];
}

sub get_pending {
	my $self = shift;
	return $self->{buffer};
}

sub put {
	my $self = shift;
	my $packets = shift;

	my @blocks;
	foreach my $packet (@$packets) {
		push @blocks, $packet->data;
	}
	return \@blocks;
}

1;
