#!/usr/bin/env perl

use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use File::Path qw(make_path);

# ============================
# Version / Credits
# ============================
my $VERSION = "2.0";

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
# db.v2
# ============================
my %COUNTRY_CENTROID = (
    # North America
    US => [ 39.8,  -98.6 ],
    CA => [ 56.1, -106.3 ],
    MX => [ 23.6, -102.6 ],
    GT => [ 15.8,  -90.2 ],
    BZ => [ 17.2,  -88.7 ],
    HN => [ 14.8,  -86.3 ],
    SV => [ 13.8,  -88.9 ],
    NI => [ 12.9,  -85.0 ],
    CR => [  9.9,  -84.2 ],
    PA => [  8.6,  -80.8 ],
    CU => [ 21.5,  -79.4 ],
    HT => [ 19.0,  -72.3 ],
    DO => [ 18.7,  -70.2 ],
    JM => [ 18.1,  -77.3 ],

    # South America
    BR => [-14.2,  -51.9 ],
    AR => [-38.4,  -63.6 ],
    CL => [-35.7,  -71.5 ],
    PE => [ -9.2,  -75.0 ],
    CO => [  4.6,  -74.1 ],
    VE => [  6.4,  -66.6 ],
    EC => [ -1.8,  -78.2 ],
    BO => [-16.7,  -64.7 ],
    PY => [-23.4,  -58.4 ],
    UY => [-32.5,  -55.8 ],
    GY => [  5.0,  -58.9 ],
    SR => [  4.0,  -56.0 ],

    # Europe
    GB => [ 55.4,   -3.4 ],
    IE => [ 53.1,   -8.2 ],
    FR => [ 46.2,    2.2 ],
    DE => [ 51.2,   10.4 ],
    NL => [ 52.1,    5.3 ],
    BE => [ 50.6,    4.7 ],
    LU => [ 49.8,    6.1 ],
    CH => [ 46.8,    8.2 ],
    AT => [ 47.5,   14.6 ],
    IT => [ 42.8,   12.5 ],
    ES => [ 40.4,   -3.7 ],
    PT => [ 39.7,   -8.0 ],
    DK => [ 56.3,    9.5 ],
    NO => [ 60.5,    8.5 ],
    SE => [ 62.0,   15.0 ],
    FI => [ 64.0,   26.0 ],
    IS => [ 64.9,  -18.6 ],
    PL => [ 52.0,   19.1 ],
    CZ => [ 49.8,   15.5 ],
    SK => [ 48.7,   19.7 ],
    HU => [ 47.2,   19.5 ],
    SI => [ 46.1,   14.9 ],
    HR => [ 45.1,   15.2 ],
    BA => [ 44.2,   17.7 ],
    RS => [ 44.0,   21.0 ],
    ME => [ 42.7,   19.3 ],
    AL => [ 41.1,   20.0 ],
    MK => [ 41.6,   21.7 ],
    GR => [ 39.1,   21.8 ],
    BG => [ 42.7,   25.5 ],
    RO => [ 45.9,   24.9 ],
    MD => [ 47.0,   28.6 ],
    UA => [ 49.0,   32.0 ],
    BY => [ 53.7,   27.9 ],
    LT => [ 55.2,   23.9 ],
    LV => [ 56.9,   24.6 ],
    EE => [ 58.7,   25.0 ],
    RU => [ 61.5,  105.3 ],

    # Middle East / Caucasus
    TR => [ 39.0,   35.0 ],
    CY => [ 35.1,   33.4 ],
    GE => [ 42.3,   43.4 ],
    AM => [ 40.1,   45.0 ],
    AZ => [ 40.3,   47.7 ],
    IL => [ 31.0,   35.0 ],
    JO => [ 31.2,   36.7 ],
    LB => [ 33.9,   35.8 ],
    SY => [ 35.0,   38.5 ],
    IQ => [ 33.2232, 43.6793 ],
    IR => [ 32.4,   53.7 ],
    SA => [ 23.9,   45.1 ],
    AE => [ 24.3,   54.3 ],
    QA => [ 25.3,   51.2 ],
    BH => [ 26.1,   50.5 ],
    KW => [ 29.3,   47.5 ],
    OM => [ 20.6,   56.1 ],
    YE => [ 15.6,   48.5 ],

    # Africa
    ZA => [-30.6,   22.9 ],
    EG => [ 26.8,   30.8 ],
    MA => [ 31.8,   -7.1 ],
    DZ => [ 28.0,    1.7 ],
    TN => [ 34.0,    9.0 ],
    LY => [ 27.0,   17.0 ],
    SD => [ 15.6,   30.2 ],
    SS => [  7.3,   30.3 ],
    ET => [  9.1,   40.5 ],
    ER => [ 15.3,   39.0 ],
    DJ => [ 11.8,   42.6 ],
    SO => [  5.2,   46.2 ],
    KE => [  0.1,   37.9 ],
    UG => [  1.4,   32.3 ],
    TZ => [ -6.4,   35.0 ],
    RW => [ -1.9,   29.9 ],
    BI => [ -3.4,   29.9 ],
    CD => [ -2.9,   23.7 ],
    CG => [ -0.2,   15.8 ],
    GA => [ -0.6,   11.8 ],
    CM => [  5.7,   12.7 ],
    NG => [  9.1,    8.7 ],
    GH => [  7.9,   -1.0 ],
    CI => [  7.5,   -5.5 ],
    SN => [ 14.5,  -14.5 ],
    ML => [ 17.6,   -3.5 ],
    NE => [ 17.6,    8.1 ],
    BF => [ 12.2,   -1.6 ],
    GN => [ 10.4,  -10.9 ],
    SL => [  8.5,  -11.8 ],
    LR => [  6.4,   -9.4 ],
    GM => [ 13.4,  -15.3 ],
    GW => [ 12.0,  -15.2 ],
    MR => [ 20.3,  -10.3 ],
    AO => [-11.2,   17.9 ],
    ZM => [-13.1,   27.8 ],
    ZW => [-19.0,   29.2 ],
    MZ => [-18.7,   35.5 ],
    MG => [-19.4,   46.7 ],
    NA => [-22.6,   17.1 ],
    BW => [-22.3,   24.7 ],

    # Asia
    CN => [ 35.9,  104.2 ],
    MN => [ 46.9,  103.8 ],
    KZ => [ 48.0,   67.0 ],
    UZ => [ 41.4,   64.6 ],
    TM => [ 39.1,   59.4 ],
    KG => [ 41.2,   74.8 ],
    TJ => [ 38.9,   71.0 ],
    AF => [ 33.9,   67.7 ],
    PK => [ 30.4,   69.3 ],
    IN => [ 21.1,   78.0 ],
    NP => [ 28.4,   84.1 ],
    BT => [ 27.4,   90.4 ],
    BD => [ 23.7,   90.4 ],
    LK => [  7.9,   80.7 ],
    MM => [ 21.9,   95.9 ],
    TH => [ 15.9,  101.0 ],
    LA => [ 19.9,  102.5 ],
    KH => [ 12.6,  104.9 ],
    VN => [ 16.3,  106.3 ],
    MY => [  4.2,  102.0 ],
    SG => [  1.35, 103.8 ],
    PH => [ 12.9,  122.7 ],
    ID => [ -2.5,  118.0 ],
    TL => [ -8.8,  125.7 ],
    KR => [ 36.5,  127.9 ],
    KP => [ 40.3,  127.5 ],
    JP => [ 36.2,  138.3 ],

    # Oceania
    AU => [-25.3,  133.8 ],
    NZ => [-41.0,  174.0 ],
    PG => [ -6.3,  143.0 ],
    FJ => [-17.7,  178.1 ],
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
# Header (printed once)
# ============================
print BOLD MAGENTA, "IP → Country → World Map Pin v$VERSION\n", RESET;
print BOLD MAGENTA, "Created with AI. Powered by Apache.\n", RESET;
print BOLD MAGENTA, "Map source: Wikimedia Commons, Public Domain\n\n", RESET;

# ============================
# One full run (Steps 1–8)
# ============================
sub run_once {
    print "---------------------------------\n";
    print BOLD CYAN, "🌍 IP → Country → World Map Pin\n", RESET;
    print "---------------------------------\n";

    # Step 1: Fetch map (cached)
    unless (-f $MAP_IN) {
        print BOLD GREEN, "Fetching map from Apache server...\n", RESET;
        system("curl -s -o '$MAP_IN' '$MAP_URL'") == 0
            or die BOLD RED . "Failed to download map\n" . RESET;
    }

    # Step 2: Get public IP
    print BOLD GREEN, "Fetching public IP...\n", RESET;
    my $ip = run("curl -s icanhazip.com");

    die BOLD RED . "Failed to get IP\n" . RESET
        unless $ip =~ /^\d+\.\d+\.\d+\.\d+$/;

    print "IP: ", BOLD YELLOW, "$ip\n", RESET;

    # Step 3: Cache lookup
    my ($cc, $country);

    if (-f $CACHE_IP) {
        open my $fh, "<", $CACHE_IP;
        my $line = <$fh>;
        close $fh;

        if ($line) {
            my ($cached_ip, $cached_cc, $cached_country) = split /\|/, $line;
            if ($cached_ip eq $ip) {
                ($cc, $country) = ($cached_cc, $cached_country);
                print BOLD GREEN, "Cache hit: Using $country ($cc)\n", RESET;
            }
        }
    }

    # Step 4: GeoIP lookup
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

    $cc = uc($cc // "");
    print "Country: $country ($cc)\n";

    die BOLD RED . "No centroid for $cc\n" . RESET
        unless exists $COUNTRY_CENTROID{$cc};

    my ($lat, $lon) = @{ $COUNTRY_CENTROID{$cc} };

    # Step 5: Map dimensions
    print BOLD GREEN, "Detecting map dimensions...\n", RESET;

    my $identify = run("magick identify -format \"%w %h\" '$MAP_IN'");
    die BOLD RED . "Failed to identify map\n" . RESET
        unless $identify =~ /^\d+\s+\d+$/;

    my ($W, $H) = split /\s+/, $identify;
    print "Map size: ${W}x${H}\n";

    # Step 6: Lat/Lon → Pixel (Plate Carrée / equirectangular)
    my $x = int( ($lon + 180) * ($W / 360) );
    my $y = int( (90 - $lat)  * ($H / 180) );

    print "Pin pixel position: x=$x y=$y\n";

    # Step 7: Draw pin + label
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

    # Step 8: Display
    print BOLD GREEN, "Displaying map...\n\n", RESET;

    system("viu", "-w", "80", "-h", "20", $MAP_OUT) == 0
        or die BOLD RED . "viu failed\n" . RESET;

    print BOLD CYAN, "\n✔ Country pinned successfully\n\n", RESET;
}

# ============================
# Run loop: R = rerun, Enter = quit
# ============================
while (1) {
    run_once();

    print BOLD MAGENTA, "Press [R] + Enter to rerun, or just Enter to quit: ", RESET;
    my $ans = <STDIN>;
    last if !defined $ans;          # Ctrl-D
    chomp $ans;

    last if $ans =~ /^\s*$/;        # Enter quits
    next if $ans =~ /^\s*r\s*$/i;   # R reruns

    print BOLD YELLOW, "Unknown option. Type R to rerun or press Enter to quit.\n\n", RESET;
}
