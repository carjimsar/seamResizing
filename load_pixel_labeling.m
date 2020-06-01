function labeling = load_pixel_labeling(img_path, color_1, color_2, ...
	color_3, color_4)


% Carga el etiquetado de los pixeles de la imagen dada. Los argumentos
% son opcionales, y en caso de que estén indica que colores usar para las etiquetas
% En caso contrario, se usan los predefinidos. 



% Los colores por defecto son: rojo 1, azul 2, verde 3 y amarillo 4
if ~exist('color_1', 'var')
	color_1 = [255 0 0];
end
if ~exist('color_2', 'var')
	color_2 = [0 0 255];
end
if ~exist('color_3', 'var')
	color_3 = [0 255 0];
end
if ~exist('color_4', 'var')
	color_4 = [255 255 0];
end

colors = [color_1; color_2; color_3; color_4];

img = imread(img_path);
[h, w, c] = size(img);
img = reshape(img, h * w, c);

labeling = zeros(h, w);
for i = 1:4
	ind_i = all(img == repmat(colors(i,:), h * w, 1), 2);
	labeling(ind_i) = i;
end

end 
