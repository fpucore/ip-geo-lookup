#!/usr/bin/env perl

use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use File::Path qw(make_path);

# ============================
# Version / Credits
# ============================
my $VERSION = "1.2";

# ============================
# Configuration
# ============================
my $MAP_URL   = "http://127.0.0.1/world_map.jpg";
my $CACHE_DIR = "$ENV{HOME}/.cache/ip_geo_lookup";
my $MAP_IN    = "$CACHE_DIR/world_map.jpg";
my $MAP_OUT   = "$CACHE_DIR/world_map_pinned.png";
my $CACHE_IP  = "$CACHE_DIR/ip_cache.txt";

# ============================
# Country centroids (lat, lon)
# ============================
my %COUNTRY_CENTROID = (
    US => [ 39.8,  -98.6 ],
    CA => [ 56.1, -106.3 ],
    MX => [ 23.6, -102.6 ],
    GB => [ 55.4,   -3.4 ],
    FR => [ 46.2,    2.2 ],
    DE => [ 51.2,   10.4 ],
    NL => [ 52.1,    5.3 ],
    AU => [-25.3,  133.8 ],
    BR => [-14.2,  -51.9 ],
    RU => [ 61.5,  105.3 ],
    CN => [ 35.9,  104.2 ],
    IN => [ 21.1,   78.0 ],
    JP => [ 36.2,  138.3 ],
    ZA => [-30.6,   22.9 ],
    ID => [ -2.5,  118.0 ],
    IQ => [ 33.2232, 43.6793 ],
);

# ============================
# Helpers
# ============================
sub run {
    my ($cmd) = @_;
    my $out = `$cmd 2>/dev/null`;
    chomp $out;
    return $out;
}

make_path($CACHE_DIR) unless -d $CACHE_DIR;

# ============================
# Header
# ============================
print BOLD MAGENTA, "IP → Country → World Map Pin v$VERSION\n", RESET;
print BOLD MAGENTA, "Created with AI. Powered by Apache.\n", RESET;
print BOLD MAGENTA, "Map source: Wikimedia Commons, Public Domain\n\n", RESET;

print "---------------------------------\n";
print BOLD CYAN, "🌍 IP → Country → World Map Pin\n", RESET;
print "---------------------------------\n";

# ============================
# Step 1: Fetch map (cached)
# ============================
unless (-f $MAP_IN) {
    print BOLD GREEN, "Fetching map from Apache server...\n", RESET;
    system("curl -s -o '$MAP_IN' '$MAP_URL'") == 0
        or die BOLD RED . "Failed to download map\n" . RESET;
}

# ============================
# Step 2: Get public IP
# ============================
print BOLD GREEN, "Fetching public IP...\n", RESET;
my $ip = run("curl -s icanhazip.com");

die BOLD RED . "Failed to get IP\n" . RESET
    unless $ip =~ /^\d+\.\d+\.\d+\.\d+$/;

print "IP: ", BOLD YELLOW, "$ip\n", RESET;

# ============================
# Step 3: Cache lookup
# ============================
my ($cc, $country);

if (-f $CACHE_IP) {
    open my $fh, "<", $CACHE_IP;
    my $line = <$fh>;
    close $fh;

    if ($line) {
        my ($cached_ip, $cached_cc, $cached_country) = split /\|/, $line;
        if ($cached_ip eq $ip) {
            ($cc, $country) = ($cached_cc, $cached_country);
            print BOLD GREEN,
              "Cache hit: Using $country ($cc)\n", RESET;
        }
    }
}

# ============================
# Step 4: GeoIP lookup
# ============================
unless ($cc) {
    print BOLD GREEN, "Looking up country...\n", RESET;

    my $geo = run("geoiplookup $ip")
        or die BOLD RED . "GeoIP lookup failed\n" . RESET;

    if ($geo =~ /:\s*([A-Z]{2}),\s*(.+)$/) {
        ($cc, $country) = ($1, $2);
    } else {
        die BOLD RED . "Could not parse GeoIP output\n" . RESET;
    }

    open my $fh, ">", $CACHE_IP;
    print $fh "$ip|$cc|$country";
    close $fh;
}

print "Country: $country ($cc)\n";

die BOLD RED . "No centroid for $cc\n" . RESET
    unless exists $COUNTRY_CENTROID{$cc};

my ($lat, $lon) = @{ $COUNTRY_CENTROID{$cc} };

# ============================
# Step 5: Map dimensions
# ============================
print BOLD GREEN, "Detecting map dimensions...\n", RESET;

my $identify = run("magick identify -format \"%w %h\" '$MAP_IN'");
die BOLD RED . "Failed to identify map\n" . RESET
    unless $identify =~ /^\d+\s+\d+$/;

my ($W, $H) = split /\s+/, $identify;
print "Map size: ${W}x${H}\n";

# ============================
# Step 6: Lat/Lon → Pixel
# ============================
my $x = int( ($lon + 180) * ($W / 360) );
my $y = int( (90 - $lat)  * ($H / 180) );

print "Pin pixel position: x=$x y=$y\n";

# ============================
# Step 7: Draw pin + label
# ============================
print BOLD GREEN, "Drawing pin on map...\n", RESET;

my $label_x = $x + 10;
my $label_y = $y - 10;

system(
    "magick",
    $MAP_IN,
    "-fill", "red",
    "-stroke", "black",
    "-strokewidth", "2",
    "-draw", "circle $x,$y $x," . ($y - 8),
    "-fill", "yellow",
    "-stroke", "black",
    "-strokewidth", "1",
    "-font", "Noto-Sans-Bold",
    "-antialias",
    "-pointsize", "48",
    "-annotate", "+$label_x+$label_y", $country,
    $MAP_OUT
) == 0 or die BOLD RED . "ImageMagick failed\n" . RESET;

# ============================
# Step 8: Display
# ============================
print BOLD GREEN, "Displaying map...\n\n", RESET;

system("viu", "-w", "80", "-h", "20", $MAP_OUT) == 0
    or die BOLD RED . "viu failed\n" . RESET;

print BOLD CYAN, "\n✔ Country pinned successfully\n\n", RESET;
