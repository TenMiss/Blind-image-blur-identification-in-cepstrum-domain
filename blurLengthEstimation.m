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

%figure,imshow(I);title('Original image');
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
for jj=20:20
    I=I0;
    psf = fspecial('motion',jj,30);  
    I = imfilter(I,psf,'circ','conv');
    I = I - mean(I(:));
    If = abs(fft2(I));
    lg = log10(1+If);
    lgf0 = ifftshift(lg);
    lgf = mat2gray(lgf0);
    figure; imshow(lgf); title('Image in logarithm spectrum');%%This figure is important
    lgcep = ifft2(lg);     
    lgcepf = ifftshift(lgcep);
    %min_lgcep = min(lgcep(:))
    BW  = edge(lgcep,'canny'); 
    BWC = ifftshift(BW); 
    figure; imshow(BWC); title('Edge image in cepstrum domain');
    
    %%%%%%%%%%%%%%%%%%%%%%% identify angles
    %
    %% Tangles is the angles to be detected
    %
    BW=BWC;
    thresh = 20;      %%%%% the threshold to detect horizonal /vertical motion blur
    PA1 = sum(BWC,2);
    num1 = find(PA1>thresh);
    if ~isempty(num1)
        disp('May occur horizonal blur')
        Tangles(jj,1)=0;
        BWC(num1,:)=0;
    else
        Tangles(jj,1)=nan;
    end
    PA2 = sum(BWC,1);
    num2 = find(PA2>thresh);
    if ~isempty(num2)
        disp('May occur vertical blur')
        Tangles(jj,2)=90;        %% Tangles is the angles to be detected
        BWC(:,num2)=0;
    else
        Tangles(jj,2)=nan;
    end
    A = Hough_line(BWC);
    [S,JiaoDu]=find(A==max(A(:)))
    S = S-1;
    accumulators = max(A(:))
    if S(1)<=5 & accumulators >=10
        disp('Motion blur is detected')
        if JiaoDu(1) <90
            find_angle = 90-JiaoDu(1)
        else
            find_angle = 270-JiaoDu(1)
        end
    else
        disp('No motion blur is detected')
        find_angle =nan;
    end
    Tangles(jj,3)=find_angle;
    temp = [2*jj find_angle S(1) accumulators];
    results =[results;temp];
    %%%%%%%%%%%%%%%%%%%%%%%%%% Estimate the blur length
    bet = Tangles(jj,:);
    non_nan = ~isnan(bet);
    num = find(non_nan);
    if isempty(num)
        disp('No motion blur is detected in this case')
        blurLength = nan
    else
        for k =1:length(num)
            beta = bet(num(k));
            J = imrotate(lgf0,-beta,'bilinear','crop');
            %figure,imshow(J)
            cr = floor(M/2)+1;  
            Y1 = J(cr-5,:)-mean(J(cr-5,:)); 
            FY1 = abs(fft(Y1));
%             Y2 = J(cr-3,:); Y3 = J(cr-1,:);
%             Y4 = J(cr+1,:); Y5 = J(cr+3,:); Y6 = J(cr+5,:);
%             FFTY1 = fft(Y1); FFTY2 = fft(Y2); FFTY3 = fft(Y3);
%             FFTY4 = fft(Y4); FFTY5 = fft(Y5); FFTY6 = fft(Y6);
%             FY1 =abs(FFTY1);   FY2 =abs(FFTY2);   FY3 =abs(FFTY3);
%             FY4 =abs(FFTY4);   FY5 =abs(FFTY5);   FY6 =abs(FFTY6);
%             FA1 = angle(FFTY1);FA2 = angle(FFTY2);FA3 = angle(FFTY3);
%             FA4 = angle(FFTY4);FA5 = angle(FFTY5);FA6 = angle(FFTY6);
%             FUA1 =  unwrap(FA1); FUA2 =  unwrap(FA2); FUA3 =  unwrap(FA3);
%             FUA4 =  unwrap(FA4); FUA5 =  unwrap(FA5); FUA6 =unwrap(FA6);
%             figure,plot(FA2,'b');hold on;,plot(FA3,'r');hold off
%             figure,plot(FUA2,'b');hold on,plot(FUA3,'r');hold off
%             FY23 = FY2*FY3'/(FY2*FY2'+FY3*FY3')
%             FA23 = FA2*FA3'/(FA2*FA2'+FA3*FA3')
%             FUA23 = FUA2*FUA3'/sqrt(FUA2*FUA2'+FUA3*FUA3')

            [xmax,imax,xmin,imin] = extreme(FY1(1:60));
            figure,plot(FY1(1:60))
            FYmean = mean(FY1);
            xmax(1)=[];imax(1)=[];
            for kk =1:5
                pos = imax(kk);
                if pos>5
                    temp = FY1(pos-2:pos+2);
                    if FY1(pos)>3*FYmean & FY1(pos)>=max(temp) %% The peak value is big enough
                                                             %% The peak is max in its neighbour
                        ratio(kk) = FY1(pos)/sum(temp);   %%% Measure the sharpness
                    else
                        ratio(kk) =0;
                    end
                else
                    ratio(kk) =0;
                end
            end
            position = find(ratio == max(ratio)); 
            if length(position)>1 | isempty(position)
                disp('Some problem in finding position')
                blurlength = nan
            else
                blurLength = imax(position)-1
            end
        end
    end
    
end




