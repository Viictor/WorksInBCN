function [ x, y ] = lat_lon_to_world_pixel( lat, lon )

    x = (lon + 180) / 360 * 256;
    y = ((1 - log(tan(lat * pi / 180) + 1 / cos(lat * pi/ 180)) / pi) / 2 * power(2, 0)) * 256;


end

