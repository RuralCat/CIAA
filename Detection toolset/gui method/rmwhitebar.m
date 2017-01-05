%% Remove the white bar in the imge
%  
%  Input: image, grayscale image
function image = rmwhitebar(input, threhold, sz)

% This method can only use when only the green channel has image.
% image = imsubtract(image(:,:,2), image(:,:,1));

[x,y] = size(input);
image = input;

for i = 1:1:x
    for j = 1:1:y
        if image(i, j) >= threhold
            bi = max(1, i - sz);
            bj = max(1, j - sz);
            ei = min(i + sz, x);
            ej = min(j + sz, y);
            crop = image(bi:ei, bj:ej);
            crop(crop == image(i, j)) = 0;
            image(i, j) = mean(crop(:));
        end
    end
end

high = imsubtract(input, image);
high(high > 0) = 1;
big = bwareaopen(high, 800) * 1.0;
whitebar = big;
image = imsubtract(input, whitebar);

