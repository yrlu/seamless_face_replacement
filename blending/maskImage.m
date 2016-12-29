% [mask] = maskImage(Img)
% (INPUT) img: h x w x 3 matrix representing the source image.
% (OUTPUT) mask: h x w logical matrix representing the replacement region.
%
% @author: Dongni W. 
% @date: 11/27/16
function mask = maskImage(Img)
h_im = imshow(Img);
e = imfreehand();
mask = createMask(e,h_im);
end

