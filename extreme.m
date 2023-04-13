function [xmax,imax,xmin,imin] = extreme(x)
%% This program is to extract the peak points
xmax = [];
imax = [];
xmin = [];
imin = [];

Nt = size(x);
if (length(Nt) ~= 2) || isempty(find(Nt==1)) 
 disp('ERROR: the entry is not a vector!')
 return
end
Nt = prod(Nt);
if Nt == 1
 return
end
dx = diff(x);
if ~any(dx)
 return
end
a = find(dx~=0);              
lm = find(diff(a)~=1) + 1;    
d = a(lm) - a(lm-1);         
a(lm) = a(lm) - floor(d/2);  
a(end+1) = Nt;

xa  = x(a);             
b = (diff(xa) > 0);     
                        
xb  = diff(b);         
imax = find(xb == -1) + 1; 
imin = find(xb == +1) + 1; 
imax = a(imax);
imin = a(imin);

nmaxi = length(imax);
nmini = length(imin);                
if (nmaxi==0) & (nmini==0)
 if x(1) > x(Nt)
  xmax = x(1);
  imax = 1;
  xmin = x(Nt);
  imin = Nt;
 elseif x(1) < x(Nt)
  xmax = x(Nt);
  imax = Nt;
  xmin = x(1);
  imin = 1;
 end
 return
end

if (nmaxi==0) 
 imax(1:2) = [1 Nt];
elseif (nmini==0)
 imin(1:2) = [1 Nt];
else
 if imax(1) < imin(1)
  imin(2:nmini+1) = imin;
  imin(1) = 1;
 else
  imax(2:nmaxi+1) = imax;
  imax(1) = 1;
 end
 if imax(end) > imin(end)
  imin(end+1) = Nt;
 else
  imax(end+1) = Nt;
 end
end
xmax = x(imax);
xmin = x(imin);
imax = reshape(imax,size(xmax));
imin = reshape(imin,size(xmin));

[a,inmax] = sort(-xmax);
xmax = xmax(inmax);
imax = imax(inmax);
[xmin,inmin] = sort(xmin);
imin = imin(inmin);
