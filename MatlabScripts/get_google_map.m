function [ filename ] = get_google_map( lat, lon, zoomlevel, width, height, maptype, nObra, path )

MAPS_API_KEY = 'AIzaSyDGIhM1AkSERF7cQQc3LTICTp6Pu24s0e8';
            
preamble = 'https://maps.googleapis.com/maps/api/staticmap';

location = ['?center=' num2str(lat,10) ',' num2str(lon,10)];

paths = '';

if ~strcmp(path,'')
    paths = ['&path=color:0x00000000|fillcolor:0xFF000033|weight:5|' path{1,1} ',' path{1,2} '|' path{1,1} ',' path{2,2} '|' path{2,1} ',' path{2,2} '|' path{2,1} ',' path{1,2}];
end

zoom = ['&zoom=' num2str(zoomlevel)];
size = ['&size=' num2str(width) 'x' num2str(height)];
maptype = ['&maptype=' maptype ];
format = '&format=jpg';
key = ['&key=' MAPS_API_KEY];
sensor = '&sensor=false';

style1 = '&style=feature:landscape%7Celement:geometry%7Chue:0xfbe1a7%7Csaturation:100%7Clightness:0';
%style1 = '&style=feature:landscape%7Celement:geometry%7Cvisibility:off';
style2 = '&style=feature:road%7Celement:geometry%7Clightness:100';
style3 = '&style=feature:landscape%7Celement:labels%7Cvisibility:off';
style4 = '&style=feature:road%7Celement:labels%7Cvisibility:off';
style5 = '&style=feature:transit%7Celement:all%7Cvisibility:off';
style6 = '&style=feature:poi%7Celement:all%7Cvisibility:off';
style7 = '&style=feature:administrative%7Celement:all%7Cvisibility:off';

url = [preamble location zoom key size style1 style2 style3 style4 style5 style6 style7 maptype format sensor paths];

if strcmp(nObra,'');
    filename = urlwrite(url,'tmp.jpg');
else
    filename = urlwrite(url, ['tmp_' num2str(nObra) '_Z-' num2str(zoomlevel) '.jpg']);
end

end