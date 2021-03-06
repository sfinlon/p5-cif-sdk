package CIF::SDK::Feed::Ipv4;

use strict;
use warnings;

use Mouse;
use Net::Patricia;

with 'CIF::SDK::Feed';

my @perm_whitelist = (
    "0.0.0.0/8",
    "10.0.0.0/8",
    "127.0.0.0/8",
    "192.168.0.0/16",
    "169.254.0.0/16",
    "192.0.2.0/24",
    "224.0.0.0/4",
    "240.0.0.0/5",
    "248.0.0.0/5",
);

sub normalize {
    my $addr = shift;

    my @bits = split(/\./,$addr);
    foreach(@bits){
        if(/^0+\/(\d+)$/){
            $_ = '0/'.$1;
        } else {
            next if(/^0$/);
            next unless(/^0{1,2}/);
            $_ =~ s/^0{1,2}//;
        }
    }
    return join('.',@bits);
}

sub understands {
	my $self = shift;
	my $args = shift;
	
	return unless($args->{'otype'});
	return 1 if($args->{'otype'} eq 'ipv4');
}

sub process {
	my $self = shift;
	my $args = shift;
	
	my $whitelist = Net::Patricia->new();
	$whitelist->add_string($_) foreach @perm_whitelist;
	$whitelist->add_string($_->{'observable'}) foreach (@{$args->{'whitelist'}});
	
	my @list;
	
	foreach (@{$args->{'data'}}){
	    $_->{'observable'} = normalize($_->{'observable'});
	    next if($self->_tag_contains_whitelist($_->{'tags'}));
	   	next if($whitelist->match_string($_->{'observable'}));
	   	if($_->{'observable'} =~ /^\S+\/(\d+)$/){
	   	    next if($1 < 8);
	   	}
	   	push(@list,$_);
	}
	return \@list
}

__PACKAGE__->meta()->make_immutable();

1;