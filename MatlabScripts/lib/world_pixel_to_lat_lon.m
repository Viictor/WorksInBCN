function [ lat, lon ] = world_pixel_to_lat_lon( x, y )

    lon = x / 256 * 360 - 180;
    n = pi - 2 * pi * y / 256;
    lat = (180 / pi * atan(0.5 * (exp(n) - exp(-n))));

end

