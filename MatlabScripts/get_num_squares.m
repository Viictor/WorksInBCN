function [ nSquaresMaps, bw_maps ] = get_num_squares( numObra, width, height, zoom, data_obres )

northing = data_obres{numObra}.card.address.geo.alpha__attributes.latitude;
easting = data_obres{numObra}.card.address.geo.alpha__attributes.longitude;
northing = str2double(strrep(northing, ',', '.'));
easting = str2double(strrep(easting, ',', '.'));
zone = '31 N';

% -------------------------------------------------------------------------
% Obtener la imagen de Google Maps
% -------------------------------------------------------------------------
[lat,lon] = utm2deg(easting,northing,zone);
maps_image = get_google_map(lat, lon, zoom, width, height, 'roadmap', '','');
maps_image = imread(maps_image);

% -------------------------------------------------------------------------
% Se convierte la imagen a binario y se calcula el numero de manzanas
% -------------------------------------------------------------------------
bw_maps = segment_image(maps_image, 2);

nSquaresMaps = calcSquares(bw_maps);

end





