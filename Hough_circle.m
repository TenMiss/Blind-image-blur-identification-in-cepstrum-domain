%-----------------------------------------------
%Function to perform Hough Transform to detect circles whose centers are near the
%origin
%Inputs:  I (input image)
%Output: Counts (accumulator array) which is a 3D array
%-----------------------------------------------
% Copyright: Wu Shiqian    21 Oct 2006
% 
function Counts = Hough_circle(I)
[M,N]=size(I);
[r,c] = find(I);
r = r-(floor(M/2)+1); c = c - (floor(N/2)+1);
rc =ceil(sqrt(r.*r + c.*c));
biggest = max(rc);
smallone = min(M,N);
maxR = min(biggest,smallone);
num = find(rc<=maxR);
rr = r(num); cc = c(num);
xy = [cc,rr];
Counts = zeros(11,11,maxR);
for i = 1:length(rr)
    for j = 1:11
        for k = 1:11
            a = j-6; b = k-6;
            rsquare = (xy(i,1)-a).^2 + (xy(i,2)-b).^2;
            rad = round(sqrt(rsquare));
            if rad>=1 & rad<=maxR
                Counts(j,k,rad) = Counts(j,k,rad)+1;
            end
        end
    end
end
