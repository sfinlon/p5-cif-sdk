package CIF::SDK::Format;

use strict;
use warnings;

use Mouse::Role;

requires qw/understands process/;

use constant DEFAULT_COLS   => [ 
    'tlp','group','reporttime','observable','cc','asn','confidence','tags','description','rdata','provider','altid_tlp', 'altid'
];

has 'columns'   => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { DEFAULT_COLS() },
    reader  => 'get_columns',
);

1;