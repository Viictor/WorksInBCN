function [ pixel_labels ] = segment_image( image, nColors )

cform = makecform('srgb2lab');
lab_image = applycform(image,cform);

ab = double(lab_image(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

cluster_idx = kmeans(ab,nColors,'distance','sqeuclidean','Replicates',5);

pixel_labels = reshape(cluster_idx,nrows,ncols);
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);

for k = 1:nColors
    color = image;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end

n = zeros(1,nColors);
n2 = zeros(1,nColors);

for i = 1:nColors
    n(i) = length(find(segmented_images{i} == 0));
    
    
    temp = sum(segmented_images{i},3) / 765;
    n2(i) = max(temp(:));
end

nSort = sort(n, 'ascend');
in = n == nSort(1);

temp_1 = im2bw(segmented_images{in}, 0.88);

if nColors > 2
    in = find(n2 == 1);
end

temp_2 = im2bw(segmented_images{in}, 0.88);

n_temp_1 = length(find(temp_1 == 1));
n_temp_2 = length(find(temp_2 == 1));

if n_temp_1 >= n_temp_2
    in = n == nSort(1);
    roads = segmented_images{in};
    roads = im2bw(roads);
    pixel_labels = roads;
else 
    roads = segmented_images{in};
    roads = im2bw(roads);
    pixel_labels = roads;
    pixel_labels = 1 - pixel_labels;
end
        
end

