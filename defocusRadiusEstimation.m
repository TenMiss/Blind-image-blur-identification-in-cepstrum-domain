clc
clear
close all
[filename, pathname] = uigetfile({'*.*','All Files (*.*)'}, 'Select image');
if isequal([filename,pathname],[0,0])
    return
end
pathAndFilename=strcat(char(pathname),char(filename));
[pathstr,name,ext,versn] = fileparts(filename);
I=imread(pathAndFilename);
figure,imshow(I);title('Original image');
[M N h] = size(I);
if(h ~= 1)
    I = rgb2gray(I);
end
if (~isa(I,'double'))
%    I0=double(I)/255;
    I = im2double(I);
end
I0 = I;
for jj=1:15
    I=I0; 
    psf = fspecial('disk', 2*jj);
    I = imfilter(I,psf,'circ','conv');
    %figure,imshow(I)
    I = I - mean(I(:));
    If = abs(fft2(I));
    lg = log10(1+If);
    lgf0 = ifftshift(lg);
    lgf = mat2gray(lgf0);
    figure; imshow(lgf); title('Image in logarithm spectrum');  
    lgcep = ifft2(lg);     
    lgcepf = ifftshift(lgcep);
    BW  = edge(lgcep,'canny'); 
    BWC = ifftshift(BW); 
    figure; imshow(BWC); title('Edge image in cepstrum domain'); 
    %% Find circle by Hough transform
    Count = Hough_circle(BWC);
    [xcenter,ycenter,maxR]=size(Count);
    for k=1:maxR
        A = Count(:,:,k);
        total = max(A(:))/k;
        results(k,:)=[k,total];
    end
    %figure,plot(results(:,2))
    num = find(results(:,2)>pi);
    if length(num)>=2
        Radius=round(0.25*(num(1)+num(2)));
    elseif length(num)==1
        Radius = fix(num/2)-1;
    else
        Radius =nan;
    end
    Check(jj,:)=[2*jj Radius 2*jj-Radius]
    %keyboard
    %close all
end
x=2*(1:15);
y=abs(Check(:,3));
figure,plot(x,y','r')
