function img_seams = draw_seams(img, seams, direction)
% Con la lista de vetas, la imagen original, y la direccion de extraccion,
% devuelve la imagen original con las vetas extraidas marcadas en rojo.

SEAM_COLOR = [1 0 0];

direction_vertical = strcmpi(direction, 'vertical');

[h, w, ~] = size(img);
num_seams = size(seams, 2);

% A cada seam, le añade un offset para ser mostrado de forma correcta
for i = num_seams:-1:2
	for j = (i-1):-1:1
		seams(:,i) = seams(:,i) + (seams(:,i) >= seams(:,j));
	end
end

% Superpone los seams en la imagen original
img_seams = img;
for i = 1:num_seams
    if direction_vertical
		seam_ind = sub2ind([h w], 1:h, seams(:,i)');
	else
		seam_ind = sub2ind([h w], seams(:,i)', 1:w);
    end
    img_seams = draw_pixels(img_seams, seam_ind, SEAM_COLOR);
end

end
