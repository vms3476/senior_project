function f = myfun_mod(x0,X1,X2,X3,Ys,Yn)
xi = x0(1);
yi = x0(2);
zi = x0(3);
x = X1;
y = X2;
z = X3;
xx = squeeze(X3(1,1,:)); yy = X1(1,:,1).'; zz = X2(:,1,1);
% Determine the nearest location of xi in x
[xxi,j] = sort(xi(:));
[ignore,i] = sort([xx;xxi]);
si(i) = (1:length(i));
si = (si(length(xx)+1:end)-(1:length(xxi)))';
si(j) = si;

% Map values in xi to index offset (si) via linear interpolation
si(si<1) = 1;
si(si>length(xx)-1) = length(xx)-1;
si = si + (xi(:)-xx(si))./(xx(si+1)-xx(si));

% Determine the nearest location of yi in y
[yyi,j] = sort(yi(:));
[ignore,i] = sort([yy;yyi]);
ti(i) = (1:length(i));
ti = (ti(length(yy)+1:end)-(1:length(yyi)))';
ti(j) = ti;

% Map values in yi to index offset (ti) via linear interpolation
ti(ti<1) = 1;
ti(ti>length(yy)-1) = length(yy)-1;
ti = ti + (yi(:)-yy(ti))./(yy(ti+1)-yy(ti));

% Determine the nearest location of zi in z
[zzi,j] = sort(zi(:));
[ignore,i] = sort([zz;zzi]);
wi(i) = (1:length(i));
wi = (wi(length(zz)+1:end)-(1:length(zzi)))';
wi(j) = wi;

% Map values in zi to index offset (wi) via linear interpolation
wi(wi<1) = 1;
wi(wi>length(zz)-1) = length(zz)-1;
wi = wi + (zi(:)-zz(wi))./(zz(wi+1)-zz(wi));

[x,y,z] = meshgrid(ones(class(x)):size(x,2),...
    ones(superiorfloat(y,z)):size(y,1),1:size(z,3));
xi(:) = si; yi(:) = ti; zi(:) = wi;

arg1 = x;
arg2 = y;
arg3 = z;
arg5 = xi;
arg6 = yi;
arg7 = zi;
nrows = size(X1,1);
ncols = size(X1,2);
npages = size(X1,3);
mx = numel(arg1); my = numel(arg2); mz = numel(arg3);
s = 1 + (arg5-arg1(1))/(arg1(mx)-arg1(1))*(ncols-1);
t = 1 + (arg6-arg2(1))/(arg2(my)-arg2(1))*(nrows-1);
w = 1 + (arg7-arg3(1))/(arg3(mz)-arg3(1))*(npages-1);

% Check for out of range values of s and set to 1
sout = find((s<1)|(s>ncols));
if ~isempty(sout), s(sout) = ones(size(sout)); end

% Check for out of range values of t and set to 1
tout = find((t<1)|(t>nrows));
if ~isempty(tout), t(tout) = ones(size(tout)); end

% Check for out of range values of w and set to 1
wout = find((w<1)|(w>npages));
if ~isempty(wout), w(wout) = ones(size(wout)); end

% Matrix element indexing
nw = nrows*ncols;
ndx = floor(w)+floor(t-1)*nrows+floor(s-1)*nw;

% Compute intepolation parameters, check for boundary value.
if isempty(s), d = s; else d = find(s==ncols); end
s(:) = (s - floor(s));
if ~isempty(d), s(d) = s(d)+1; ndx(d) = ndx(d)-nrows; end

% Compute intepolation parameters, check for boundary value.
if isempty(t), d = t; else d = find(t==nrows); end
t(:) = (t - floor(t));
if ~isempty(d), t(d) = t(d)+1; ndx(d) = ndx(d)-1; end

% Compute intepolation parameters, check for boundary value.
if isempty(w), d = w; else d = find(w==npages); end
w(:) = (w - floor(w));
if ~isempty(d), w(d) = w(d)+1; ndx(d) = ndx(d)-nw; end
arg4 = Ys;
% F =  (( arg4(:,:,ndx).*(1-t) + arg4(:,:,ndx+1).*t ).*(1-s) + ...
%         ( arg4(:,:,ndx+nrows).*(1-t) + arg4(:,:,ndx+(nrows+1)).*t ).*s).*(1-w) +...
%        (( arg4(:,:,ndx+nw).*(1-t) + arg4(:,:,ndx+1+nw).*t ).*(1-s) + ...
%         ( arg4(:,:,ndx+nrows+nw).*(1-t) + arg4(:,:,ndx+(nrows+1+nw)).*t ).*s).*w;
% F =  (( arg4(:,ndx).*(1-t) + arg4(:,ndx+1).*t ).*(1-s) + ...
%         ( arg4(:,ndx+nrows).*(1-t) + arg4(:,ndx+(nrows+1)).*t ).*s).*(1-w) +...
%        (( arg4(:,ndx+nw).*(1-t) + arg4(:,ndx+1+nw).*t ).*(1-s) + ...
%         ( arg4(:,ndx+nrows+nw).*(1-t) + arg4(:,ndx+(nrows+1+nw)).*t ).*s).*w;
F =  (( arg4(ndx,:).*(1-w) + arg4(ndx+1,:).*w ).*(1-t) + ...
        ( arg4(ndx+nrows,:).*(1-w) + arg4(ndx+(nrows+1),:).*w ).*t).*(1-s) +...
       (( arg4(ndx+nw,:).*(1-w) + arg4(ndx+1+nw,:).*w ).*(1-t) + ...
        ( arg4(ndx+nrows+nw,:).*(1-w) + arg4(ndx+(nrows+1+nw),:).*w ).*t).*s;
f = Yn-F;
f = f(:);
plot(F);
