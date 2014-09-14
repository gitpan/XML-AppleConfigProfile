#!perl -T

# Test suite 12-data: Tests against the Data payload type.
# 
# Copyright © 2014 A. Karl Kornel.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either: the GNU General Public License as published
# by the Free Software Foundation; or the Artistic License.
# 
# See http://dev.perl.org/licenses/ for more information.

use 5.14.4;
use strict;
use warnings FATAL => 'all';


package Local::Data;

use File::Temp;
use Readonly;
use XML::AppleConfigProfile::Payload::Common;
use XML::AppleConfigProfile::Payload::Types qw($ProfileData);

use base qw(XML::AppleConfigProfile::Payload::Common);

Readonly our %payloadKeys => (
    'dataField' => {
        type => $ProfileData,
        description => 'A field containing data.',
    },
);


package main;

use Config;
use Readonly;
use Test::Exception;
use Test::More;
use XML::AppleConfigProfile::Payload::Common;





#plan tests => 0;

plan skip_all => 'Still in development';

__END__

# Test all of the numbers that should be good.
foreach my $guid_group (@tests) {
    Readonly my $guid_as_string => $guid_group->[0];
    Readonly my $guid_as_hex => $guid_group->[1];
    
    # Make sure we're reading GUIDs properly
    my $guid1 = Data::GUID->from_string($guid_as_string);
    my $guid2 = Data::GUID->from_hex($guid_as_hex);
    cmp_ok($guid1, '==', $guid2,
           'Comparing ' . $guid_as_string . ' and ' . $guid_as_hex);
    undef $guid1;
    undef $guid2;
    
    # Keep a GUID copy for reference
    my $guid_reference = Data::GUID->from_string($guid_as_string);
    
    # See if our payload can accept the Data::GUID object
    my $guid1a = Data::GUID->from_string($guid_as_string);
    my $object = new Local::UUID;
    my $payload = $object->payload;
    lives_ok {$payload->{uniqueField} = $guid1a} 'Write object';
    my $read_guid = $payload->{uniqueField};
    ok(defined($read_guid), 'Read object back');
    cmp_ok($read_guid, '==', $guid_reference, 'Compare objects');
    undef $guid1a;
    undef $object;
    undef $payload;
    undef $read_guid;
    
    # Now, let's try again, but with a string as the payload input
    $object = new Local::UUID;
    $payload = $object->payload;
    lives_ok {$payload->{uniqueField} = $guid_as_string} 'Write string';
    $read_guid = $payload->{uniqueField};
    ok(defined($read_guid), 'Read was-string-now-object back');
    cmp_ok($read_guid, '==', $guid_reference, 'Compare string');
    undef $object;
    undef $payload;
    undef $read_guid;
    
    # And now, once again, but with the hex value as the payload input
    # (This is our last payload class test, so keep $object and $payload
    # around for plist testing)
    $object = new Local::UUID;
    $payload = $object->payload;
    lives_ok {$payload->{uniqueField} = $guid_as_hex} 'Write hex';
    $read_guid = $payload->{uniqueField};
    ok(defined($read_guid), 'Read was-hex-now-object back');
    cmp_ok($read_guid, '==', $guid_reference, 'Compare hex');
#    undef $object;
#    undef $payload;
    undef $read_guid;
    
    # TODO: Create Data::UUID object and use that for testing
    
    # TODO: Create base64-encoded version and use that for testing
    
    # Make sure we get a correct plist out
    my $plist;
    lives_ok {$plist = $object->plist} 'Convert to plist';
    cmp_ok($plist->value->{uniqueField}->value, 'eq',
           $payload->{uniqueField}->as_string, 'plist uuid matches'
    );
}


# Make sure each of the baddies fails to process
my $i = 1;
foreach my $baddie (@baddies) {
    my $object = new Local::UUID;
    my $payload = $object->payload;
    
    # Make sure every method of reading fails
    dies_ok {$payload->{uniqueField} = $baddie} "Non-UUID $i";
    
    $i++;
}


# Done!
done_testing();