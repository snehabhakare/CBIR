%% SAVE SOH FOR DATABASE
tic;

window_size = 8;
% keyword = 'CoffeeMug';
database_dir = '../../../Corel100/';

% Process the database
dir_name=database_dir;
% dir_name = strcat(database_dir,keyword);
D = dir(strcat(dir_name,'*.jpg')); % check dir command, in matlab documentation

N=floor(length(D)); % Save files in 3 parts 1:N1, N1+1:N2, N2+1:N
N1=floor(length(D))/3;
N2=2*N1;


SALIENCY_HISTOGRAMS=[];
% f = waitbar(0,"Please Wait...");
starting=floor(N1);

for i=starting+3:starting+3
%     msg=strcat('Computing SOH ',num2str(i),'/',num2str(N));
%     f = waitbar(i/N,f,msg);
    filename = strcat(dir_name,D(int8(i)).name);
    X=double(imread(filename));
    [im,mask1] = textureDistinctMap(X);
    figure, imshow(im);
    figure, imshow(mask1);
    [image, Ix, Iy, x, y] = featureExtraction(double(X),mask1);
    figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(y,x,'filled','r.');
    cx=x;
    cy=y;
    h = soh(Ix, Iy, x, y, window_size);
    SALIENCY_HISTOGRAMS(:,:,i)=h;
end
% close(f);
% soh_file = strcat('../SOH_save/Corel_2','_mhec_sal_hists.mat');
% save(soh_file,'SALIENCY_HISTOGRAMS');
toc;