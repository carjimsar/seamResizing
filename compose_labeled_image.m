function img = compose_labeled_image(img, lab, img_weight)

% Forma la imagen RGB etiquetada partiendo de una imagen, ya sea en escala de grises o RGB,
% usando los valores de etiqueta para colores por defecto. El peo de la imagen para la composicion
% es un valor opcional
if ~exist('img_weight', 'var')
	img_weight = 0.4;
end

[h, w, c] = size(img);
switch c
	case 1
		img = repmat(img, [1 1 3]);
	case 3
	otherwise
		error('Only grayscale and RGB images are supported.');
end
rgb = reshape(img, h * w, 3);

num_labs = max(lab(:));
colors = get_label_colors();
num_colors = size(colors, 1);

% Asigna por pares las etiquetas a los valores RGB
for i = 1:min(num_colors, num_labs)
	idx_i = (lab == i);
	num_i = sum(idx_i(:));
	rgb(idx_i,:) = img_weight * rgb(idx_i,:) + ...
		(1 - img_weight) * repmat(colors(i,:), [num_i 1]);
end

img = reshape(rgb, [h w 3]);

end
