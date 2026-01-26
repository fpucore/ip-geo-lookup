#!/usr/bin/perl
# ip-geo-lookup script, Script version 1.2

use strict;
use warnings;

# Launch ip-geo-lookup
my $cmd = "kitty -e /bin/bash -c \"ip-geo-lookup; echo 'Press Enter to exit'; read\"";
system($cmd) == 0 or warn "Failed to launch ip-geo-lookup: $!";

print "Exiting now.\n";
print "\n";
