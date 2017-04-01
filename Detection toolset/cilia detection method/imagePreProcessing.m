
function imHist = imagePreProcessing(im)
%

% filter image
im = rmwhitebar(im, 1.0, 2);
im = imfilter(im,fspecial('gaussian', [3,3], 1));

% estimate background
histNum = imhist(im);
[~,ind] = sort(histNum, 'descend');
ind = ind(1:2);
bg = sum((ind - 1) / 255 .* histNum(ind)) / sum(histNum(ind));

% hist adjust
imHist = imadjust(im, [bg, max(im(:))], [0.001,1]);
% imHist = imguidedfilter(imsharpen(imHist,'Radius',1.5,'Amount',5));

end