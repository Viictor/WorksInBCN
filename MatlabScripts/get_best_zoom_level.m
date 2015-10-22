function [ zoom, image, squares ] = get_best_zoom_level( minZoom, bw_image, mOpenData )

[height, width] = size(bw_image);

zoom = 1;
nSquares = zeros(1, 10);
images = cell(1,10);

for i=1:11
    zoom = zoom + 0.1;
    new_image = imresize(bw_image, zoom);
    new_image = imcrop(new_image, [0 0 width height]);

    images{i} = new_image;
    nSquares(i) = calcSquares(new_image);
end

diff = nSquares - mOpenData;

[value, index]= min(abs(diff));

zoom = index/10 + minZoom;
image = images{index};
squares = nSquares(index);

end

