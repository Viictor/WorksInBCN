function [ yoffSet, xoffSet ] = template_matching( image, odata_image)

bw_google_image = image;
bw_odata_image = segment_image(odata_image, 3);

c = normxcorr2(bw_odata_image,bw_google_image);

scrsz = get(groot,'ScreenSize');
SCREEN_WIDTH = scrsz(3);
SCREEN_HEIGHT = scrsz(4);

[ypeak, xpeak] = find(c==max(c(:)));
yoffSet = ypeak-size(bw_odata_image,1);
xoffSet = xpeak-size(bw_odata_image,2);
% figure('position', [SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT]);
% hAx  = axes;
% imshow(bw_google_image,'Parent', hAx);
% imrect(hAx, [xoffSet, yoffSet, size(bw_odata_image,2), size(bw_odata_image,1)]);

end

