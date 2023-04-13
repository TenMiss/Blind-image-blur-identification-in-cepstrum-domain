%-----------------------------------------------
%Function to perform Hough Transform to detect a line passing through the
%origin
%Inputs:  I (input image)
%Returns: A (accumulator array)
% Note: the actual s should be s-1;
%-----------------------------------------------
% Copyright: Wu Shiqian    20 Oct 2006
% 
function A = Hough_line(I)
[M,N]=size(I);
[r,c] = find(I);
r = r-(floor(M/2)+1); c = c - (floor(N/2)+1);
rc =sqrt(r.*r + c.*c);
num = find(rc<=80);
rr = r(num); cc = c(num);
xy = [cc,rr];
beta = 180;
smax =11;
A = zeros(smax,beta);
for i = 1:length(rr)
    for theta = 1:beta;
        s = 1+round(xy(i,1)*cos(theta*pi/180)+xy(i,2)*sin(theta*pi/180));
        if s>=1 & s<=smax
            A(s,theta) = A(s,theta)+1;
        end
    end
end
