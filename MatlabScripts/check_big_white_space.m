function [ big_white_space ] = check_big_white_space( image )

    con_comps = bwconncomp(image);

    areas = zeros(1, con_comps.NumObjects);
    for i = 1:con_comps.NumObjects
        areas(i) = length(con_comps.PixelIdxList{1,i});
    end
    areas = sort(areas);
    big_white_space = 0;
    
    
    picos = diff(areas);

    if length(picos) < 3
        picos(3) = 0;
        picos = sort(picos);
    end
    
    peaks = findpeaks(picos, 'MinPeakProminence', 50);
    
    nSquares = 0;
    if isempty(peaks)
        nSquares = con_comps.NumObjects;
        disp('Peaks empty !');
    else
        for i = 1:length(areas)
            if areas(i) >= peaks(1)
                nSquares = nSquares + 1;
            end
        end
    end
    
end


