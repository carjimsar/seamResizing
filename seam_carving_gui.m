function seam_carving_gui()

[archivo,ruta] = uigetfile('*.jpg');

img = double(imread(strcat(ruta,archivo))) / 255;
[img_h, img_w, ~] = size(img);

hfig = figure;
% set(hfig, ...
% 	'Units', 'normalized', ...
% 	'name', sprintf('Image file: %s', imagen));


mask_delete = false(img_h, img_w);
mask_protect = false(img_h, img_w);


create_ui_control('text', [1 0 0.4],"Alto: ");
create_ui_control('text', [1 0.4 0.4],img_h);
create_ui_control('text', [2 0 0.4],"Ancho :");
create_ui_control('text', [2 0.4 0.4],img_w);

create_ui_control('pushbutton', 3, 'Define zona a borrar', ...
	{@define_mask, 'mask_delete'});

create_ui_control('pushbutton', 4, 'Limpiar zona a borrar', ...
	{@clear_mask, 'mask_delete'});

create_ui_control('pushbutton', 5, 'Define zona a proteger', ...
	{@define_mask, 'mask_protect'});

create_ui_control('pushbutton', 6, 'Limpiar zona a proteger', ...
	{@clear_mask, 'mask_protect'});

create_ui_control('text', [7 0 0.4], 'Coste');

hcost = create_ui_control('popupmenu', [7 0.4 0.6], ...
	{'Standard', 'Forward'});

create_ui_control('text', [8 0 0.4], 'Direction:');
hdir = create_ui_control('popupmenu', [8 0.4 0.6], ...
	{'Vertical', 'Horizontal'});

create_ui_control('text', [9 0 0.4], 'Seams:');
hseams = create_ui_control('edit', [9 0.4 0.6], 0);

create_ui_control('pushbutton', 10, 'Carve', @carve);

create_ui_control('text', [11 0 0.4], 'Alto:');
newheight = create_ui_control('edit', [11 0.4 0.6], 0);

create_ui_control('text', [12 0 0.4], 'Ancho:');
newidth = create_ui_control('edit', [12 0.4 0.6], 0);

create_ui_control('pushbutton', 13, 'Redimensionar', @resize);

haxes = axes(...
	'Units', 'normalized', ...
	'Box', 'on', ...
	'XGrid', 'off', 'YGrid', 'off', ...
	'Xlim', [1 img_w], 'Ylim', [1 img_h], ...
	'NextPlot', 'add', ...
	'interruptible', 'off', ...
	'YDir', 'reverse', ...
	'xlimmode', 'manual', 'ylimmode', 'manual', 'zlimmode', 'manual', ...
	'DataAspectratio', [1 1 1], ...
	'xtick', [], 'ytick', [], ...
	'Position', [0.25 0 0.74 1]);
imagesc(img, 'parent', haxes);

setappdata(hfig, 'img', img);
setappdata(hfig, 'mask_protect', mask_protect);
setappdata(hfig, 'mask_delete', mask_delete);
setappdata(hfig, 'haxes', haxes);
setappdata(hfig, 'hcost', hcost);
setappdata(hfig, 'hdir', hdir);
setappdata(hfig, 'hseams', hseams);
setappdata(hfig, 'newheight', newheight);
setappdata(hfig, 'newidth', newidth);

end

function resize(hobj, ~)

hfig = ancestor(hobj, 'figure');
img = getappdata(hfig, 'img');

[img_h, img_w, ~] = size(img);

% mask defined by the user
mask_delete = getappdata(hfig, 'mask_delete');
mask_protect = getappdata(hfig, 'mask_protect');

% properties of the method
hcost = getappdata(hfig, 'hcost');
cost_method_str = get(hcost, 'String');
cost_method = cost_method_str{get(hcost, 'Value')};

newheight = getappdata(hfig, 'newheight');
num_seams_h = img_h - str2double(get(newheight, 'String'));

newidth = getappdata(hfig, 'newidth');
num_seams_w = img_w - str2double(get(newidth, 'String'));

% carve seams from the image
[img_media, seamsh] = seam_carving(img, 'Horizontal', num_seams_h, ...
	cost_method, mask_delete, mask_protect);

%COMIENZA

[img_h, img_w, ~] = size(img_media);

% mask defined by the user
mask_delete = false(img_h, img_w);
mask_protect = false(img_h, img_w);



% carve seams from the image
[img_carve, seamsv] = seam_carving(img_media, 'Vertical', num_seams_w, ...
	cost_method, mask_delete, mask_protect);

%ACABA

figure;
imagesc(img_carve);
axis image off;
title('Carved image');

% visualize carved seams
img_seams_media = draw_seams(img, seamsh, 'Horizontal');
img_seams = draw_seams(img_seams_media, seamsv, 'Vertical');


figure;
imagesc(img_seams);
axis image off;
title('Seams projected to the original image');



end

function define_mask(hobj, ~, mask_name)

hfig = ancestor(hobj, 'figure');%vuelve atras la parte visible
img = getappdata(hfig, 'img');%cargamos la imagen
haxes = getappdata(hfig, 'haxes');%cargamos el poligono

% dejar que el usuario especifique las coordenadas del polígono delimitador
[x, y] = getline(haxes);

% convertir el polígono en una máscara binaria
mask = roipoly(img, x, y);%especifica los vértices poligonales como 
%coordenadas X-Y y en el sistema de coordenadas espaciales predeterminado.xiyi
mask = logical(mask);%convierte en una matriz de valores lógicos

setappdata(hfig, mask_name, mask);%almacena el resultanto con su nombre
redraw_image(hfig);%

end


function clear_mask(hobj, ~, mask_name)

hfig = ancestor(hobj, 'figure');%vuelve atras la parte visible
mask = getappdata(hfig, mask_name); %rescatamos los valores


mask = false(size(mask));% Limpiamos la mascara

setappdata(hfig, mask_name, mask);%la volvemos a cargar
redraw_image(hfig);

end


function carve(hobj, ~)

hfig = ancestor(hobj, 'figure');%vuelve atras la parte visible
img = getappdata(hfig, 'img');%cargamos la imagen

% mask defined by the user
mask_delete = getappdata(hfig, 'mask_delete');%cargamos mascara a borrar
mask_protect = getappdata(hfig, 'mask_protect');%cargamos mascara a proteger

% properties of the method
hcost = getappdata(hfig, 'hcost');%cargamos el coste
cost_method_str = get(hcost, 'String');
cost_method = cost_method_str{get(hcost, 'Value')};
hdir = getappdata(hfig, 'hdir');
direction_str = get(hdir, 'String');%cargamos direccion
direction = direction_str{get(hdir, 'Value')};
hseams = getappdata(hfig, 'hseams');%cargamos costuras
num_seams = str2double(get(hseams, 'String'));

% hacemos el metodo
[img_carve, seams] = seam_carving(img, direction, num_seams, ...
	cost_method, mask_delete, mask_protect);



figure;
imagesc(img_carve);%una imagen que utiliza el rango completo de colores
axis image off;
title('Carved image');

% visualize carved seams
img_seams = draw_seams(img, seams, direction);

figure;
imagesc(img_seams);
axis image off;
title('Seams projected to the original image');

end


function redraw_image(hfig)

img = getappdata(hfig, 'img');
mask_delete = getappdata(hfig, 'mask_delete');
mask_protect = getappdata(hfig, 'mask_protect');
haxes = getappdata(hfig, 'haxes');

% dibujamos ambas mascaras
img = draw_mask(img, mask_delete, [1 0 0], 0.5);
img = draw_mask(img, mask_protect, [0 0 1], 0.5);

% enseñamos la imagewn modificada
imagesc(img, 'parent', haxes);

end


function control = create_ui_control(style, pos, text, callback)

% valores de ancho y alto del elemento de control
CW = 0.25;
CH = 0.06;
MARG = 0.01;

if numel(pos) == 1
	pos = [0, 1 - pos * CH, CW - MARG, CH - MARG];
else
	pos = [pos(2) * CW, 1 - pos(1) * CH, pos(3) * CW - MARG, CH - MARG];
end

if ~exist('callback', 'var')
	callback = '';
end

control = uicontrol(...
	'Style', style, ...
	'Units', 'Normalized', ...
	'Position', pos, ...
	'String', text, ...
	'Callback', callback);

end


function mask_img = draw_mask(img, mask, color, alpha)

[h, w, c] = size(img);
mask_img = img;
for i = 1:c
	ind_i = find(mask) + (i - 1) * h * w;
	mask_img(ind_i) = alpha * mask_img(ind_i) + (1 - alpha) * color(i);
end

end
