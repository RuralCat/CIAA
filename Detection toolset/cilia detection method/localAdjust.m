function I = localAdjust(im)
%
 
meanI = mean(im(im>0));
im(im<=meanI) = meanI;
I = exp(-meanI./(im-meanI));

end