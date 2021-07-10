%CLIMSCALE Rescale the color limits of an image to remove outliers with percentiles
%
%   clim=climscale(h, ptiles);
%
%   h: image handle (optional, otherwise h=gca)
%   ptiles: percentiles (optional, default [5 98])
function climscale(h, ptiles)
if nargin==0
    h=gca;
end

if nargin<2
    ptiles=[5 98];
end

data=get(get(h, 'children'), 'cdata');
clim=prctile(reshape(data,1,numel(data)), ptiles);
set(h,'clim',clim);