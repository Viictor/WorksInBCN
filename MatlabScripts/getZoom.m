function [mMaps, minZoom, maxZoom] = getZoom( mOpenData, n_obra, width, height, zoom, data_obres, h, perc)
    
[mMaps, bw_maps] = get_num_squares(n_obra, width, height, zoom, data_obres);

if mMaps - mOpenData > 5
    zoom = zoom + 1;
    [mMaps, minZoom, zoom_max] = getZoom(mOpenData, n_obra, width, height, zoom, data_obres, h, perc);
    maxZoom = zoom_max;
    minZoom = zoom_max - 1;
else
   maxZoom = zoom;
   minZoom = zoom - 1;
end

end