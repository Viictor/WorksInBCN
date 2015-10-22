function [ x, y, x_max, y_max] = work_coordinates( odata_image )

    cform = makecform('srgb2lab');
    lab_image = applycform(odata_image,cform);
    
    work = lab_image(:,:,1);
    work = im2bw(work);
    
    [row,col] = find(work == 0);
    
    if ( isempty(row))

        ab = double(lab_image(:,:,2:3));
        nrows = size(ab,1);
        ncols = size(ab,2);
        ab = reshape(ab,nrows*ncols,2);

        nColors = 3;

        [cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqeuclidean','Replicates',5);

        pixel_labels = reshape(cluster_idx,nrows,ncols);
        segmented_images = cell(1,3);
        rgb_label = repmat(pixel_labels,[1 1 3]);

        for k = 1:nColors
            color = odata_image;
            color(rgb_label ~= k) = 0;
            segmented_images{k} = color;
        end



        n = zeros(1,nColors);

        for i = 1:nColors
            n(i) = length(find(segmented_images{i} == 0));
        end

        nSort = sort(n, 'descend');
        in = find( n == nSort(1) );


        work = segmented_images{in};
        work = im2bw(work);


        [row,col] = find(work == 1);
    end
    
    col = sort(col);
    row = sort(row);
    
    x = col(1);
    y = row(1);
    
    x_max = col(end);
    y_max = row(end);

end

