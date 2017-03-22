function [C,ao] = blend(A,aa,B,ab)
%BLEND Composite image A over image B.
%
%   A/B    rgb images;
%          arrays of size [x y 3];
%          values in the range [0,1].
%   aa/ab  transparency of the pixels in A and B, respectively;
%          arrays of size [x y 3] or [x y], or scalars;
%          values in the range [0,1].
%
%   C      composite rgb image
%   ao     corresponding alpha
%
%   References:
%   Porter and Duff (1984): Compositing digital images.
%
%   Author: Kristian Loewe

assert(any(strcmp(class(A), {'single','double'})) ...
  && strcmp(class(A), class(B)));

if ndims(A) == 2; A = cat(3,A,A,A); end
if ndims(B) == 2; B = cat(3,B,B,B); end
assert(isequal(size(A), size(B)));

assert(~any(isnan(A(:))) && ~any(isnan(B(:))));
% B(isnan(B)) = 0;
% A(isnan(A)) = 0;

% if isscalar(aa); aa = ones(size(A)).*aa; end
% if isscalar(ab); ab = ones(size(B)).*ab; end

if ~isscalar(aa)
  if ndims(aa) == 2
    aa = cat(3,aa,aa,aa);
  end
  assert(isequal(size(aa),size(A)));
end
if ~isscalar(ab)
  if ndims(ab) == 2
    ab = cat(3,ab,ab,ab);
  end
  assert(isequal(size(ab),size(B)));
end



% out alpha
a = aa + ab.*(1-aa);

% out rgb
C = (A.*aa + B.*ab.*(1-aa))./a;
% C(ao == 0) = 0;

% if ndims(ao) == 3 ...
%     && isequal(ao(:,:,1),ao(:,:,2)) && isequal(ao(:,:,1),ao(:,:,3))
%   ao = ao(:,:,1);
% end

if nargout == 2
  ao = a;
else
  assert(nargout == 1);
end

end
