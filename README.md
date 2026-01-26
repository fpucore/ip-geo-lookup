# ip-country-world-map-pin

IP Geolocation Lookup Tool

A powerful, graphical IP geolocation tool for a kitty-based terminal consoles, on Linux, written in Perl. It fetches your public IP address, determines your country via GeoIP, pins your location on a world map, and renders with full graphics in the terminal. Perfect for Cherry Terminal on the Blackbox-hwm window manager.
Features

    IP Detection: Fetches your public IP using icanhazip.com.
    Geolocation Lookup: Uses geoiplookup to get country information.
    Caching: Caches results to avoid repeated lookups.
    Graphical Map: Downloads a world map, pins your location with a red circle and label, and displays it graphically in the terminal.
    Error Handling: Robust error checking and fallbacks.
    Customizable: Easy to modify centroids to add more countries.

Demo

![Demo screenshot](demo/demo.webp)

🌐 IP & Geolocation Lookup Tool 🌍

Powered by icanhazip.com, geoiplookup, and viu


🔍 Fetching your IP address...

📡 Your IP: 192.168.1.1


🗺️  Looking up geolocation...

📍 Geolocation Results:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌍 Country: Indonesia

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


🖼️  Displaying Graphical World Map with viu:

[Graphical world map with red pin at Iraq location]

📍 Your approximate location: Indonesia (imagine the red 'X' on the map!)

✅ Lookup complete! Stay secure online. 🔒

Installation
Prerequisites

    Perl: to run the script.
    curl: for IP fetching.
    geoiplookup: for geolocation.
    viu for graphical display.
    ImageMagick: for map pinning.
    Map File (included): for map render.
    Apache web server (recommended): for fetching map source file. Alternatively, place map source file in a local dir.

Steps

    Clone the repo:

git clone https://github.com/fpucore/ip-country-world-map-pin

cd ip-country-world-map-pin

Make executable:

chmod +x ip-geo-lookup.pl

Run:

    ./ip-geo-lookup.pl

Usage
Basic Run

./ip-geo-lookup.pl

Launcher Script

Use the included launch-ip-geo.pl to open in a new terminal:

./launch-ip-geo.pl

This uses kitty to launch the tool and keeps the terminal open, prompting the user to interact to exit.
Customization

    Add Countries: Edit %COUNTRY_CENTROID in the script for more locations.
    Map Source: Change $MAP_URL to a different image URL.
    Cache: Results are cached in ~/.cache/ip_geo_lookup/ for speed.

Dependencies

    Perl Modules: Term::ANSIColor, File::Path.
    External Tools: curl, geoiplookup, viu, ImageMagick.
    OS: Linux (tested on H-Linux with Blackbox-hwm; will work on others with dependencies installed).

Install for system-wide execution:

sudo ln -s ip-world-country-map-pin/ip-geo-lookup.pl /usr/bin/ip-geo-lookup

License

This project is licensed under the MIT License - see the LICENSE file for details.
Contributing

Contributions are welcome! Please:

    Fork the repo.
    Submit a pull request.

Credits

    Developer: Chris McGimpsey-Jones (chrisjones.unixmen@gmail.com) 
    Map Source: Wikimedia Commons (Public Domain).
    Inspiration: For Blackbox-hwm on H-Linux.

Support

If you encounter issues:

    Check dependencies are installed.
    Ensure internet access for map download.
    Open an issue on GitHub.

Enjoy exploring your digital location! 🌍
