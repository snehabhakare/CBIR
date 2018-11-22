function[image, Ix, Iy, x, y] = featureExtraction(im,mask)
    %Corner detection parameters
%     if size(im,1)~=size(mask,1)
%         diff=abs(size(im,1)-size(mask,1));
%         mask=padarray(mask,[diff 0],0,'post');
%     end
%     if size(im,2)~=size(mask,2)
%         diff=abs(size(im,2)-size(mask,2));
%         mask=padarray(mask,[0 diff],0,'post');
%     end
    if mask==zeros(size(mask))
        newim=mat2gray(im);
    else
        newim=mat2gray(im.*mask);
    end
%     figure,imshow(mat2gray(im));
    sigma1 = 1.7;
    sigma2 = 0.8;
    k = 0.16;

    %Feature extraction (Harris corner detection-sobel edge detection)
    [image, Ix, Iy, ~, cornerness] = myHarrisCornerDetector(double(rgb2gray(newim)), sigma1, sigma2, k);
%     disp('Before');
%     disp(strcat( 'Mean:', num2str(mean(cornerness(:))) ) );
%     disp(strcat( 'Min:', num2str(min(cornerness(:))) ) );
%     disp(strcat( 'Max:', num2str(max(cornerness(:))) ) );
    %Feature point construction
    cornerness = (cornerness>1e-4);
%     disp('After');
%     disp(strcat( 'Mean:', num2str(mean(cornerness(:))) ) );
%     disp(strcat( 'Min:', num2str(min(cornerness(:))) ) );
%     disp(strcat( 'Max:', num2str(max(cornerness(:))) ) );
    [x,y] = find(cornerness);
end