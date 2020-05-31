function seam_carving_carga()
hfig1 = figure;
create_ui_control('text', [1 0 0.4], 'Imagen:');
himg = create_ui_control('edit', [1 0.4 1], 'Nombre imagen');

create_ui_control('pushbutton', 2, 'Cargar Imagen', ...
	@cargarImagen);
create_ui_control('text', [3 0 0.4], 'Direction:');
control = create_ui_control('popupmenu', [3 0.4 1], ...
	{'Eliminar elemento', 'Cambiar tamaño'});
setappdata(hfig1, 'hcontrol', control);
setappdata(hfig1, 'himg', himg);
end
function cargarImagen(hobj, ~)
hfig1 = ancestor(hobj, 'figure');%vuelve atras la parte visible
image = getappdata(hfig1, 'himg');%cargamos la imagen
imagen=get(image, 'String');
control = getappdata(hfig1, 'hcontrol');
control_str = get(control, 'String');%cargamos direccion
control_t = control_str{get(control, 'Value')};

if strcmpi(control_t, 'Eliminar elemento')%compara sting
    seam_carving_gui(imagen);    
end
if strcmpi(control_t, 'Cambiar tamaño')%compara sting
    seam_carving_reduction(imagen);
end
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