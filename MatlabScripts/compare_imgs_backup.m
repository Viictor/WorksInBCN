feature('DefaultCharacterSet', 'UTF8');

scrsz = get(groot,'ScreenSize');
SCREEN_WIDTH = scrsz(3);
SCREEN_HEIGHT = scrsz(4);


h = waitbar(0,'Iniciando proceso...');

% -------------------------------------------------------------------------
% Cargar fichero JSON en un cell array
% -------------------------------------------------------------------------
data_obres = parse_json(fileread('obres.json'));

% -------------------------------------------------------------------------
% Calcular el numero de manzanas de cada imagen
% Pruebas con:
% 21: Bien
% 11: Bien
% 8 : Bien
% 28: Mal
% 19: Bien
% 22: Mas o menos
% 31: Mal
% 33: Bien
% 34: Bien
% 40: Bien
% 44: Mas o menos
% 47: Mas o menos
% 49: Mal
% 52: Mas o menos
% 54: Bien
% 56: Mal
% 57: Mal
%
% -------------------------------------------------------------------------



numObra = 44;
default_zoom = 15;

perc = 10;
waitbar(perc/100,h,sprintf('Calculando manzanas de la imagen de OpenData (%d%%)...',perc));

% -------------------------------------------------------------------------
% Calcular manzanas de la imagen de OpenData
% -------------------------------------------------------------------------
[ mOpenData, bw_opendata, odata_image ] = get_num_squares_opendata(numObra, data_obres);
[height, width] = size(bw_opendata);

perc = 30;
waitbar(perc/100,h,sprintf('Calculando margen de zoom con Google Maps (%d%%)...',perc));

% -------------------------------------------------------------------------
% Se determina el zoom 
% -------------------------------------------------------------------------
[mMaps, minZoom, maxZoom] = getZoom(mOpenData, numObra, width, height, default_zoom, data_obres, h, perc);
[mMapsMinZoom, bw_mapsMin] = get_num_squares(numObra, width, height, minZoom, data_obres);

[ zoom, image, squares ] = get_best_zoom_level( minZoom, bw_mapsMin, mOpenData );

perc = 70;
waitbar(perc/100,h,sprintf('Template Matching (%d%%)...',perc));

% -------------------------------------------------------------------------
% Se pide una imagen a google con el zoom calculado y de mas resolucion 
% para hacer el template matching
% -------------------------------------------------------------------------
[m, bw_mapsBigger] = get_num_squares(numObra, 2048, 2048, minZoom, data_obres);
z = 1 + zoom - minZoom;
new_image = imresize(bw_mapsBigger, z);
[h_new, w_new] = size(new_image);

% -------------------------------------------------------------------------
% Template Matching
% -------------------------------------------------------------------------
[yoffSet, xoffSet] = template_matching(new_image, odata_image);

waitbar(90,h,sprintf('Template Matching (%d%%)...',100));

figure('position', [0, SCREEN_HEIGHT/2, SCREEN_WIDTH/2, SCREEN_HEIGHT/2]),
subplot(1,2,1),
imshow(bw_opendata),
axis image;
title(['OpenData : ' num2str(mOpenData) ' manzanas']),
subplot(1,2,2),
imshow(image),
axis image;
title(['Google : ' num2str(squares) ' manzanas']);

% -------------------------------------------------------------------------
% Desplazar la imagen para tenerla centrada respecto a la de OpenData
% -------------------------------------------------------------------------
center_y = yoffSet + (height/2);
center_x = xoffSet + (width/2);

desp_x = -(w_new/2 - center_x);
desp_y = -(h_new/2 - center_y);

northing = data_obres{numObra}.card.address.geo.alpha__attributes.latitude;
easting = data_obres{numObra}.card.address.geo.alpha__attributes.longitude;
northing = str2double(strrep(northing, ',', '.'));
easting = str2double(strrep(easting, ',', '.'));
zone = '31 N';

% -------------------------------------------------------------------------
% Calcular las nuevas coordenadas
% -------------------------------------------------------------------------
[lat,lon] = utm2deg(easting,northing,zone);
[x_original, y_original] = lat_lon_to_world_pixel(lat, lon);
x_desplazada = (x_original * power(2,zoom) + desp_x) / power(2,zoom);
y_desplazada = (y_original * power(2,zoom) + desp_y) / power(2,zoom);

% -------------------------------------------------------------------------
% Recuperar la iamgen desplazada
% -------------------------------------------------------------------------
[lat_desplazada, lon_desplazada] = world_pixel_to_lat_lon(x_desplazada, y_desplazada);
image_desplazada = get_google_map(lat_desplazada, lon_desplazada, minZoom, width, height, 'roadmap', '', '');
image_desplazada = imread(image_desplazada);
z = 1 + zoom - minZoom;
new_image = imresize(image_desplazada, z);
[h_new, w_new] = size(new_image);
w_new = w_new/3;
new_image = imcrop(new_image, [(w_new/2 - width/2) (h_new/2 - height/2) width height]);

% -------------------------------------------------------------------------
% Plot de ambas imagenes
% -------------------------------------------------------------------------

figure('position', [0, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT/2]),
subplot(1,2,1),
imshow(imread('tmp_src.jpg')),
axis image;
title('OpenData'),
subplot(1,2,2),
imshow(new_image),
axis image;
title('Google');

[x_work, y_work, x_max_work, y_max_work] = work_coordinates(odata_image);
desp_x = -(width/2 - x_work);
desp_y = -(height/2 - y_work);
desp_x_max = -(width/2 - x_max_work);
desp_y_max = -(height/2 - y_max_work);

[x_original, y_original] = lat_lon_to_world_pixel(lat_desplazada, lon_desplazada);
x_desplazada = (x_original * power(2,zoom) + desp_x) / power(2,zoom);
y_desplazada = (y_original * power(2,zoom) + desp_y) / power(2,zoom);
x_desplazada_max = (x_original * power(2,zoom) + desp_x_max) / power(2,zoom);
y_desplazada_max = (y_original * power(2,zoom) + desp_y_max) / power(2,zoom);
[lat_work, lon_work] = world_pixel_to_lat_lon(x_desplazada, y_desplazada);
[lat_work_max, lon_work_max] = world_pixel_to_lat_lon(x_desplazada_max, y_desplazada_max);

paths = cell(2,2);
paths{1,1} = num2str(lat_work,10);
paths{1,2} = num2str(lon_work,10);
paths{2,1} = num2str(lat_work_max,10);
paths{2,2} = num2str(lon_work_max,10);

imagen_work = get_google_map(lat_desplazada, lon_desplazada, minZoom, width, height, 'roadmap', '', paths);
figure,
imshow(imagen_work);

jsonData = cell(1, length(data_obres));
jsonData(1,:) = {cell(4,2)};

jsonData{1}{1,1} = paths{1,1};
jsonData{1}{1,2} = paths{1,2};
jsonData{1}{2,1} = paths{1,1};
jsonData{1}{2,2} = paths{2,2};
jsonData{1}{3,1} = paths{2,1};
jsonData{1}{3,2} = paths{2,2};
jsonData{1}{4,1} = paths{2,1};
jsonData{1}{4,2} = paths{1,2};

savejson('',jsonData,'coordinates');

waitbar(100,h,sprintf('Template Matching (%d%%)...',100));
close(h);
