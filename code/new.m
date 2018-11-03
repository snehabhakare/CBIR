% im=imread('../src/1.jpg');
im=imread('../SampleImages/Butterfly/10.jpg');
[m n p]=size(im);
% a=[1:m-4]';
% d=repelem(a,n-4);
% b=[1:n-4]';
% c=repelem(b,1,m-4);
% b=c(:);
% a=d;
res_im=im(3:m-2,3:n-2,1:3);
window_size=5;
% fmat=zeros(25,(m-4)*(n-4),p);
fmat=zeros((m-4)*(n-4),25,p);
f = waitbar(0,"Please Wait...");
tic;
for iter=1:p
    msg=strcat('Processing Channel-',num2str(iter));
    f = waitbar(iter/p,f,msg);
    fmat(:,:,iter)=computeFeatures(im(:,:,iter),m,n,window_size);
end
close(f);
toc;

% using myPCA method


% channel1=fmat(:,:,1);

lab_image=[];
lab_image=cat(2,fmat(:,:,1),fmat(:,:,2));
lab_image=cat(2,lab_image,fmat(:,:,3));

% r=lab_image(:,1);
% g=lab_image(:,26);
% b=lab_image(:,51);
% newim(:,:,1)=reshape(r,m-4,n-4);
% newim(:,:,2)=reshape(g,m-4,n-4);
% newim(:,:,3)=reshape(b,m-4,n-4);
% % newim=reshape(a,5,5,3);
% figure,imshow(mat2gray(newim)),colorbar;

% vec=res_im(:,:,1);
% a=vec(:);
% abc=(r==vec(:));

lab_image=transpose(lab_image);

% r=lab_image(1,:);
% g=lab_image(26,:);
% b=lab_image(51,:);
% newim(:,:,1)=reshape(r,m-4,n-4);
% newim(:,:,2)=reshape(g,m-4,n-4);
% newim(:,:,3)=reshape(b,m-4,n-4);
% % newim=reshape(a,5,5,3);
% figure,imshow(mat2gray(newim)),colorbar;

xbar=mean(lab_image,2);
mean_deducted=lab_image-xbar;
% L=transpose(mean_deducted)*mean_deducted;
L=mean_deducted*transpose(mean_deducted);
[eigvals,eigvecs]=eig(L);
[diagonal,indices]=sort(diag(eigvals),'descend');
eigvecs=eigvecs(:,indices);
% eigen_vectors=mean_deducted*W;
% V_hat=eigen_vectors(1:3,:);
V_hat=eigvecs(:,1:3);
eigspace=transpose(V_hat)*mean_deducted;
transformedspace=transpose(eigspace);

%% clustering
clusters=20;
idx=kmeans(transformedspace,clusters);
% new_im=reshape(idx,m-4,n-4);
% figure,imshow(mat2gray(new_im)),colorbar;
animg=zeros([(m-4)*(n-4),1]);
atoms=[];

for iter=1:clusters
    indices=find(idx==iter);
    animg(indices,1)=iter;
    atom=mean(transformedspace(indices,:),1);
%     atom= mean(tx(indices,:),1);
    atoms = cat(1,atoms,atom);
end
txanimg=transpose(animg);
newimg=reshape(txanimg,m-4,n-4);
figure,imshow(mat2gray(newimg)),colorbar;

% r=eigen_vectors(:,1);
% g=eigen_vectors(:,26);
% b=eigen_vectors(:,51);
% newim(:,:,1)=reshape(r,m-4,n-4);
% newim(:,:,2)=reshape(g,m-4,n-4);
% newim(:,:,3)=reshape(b,m-4,n-4);
% % newim=reshape(a,5,5,3);
% figure,imshow(mat2gray(newim)),colorbar;
% transpose(V_hat)*mean_deducted;

cov=[];
for j=1:clusters
    for iter=1:clusters
        cov(j,iter)=var((atoms(j,:)-atoms(iter,:)).^2);
    end
end
Pij=[];
for i=1:clusters
    for j=1:clusters
        if i==j
            continue
        else
%             sd=sqrt(cov(i,j));
            g=exp((-0.5)*(atoms(i,:).^2)/cov(i,j));
            Pij(i,j)=g(1)*g(2)*g(3);
        end
    end
end
beta=1-Pij;

% window_size=;
%Spatial gaussian mask
spatch=zeros(size(im(:,:,1)));
% spatch=patch;
% sigma_spat=m/3;
sigma_spat=0.5;
row=1;
ci=m/2;
cj=n/2;
%set up the spatial gaussian mask
for i=1:size(im,1)
    col=1;
    for j=1:size(im,2)
        pow=sqrt((i-ci)*(i-ci)+(j-cj)*(j-cj));
        pow=pow*pow;
%         spatch(i,j)=-pow/(sigma_spat*sigma_spat);
        spatch(i,j)=exp(-pow/(2*sigma_spat*sigma_spat));
        col=col+1;
    end
    row=row+1;
end

 for iter=1:clusters
    indices=find(idx==iter);
    center_dist(iter) = exp( ( -1/length(indices) ) * sum( spatch(indices) ) );
 end
alpha=zeros(clusters,1);
for iter=1:clusters
    g=exp((-0.5)*(atoms(iter,:).^2)./sum(cov(iter,:)));
    Pix(iter)=g(1)*g(2)*g(3);
    for j=1:clusters
        if iter==j
            continue
        else
%             alpha(iter)=alpha(iter)+beta(iter,j)*Pix(iter)*center_dist(iter);
%             alpha(iter)=alpha(iter)+beta(iter,j)*center_dist(iter);
%             alpha(iter)=beta(iter,j)*center_dist(iter);
            alpha(iter)=alpha(iter)+beta(iter,j)*Pix(iter);
        end
    end
end

saliency_map=zeros(1,(m-4)*(n-4));

 for iter=1:clusters
    indices=find(idx==iter);
    saliency_map(indices)=alpha(iter);
 end
 saliency_map=reshape(saliency_map,m-4,n-4);
figure,imshow(mat2gray(saliency_map)),colorbar;

%% feature matrix
function feature_matrix=computeFeatures(im,m,n,window_size)
diff=(window_size-1)/2;
feature_matrix=[];
x1=1;
y1=1;
x2=1;
y2=1;

f=waitbar(0,"Please wait...");
% Ignoring boundary conditions for now.
for j=3:n-2
    msg='Processing...';
    f = waitbar(j/(n-2),f,msg);
    for i=3:m-2
        if i+diff>m
            x2=m;
        else
            x2=i+diff;
        end
        if i-diff<1
            x1=1;
        else
            x1=i-diff;
        end
        if j+diff>n
            y2=n;
        else
            y2=j+diff;
        end
        if j-diff<1
            y1=1;
        else
            y1=j-diff;
        end
        
        A=im([x1:x2],[y1:y2]);
        [m1 n1]=size(A);
        layer2=A(1,1:4);
        layer2=cat(2,layer2,transpose(A(1:5,5)));
        layer2=cat(2,layer2,A(5,1:4));
        layer2=cat(2,layer2,transpose(A(2:4,1)));
        sorted_layer2=sort(layer2); % Sorting the square rings around center pixel.
        layer1=A(2,2:4);
        layer1=cat(2,layer1,A(4,2:4));
        layer1=cat(2,layer1,[A(3,2),A(3,4)]);
        sorted_layer1=sort(layer1); 
        local_vector=cat(2,A(3,3),sorted_layer1);
        local_vector=cat(2,local_vector,sorted_layer2);
        feature_matrix=cat(1,feature_matrix,local_vector);
%         feature_matrix=cat(2,feature_matrix,transpose(local_vector));
%         disp(A);
%         disp(local_vector);
    end
end
close(f);
end