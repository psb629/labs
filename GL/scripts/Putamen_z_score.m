%% Striatum
tmp = niftiread('/mnt/ext6/GL/fmri_data/masks/mask.striatum.nii');
mask_striatum = (tmp ~= 0);
mesh_striatum = isosurface(mask_striatum, 0.5);
%% Whole Brain
tmp = niftiread('/mnt/ext6/GL/fmri_data/masks/full_mask.GL+tlrc.nii');
mask_brain = (tmp > 0);
mesh_brain = isosurface(smooth3(mask_brain, 'box', 11), 0.5);
%% Statistics
% tmp = niftiread('/mnt/sdb2/GL/fmri_data/stats/GLM.Move_Stop/statMove.group.nii');
% stat_beta = tmp(:,:,:,1,2);
% tmp = niftiread('/mnt/sdb2/GL/fmri_data/stats/GLM.reward/GL.group.zscore.nii');
% stat_beta = tmp(:,:,:,1,1);
tmp = niftiread('/mnt/ext6/GL/fmri_data/stats/GLM.reward.4s_shifted.SSKim/GL.group.Zscore.n24.nii');
stat_beta = tmp(:,:,:,1,2);
%%
[num_vertex, ~] = size(mesh_striatum.vertices);
color_map = zeros(num_vertex, 1);

for i = 1:num_vertex
    coord = round(mesh_striatum.vertices(i,:));
    color_map(i) = stat_beta(coord(2), coord(1), coord(3));
end

% vmax = max(color_map, [], 'all');
% vmin = min(color_map, [], 'all');
% color_map = (color_map - vmin) / (vmax - vmin);
% color_map = NNsmooth(mesh_striatum.vertices, mesh_striatum.faces, color_map', 2);
%%
ax1 = axes;

p2 = patch('Vertices', mesh_brain.vertices, 'Faces', mesh_brain.faces, ...
    'FaceColor', 'white', 'FaceAlpha', .3, 'EdgeColor', 'None', ...
    'AmbientStrength', 1, 'BackFaceLighting', 'unlit');

set(gca, 'color', 'k')

camlight;
lighting gouraud

xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis');

daspect([1 1 1]);
view(3);
axis ij;
axis equal
ax_hidden = axes('Visible', 'off', 'hittest', 'off');
%%
p1 = patch('Vertices', mesh_striatum.vertices, 'Faces', mesh_striatum.faces, ...
    'FaceColor', 'interp', 'FaceVertexCData', color_map, 'EdgeColor', 'None', ...
    'AmbientStrength', 1, 'DiffuseStrength', 0, 'SpecularStrength', 0, ...
    'FaceLighting', 'flat');

camlight;
lighting gouraud

colormap(flipud(max(0, cbrewer('div', 'RdBu', 255))));

xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis');

daspect([1 1 1]);
view(3);
axis ij;
axis equal
colorbar;

% set(p1, 'Parent', ax_hidden);

% linkprop([ax1 ax_hidden], {'CameraPosition', 'XLim', 'YLim', 'ZLim', 'Position',' CameraUpVetor'});