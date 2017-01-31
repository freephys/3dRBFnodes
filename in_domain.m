function [is, radii] = in_domain(x, y, z)
%% [is, radii] = in_domain(x, y, z)
% Check if the point (x,y,z) lies in the atmosphere-like layer; uses ETOPO1
% data and linear interpolation to compare the norm of (x,y,z) with that of
% the Earth surface at the same values of spherical angles.
% Output: 
% is - logical array corresponding to indices of coordinates in x, y, z.
% radii - values of the radius of Earth surface, produced by linear
% interpolation of ETOPO1
% Input:
% x,y,z - arrays of the x-, y-, z-coordinates of the input set of vectors.
%%

persistent Z;
if isempty(Z)
    load('z_transp.mat');    
end
outer = 1.1;
inner = .9;

x_new = reshape(x,[],1);
y_new = reshape(y,[],1);
z_new = reshape(z,[],1);


[m, n] = size(Z);
nn = numel(Z);
delta = pi/n;
[p1, p2, p3] = cart2sph(x_new,y_new,z_new);

azdelta = mod(p1,delta);
eldelta = mod(p2,delta);

gridaz = uint16( (p1-azdelta)/delta + m/2+1);
gridel = uint16( (p2-eldelta)/delta + n/2);
gridind = sub2ind(size(Z), gridaz, gridel);

% Instead of dividing by the Earth radius in meters, i.e. 6,378,000, we exaggerate the
% radial coordinate.
R = 1+[Z(gridind) Z(mod(gridind+m,nn)) Z(mod(gridind+1,nn)) Z(mod(gridind+m+1,nn))]/63780;


indices =  (azdelta + eldelta) <= delta;

    r_interpolated_lower = R(indices,1) + ( R(indices,2)-R(indices,1) ) .*...
        eldelta(indices,1)/delta +...
        ( R(indices,2)-R(indices,1) ) .* azdelta(indices,1)/delta;
 
    r_interpolated_upper = R(~indices,4) + (R(~indices,2)-R(~indices,4)).*...
        (1-azdelta(~indices,1)/delta) +...
        (R(~indices,3)-R(~indices,4)).*(1-eldelta(~indices,1)/delta);

% is = zeros(numel(x_gpu),'gpuArray');
is =zeros(1,numel(x));
radii=zeros(1,numel(x));
radii(indices) = r_interpolated_lower;
radii(~indices) = r_interpolated_upper;

% for the "atmosphere"-type layer:
% is(indices) =  (p3(indices,1) < outer) .* (r_interpolated_lower < p3(indices,1));
% is(~indices) =  (p3(~indices,1) < outer) .* (r_interpolated_upper < p3(~indices,1));

% for the "crust"-type layer:
is(indices) =  (p3(indices,1) > inner) .* (r_interpolated_lower > p3(indices,1));
is(~indices) =  (p3(~indices,1) > inner) .* (r_interpolated_upper > p3(~indices,1));

is=logical(is);