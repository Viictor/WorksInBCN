feature('DefaultCharacterSet', 'UTF8');

scrsz = get(groot,'ScreenSize');
SCREEN_WIDTH = scrsz(3);
SCREEN_HEIGHT = scrsz(4);


h = waitbar(0,'Iniciando proceso...');

% -------------------------------------------------------------------------
% Cargar fichero JSON en un cell array
% -------------------------------------------------------------------------
data_obres = parse_json(fileread('obres.json'));
nObres = length(data_obres);
default_zoom = 15;

coordinatesData = cell(1, length(data_obres));
coordinatesData(1,:) = {cell(4,2)};

% -------------------------------------------------------------------------
% Calcular el numero de manzanas de cada imagen
% -------------------------------------------------------------------------

perc = -1;
for numObra = 1:nObres
    
    
    if numObra == 14
        debugging = 0;
    end
    
    perc = perc + 1/nObres*100;
    waitbar(perc/100,h,sprintf('Obra (%d) - Manzanas de la imagen de OpenData (%0.2f%%)...',numObra, perc));

    % -------------------------------------------------------------------------
    % Calcular manzanas de la imagen de OpenData
    % -------------------------------------------------------------------------
    [ mOpenData, bw_opendata, odata_image ] = get_num_squares_opendata(numObra, data_obres);
    
    if mOpenData == -1
        continue;
    end
    
    [height, width] = size(bw_opendata);

    
    waitbar(perc/100,h,sprintf('Obra (%d) - Calculando zoom con Google Maps (%0.2f%%)...',numObra, perc));

    % -------------------------------------------------------------------------
    % Se determina el zoom 
    % -------------------------------------------------------------------------
    [mMaps, minZoom, maxZoom] = getZoom(mOpenData, numObra, width, height, default_zoom, data_obres, h, perc);
    [mMapsMinZoom, bw_mapsMin] = get_num_squares(numObra, width, height, minZoom, data_obres);
    
    if ( minZoom == 14 )
        disp(['Zoom 14 -> ' num2str(numObra)]);
        continue;
    end

    [ zoom, image, squares ] = get_best_zoom_level( minZoom, bw_mapsMin, mOpenData );
    
    waitbar(perc/100,h,sprintf('Obra (%d) - Cargando imagen a comparar (%0.2f%%)...',numObra, perc));

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

    waitbar(perc/100,h,sprintf('Obra (%d) - Template Matching (%0.2f%%)...',numObra, perc));

%     figure('position', [0, SCREEN_HEIGHT/2, SCREEN_WIDTH/2, SCREEN_HEIGHT/2]),
%     subplot(1,2,1),
%     imshow(bw_opendata),
%     axis image;
%     title(['OpenData : ' num2str(mOpenData) ' manzanas']),
%     subplot(1,2,2),
%     imshow(image),
%     axis image;
%     title(['Google : ' num2str(squares) ' manzanas']);

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
%     image_desplazada = get_google_map(lat_desplazada, lon_desplazada, minZoom, width, height, 'roadmap', '', '');
%     image_desplazada = imread(image_desplazada);
%     z = 1 + zoom - minZoom;
%     new_image = imresize(image_desplazada, z);
%     [h_new, w_new] = size(new_image);
%     w_new = w_new/3;
%     new_image = imcrop(new_image, [(w_new/2 - width/2) (h_new/2 - height/2) width height]);

%     % -------------------------------------------------------------------------
%     % Plot de ambas imagenes
%     % -------------------------------------------------------------------------
% 
%     figure('position', [0, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT/2]),
%     subplot(1,2,1),
%     imshow(imread('tmp_src.jpg')),
%     axis image;
%     title('OpenData'),
%     subplot(1,2,2),
%     imshow(new_image),
%     axis image;
%     title('Google');

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

%    imagen_work = get_google_map(lat_desplazada, lon_desplazada, minZoom, width, height, 'roadmap', numObra , paths);
%     figure,
%     imshow(imagen_work);

    coordinatesData{numObra}{1,1} = paths{1,1};
    coordinatesData{numObra}{1,2} = paths{1,2};
    coordinatesData{numObra}{2,1} = paths{1,1};
    coordinatesData{numObra}{2,2} = paths{2,2};
    coordinatesData{numObra}{3,1} = paths{2,1};
    coordinatesData{numObra}{3,2} = paths{2,2};
    coordinatesData{numObra}{4,1} = paths{2,1};
    coordinatesData{numObra}{4,2} = paths{1,2};
end

savejson('',coordinatesData,'coordinates');

waitbar(100,h,sprintf('Completado (%0.2f%%)...',100));
close(h);
