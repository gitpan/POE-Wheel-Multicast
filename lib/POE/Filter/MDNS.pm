package POE::Filter::MDNS;

use strict;
use warnings;

use base 'POE::Filter::DNS';

use Net::DNS::Packet;

sub get_one {
	my $self = shift;
	
	# This is a hack to make Net::DNS::Packet pass the UTF-8 data through, rather than escaping it all.
	no warnings 'redefine';
#       local $SIG{__WARN__} = sub { stuff }; # a cute way to prevent -W from still emitting warnings
	local *Net::DNS::Packet::dn_expand = \&dn_expand;

	return $self->SUPER::get_one(@_);
}

sub dn_expand {
        my ($packet, $offset) = @_; # $seen from $_[2] for debugging
        my $name = "";
        my $len;
        my $packetlen = length $$packet;
        my $int16sz = Net::DNS::INT16SZ();

        # Debugging
        # warn "USING PURE PERL dn_expand()\n";
        #if ($seen->{$offset}) {
        #       die "dn_expand: loop: offset=$offset (seen = ",
        #            join(",", keys %$seen), ")\n";
        #}
        #$seen->{$offset} = 1;

        while (1) {
                return (undef, undef) if $packetlen < ($offset + 1);

                $len = unpack("\@$offset C", $$packet);

                if ($len == 0) {
                        $offset++;
                        last;
                }
                elsif (($len & 0xc0) == 0xc0) {
                        return (undef, undef)
                                if $packetlen < ($offset + $int16sz);

                        my $ptr = unpack("\@$offset n", $$packet);
                        $ptr &= 0x3fff;
                        my($name2) = dn_expand($packet, $ptr); # pass $seen for debugging

                        return (undef, undef) unless defined $name2;

                        $name .= $name2;
                        $offset += $int16sz;
                        last;
                }
                else {
                        $offset++;

                        return (undef, undef)
                                if $packetlen < ($offset + $len);

                        my $elem = substr($$packet, $offset, $len);

                        $name .= $elem . ".";

                        $offset += $len;
                }
        }

        $name =~ s/\.$//;
        return ($name, $offset);
}


1;
