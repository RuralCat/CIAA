%
function [enhancedImage,bw] = imageLocalEnhanced(im, minCiliaArea, halfBlockSize)
%

% define para
if nargin < 3
    halfBlockSize = 16;
end
blockSize = 2 * halfBlockSize;
graylevel = 0.01;
[h,w] = size(im);
% shift image
imageLeftRight = zeros(h,w + halfBlockSize);
imageLeftRight(:,1:halfBlockSize) = im(:,1:halfBlockSize);
imageLeftRight(:,(halfBlockSize+1):end) = im;
imageUpBottom = zeros(h + halfBlockSize,w);
imageUpBottom(1:halfBlockSize,:) = im(1:halfBlockSize,:);
imageUpBottom((halfBlockSize+1):end,:) = im;
% local enhanced
fun = @(block_struct) localAdjust(block_struct.data);
imageLocal = blockproc(im,[blockSize,blockSize],fun);
imageLocalLR = blockproc(imageLeftRight,[blockSize,blockSize],fun);
imageLocalUB = blockproc(imageUpBottom,[blockSize,blockSize],fun);
% convert to binary image
bw = im2bw(imageLocal,graylevel);
bwLR = im2bw(imageLocalLR,graylevel);
bwUB = im2bw(imageLocalUB,graylevel);
bwLR = bwLR(:,(halfBlockSize+1):end);
bwUB = bwUB((halfBlockSize+1):end,:);
bw = bw & bwLR & bwUB;
% bw = bwareaopen(bw,10);
% bw = imdilate(bw,strel('disk',2));
bw = bwareaopen(bw,minCiliaArea);
%
enhancedImage = (imageLocal + imageLocalLR(:,(halfBlockSize+1):end) + ...
    imageLocalUB((halfBlockSize+1):end,:)) / 3;

end