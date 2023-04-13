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
I0=I;
%%%%%%%%%%%%%% Motion blur the image  %%%%%%%%%%%%%%%%%%
results =[];
for jj=1:90
    I=I0;
    psf = fspecial('motion',20,2*jj);  
    I = imfilter(I,psf,'circ','conv');
    I = I - mean(I(:));
    If = abs(fft2(I));
    lg = log10(1+If);
    lgf = ifftshift(lg);
    lgf = mat2gray(lgf);
    lgcep = ifft2(lg);     
    lgcepf = ifftshift(lgcep);
    %min_lgcep = min(lgcep(:))
    BW  = edge(lgcep,'canny'); 
    BWC = ifftshift(BW); 
    %figure; imshow(BWC); title('Edge image in cepstrum domain');
    
    %%%%%%%%%%%%%%%%%%%%%%% identify angles
    A = Hough_line(BWC);
    accumulators = max(A(:));
    [S,JiaoDu]=find(A==accumulators);
    S=S-1;
    if accumulators >=10 & S(1)<=5
        disp('Motion blur is detected')
        if JiaoDu(1) <90
            find_angle = 90-JiaoDu(1);
        else
            find_angle = 270-JiaoDu(1);
        end
    else
        disp('No motion blur is detected')
        find_angle =nan;
    end
    temp = [2*jj find_angle S(1) accumulators abs(2*jj-find_angle)];
    results =[results;temp]
end
x=2*(1:90);
y=abs(results(:,2)-results(:,1));
figure,plot(x,y','r')




