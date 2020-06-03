function seam_carving_gui()

[archivo,ruta] = uigetfile(...    
    {'*.jpg; *.JPG; *.jpeg; *.JPEG; *.img; *.IMG; *.tif; *.TIF; *.tiff; *.TIFF; *.png; *.PNG','Supported Files'},...    
    'MultiSelect', 'on');

img = double(imread(strcat(ruta,archivo))) / 255;
[img_h, img_w, ~] = size(img);

hfig = figure;

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

create_ui_control('text', [8 0 0.4], 'Direccion:');
hdir = create_ui_control('popupmenu', [8 0.4 0.6], ...
	{'Vertical', 'Horizontal'});

create_ui_control('text', [9 0 0.4], 'Vetas:');
hseams = create_ui_control('edit', [9 0.4 0.6], 0);

create_ui_control('pushbutton', 10, 'Extraer', @carve);

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

% Funcion para redimensionar la imagen a las medidas
% indicadas. Es una modificacion de la funcion carve,
% que calculas las vetas a eliminar para conseguir la 
% la resolucion final. Ignora la configuracion de orientacion,
% ya que reduce por cada una segun sea necesario


hfig = ancestor(hobj, 'figure');
img = getappdata(hfig, 'img');

[img_h, img_w, ~] = size(img);

% Mascara definida por el usuario
% mask_delete = false(img_h, img_w);
% mask_protect = false(img_h, img_w);

mask_delete = getappdata(hfig, 'mask_delete');
mask_protect = getappdata(hfig, 'mask_protect');

% Recupera la configuracion necesaria desde la interfaz de usuario
hcost = getappdata(hfig, 'hcost');
cost_method_str = get(hcost, 'String');
cost_method = cost_method_str{get(hcost, 'Value')};

newheight = getappdata(hfig, 'newheight');
newheight = str2double(get(newheight, 'String'));
num_seams_h = img_h - newheight;

newidth = getappdata(hfig, 'newidth');
newidth = str2double(get(newidth, 'String'));
num_seams_w = img_w - newidth;

if((newheight == 0 || newidth == 0) || (newheight == img_h && newidth == img_w) || (newheight > img_h || newidth > img_w))
%Solo podemos redimensionar si se han indicado medidas validas

    msgbox('Las nuevas medidas deben ser mayor que 0 y al menos una menor que las originales','Error');

else
    
[img_media, seamsh, mask_delete, mask_protect] = seam_carving(img, 'Horizontal', num_seams_h, ...
    cost_method, mask_delete, mask_protect);

mask_delete = mask_delete';
mask_protect = mask_protect';

% Elimina las costuras
[img_carve, seamsv, ~, ~] = seam_carving(img_media, 'Vertical', num_seams_w, ...
    cost_method, mask_delete, mask_protect);

 img_seamsh = draw_seams(img, seamsh, 'Horizontal');
 img_seamsv = draw_seams(img_media, seamsv, 'Vertical');

figure;
imagesc(img_carve);
axis image off;
title('Imagen reducida');


figure;
imagesc(img_seamsh);
axis image off;
title('Vetas horizontales superpuestas');

figure;
imagesc(img_seamsv);
axis image off;
title('Vetas verticales superpuestas');




end
end

function define_mask(hobj, ~, mask_name)

hfig = ancestor(hobj, 'figure');
img = getappdata(hfig, 'img');
haxes = getappdata(hfig, 'haxes');

% Permite configurar los limites del poligono que forma la mascara
[x, y] = getline(haxes);

% Convierte el poligono a una mascara binaria para su aplicacion
mask = roipoly(img, x, y);
mask = logical(mask);

setappdata(hfig, mask_name, mask);
redraw_image(hfig);

end


function clear_mask(hobj, ~, mask_name)

hfig = ancestor(hobj, 'figure');
mask = getappdata(hfig, mask_name); 

% Reinicia la mascara estableciendola a 0 al completo
mask = false(size(mask));

setappdata(hfig, mask_name, mask);
redraw_image(hfig);

end


function carve(hobj, ~)
% Funcion encargada de la eliminacion de vetas

hfig = ancestor(hobj, 'figure');
img = getappdata(hfig, 'img');

% Mascaras definidas por el usuario en la interfaz
mask_delete = getappdata(hfig, 'mask_delete');
mask_protect = getappdata(hfig, 'mask_protect');

% Recupera la configuracion necesaria desde la interfaz de usuario
hcost = getappdata(hfig, 'hcost');
cost_method_str = get(hcost, 'String');
cost_method = cost_method_str{get(hcost, 'Value')};
hdir = getappdata(hfig, 'hdir');
direction_str = get(hdir, 'String');
direction = direction_str{get(hdir, 'Value')};
hseams = getappdata(hfig, 'hseams');
num_seams = str2double(get(hseams, 'String'));

if ( ~any(mask_delete(:)) && num_seams < 1  )

    msgbox('Para reducir la imagen, es necesario indicar cuantas vetas extraer y/o establecer una mascara de eliminacion.','Error');

else
    [img_carve, seams, ~, ~] = seam_carving(img, direction, num_seams, ...
        cost_method, mask_delete, mask_protect);

    figure;
    imagesc(img_carve);
    axis image off;
    title('Imagen reducida');

    % Funcion encargada de la superposicion de las vetas
    img_seams = draw_seams(img, seams, direction);

    figure;
    imagesc(img_seams);
    axis image off;
    title('Vetas superpuestas');
    
end
end


function redraw_image(hfig)

img = getappdata(hfig, 'img');
mask_delete = getappdata(hfig, 'mask_delete');
mask_protect = getappdata(hfig, 'mask_protect');
haxes = getappdata(hfig, 'haxes');

% Superpone la mascara a la imagen original
img = draw_mask(img, mask_delete, [1 0 0], 0.5);
img = draw_mask(img, mask_protect, [0 0 1], 0.5);

% Muestra la imagen por pantalla
imagesc(img, 'parent', haxes);

end

function reset (~, hfig)
    redraw_image(hfig);


end

function control = create_ui_control(style, pos, text, callback)

% Ancho y alto para la colocacion en la interfaz grafica
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
