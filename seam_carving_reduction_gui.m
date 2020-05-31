
function seam_carving_reduction_gui(imagen)

hfig = figure;
set(hfig, ...
	'Units', 'normalized', ...
	'name', sprintf('Image file: %s', imagen));

img = double(imread(imagen)) / 255;
[img_h, img_w, ~] = size(img);

 

mask_protect = false(img_h, img_w);
create_ui_control('text', [1 0 0.4],"Alto: ");
create_ui_control('text', [1 0.4 0.4],img_h);
create_ui_control('text', [2 0 0.4],"Ancho :");
create_ui_control('text', [2 0.4 0.4],img_w);

create_ui_control('text', [3 0 0.4], 'Alto:');
halto = create_ui_control('edit', [3 0.4 0.6], 0);
create_ui_control('text', [4 0 0.4], 'Ancho :');
hancho = create_ui_control('edit', [4 0.4 0.6], 0);

create_ui_control('pushbutton', 5, 'Define zona a proteger', ...
	{@define_mask, 'mask_protect'});

create_ui_control('pushbutton', 6, 'Limpiar zona a proteger', ...
	{@clear_mask, 'mask_protect'});

create_ui_control('text', [7 0 0.4], 'Coste');

hcost = create_ui_control('popupmenu', [7 0.4 0.6], ...
	{'Standard', 'Forward'});


create_ui_control('pushbutton', 10, 'Carve', @carve);

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
setappdata(hfig, 'haxes', haxes);
setappdata(hfig, 'hcost', hcost);
setappdata(hfig, 'halto', halto);
setappdata(hfig, 'hancho', hancho);


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

mask_protect = getappdata(hfig, 'mask_protect');%cargamos mascara a proteger

% properties of the method
hcost = getappdata(hfig, 'hcost');%cargamos el coste
cost_method_str = get(hcost, 'String');
cost_method = cost_method_str{get(hcost, 'Value')};

halto = getappdata(hfig, 'halto');%cargamos costuras
num_halto = str2double(get(halto, 'String'));
hancho = getappdata(hfig, 'hancho');%cargamos costuras
num_hancho = str2double(get(hancho, 'String'));

% hacemos el metodo
[img_carve, seams] = seam_carving_reduccion(img, halto, hancho, ...
	cost_method, mask_protect);

figure;
imagesc(img_carve);%una imagen que utiliza el rango completo de colores
axis image off;
title('Carved image');

% visualize carved seams
img_seams = draw_size(img, num_halto, num_hancho);

figure;
imagesc(img_seams);
axis image off;
title('Seams projected to the original image');

end


function redraw_image(hfig)

img = getappdata(hfig, 'img');
mask_protect = getappdata(hfig, 'mask_protect');
haxes = getappdata(hfig, 'haxes');

% dibujamos ambas mascaras
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
