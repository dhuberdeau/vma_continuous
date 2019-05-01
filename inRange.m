function dst = inRange(src, upbound, lowbound)

% function dst = inRange(src, upbound, lowbound)
%
% David Huberdeau. 01/23/2018
%
% Emulate python function by same name;
% - dst(I) = lowbound(I) <= src(I) <= upbound && ... for each dimension
% 
% src should be nxmx3 - a nxm image of HSV values

dst = src(:,:,1) >= lowbound(1) & src(:,:,1) <= upbound(1) &...
    src(:,:,2) >= lowbound(2) & src(:,:,2) <= upbound(2) &...
    src(:,:,3) >= lowbound(3) & src(:,:,3) <= upbound(3);

