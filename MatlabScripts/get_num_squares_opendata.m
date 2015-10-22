function [ nSquaresOpenData, bw_opendata, odata_image ] = get_num_squares_opendata( numObra, data_obres )


image_src = data_obres{numObra}.card.address.object.alpha__attributes.src;

% -------------------------------------------------------------------------
% Guardar la imagen de OpenData y recuperar sus dimensiones
% -------------------------------------------------------------------------

try 
    odata_image = urlwrite(image_src,'tmp_src.jpg');
    odata_image = imread(odata_image);
    % ---------------------------------------------------------------------
    % Se convierte la imagen a binario y se calcula el numero de manzanas
    % ---------------------------------------------------------------------
    bw_opendata = segment_image(odata_image, 3);
    
    imshow(bw_opendata);
   
    
    
    %------------------------- DESCARTE ESQUINAS --------------------------
   
    [height, width] = size(bw_opendata);
    l = 151*101;
    
    corner_1 = imcrop(bw_opendata, [0 0 150 100]);
    corner_2 = imcrop(bw_opendata, [0 (height-100) 150 100]);
    corner_3 = imcrop(bw_opendata, [(width-150) 0 150 100]);
    corner_4 = imcrop(bw_opendata, [(width-150) (height-100) 150 100]);
    
    nP = zeros(1,4);
    nP(1) = length(find(corner_1 == 0))/l*100;
    nP(2) = length(find(corner_2 == 0))/l*100;
    nP(3) = length(find(corner_3 == 0))/l*100;
    nP(4) = length(find(corner_4 == 0))/l*100;
    
    ab = find(nP >= 50);
    
    imagenLimite = 0;
    
    if ( ~isempty(ab) )
        ab = find(nP >= 80);
        if ( ~isempty(ab) )
            disp(['Imagen límite ciudad -> ' num2str(numObra)]);
            imagenLimite = 1;
        end
    end
    
    %---------------------------------------------------------------------- 
    
    if imagenLimite == 0
        nSquaresOpenData = calcSquares(bw_opendata);
    else
        nSquaresOpenData = -1;
    end
    
catch e 
    
    disp('No Hay imagen en OpenData');
    nSquaresOpenData = -1;
    bw_opendata = '';
    odata_image = '';
    
end


end

