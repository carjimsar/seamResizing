function img = draw_pixels(img, pix_ind, color)

% Asigna a los pixeles un color segun lo que se haya especificado en su indice.
% La funcion trabaja con todos los colores de la imagen

[h, w, c] = size(img);

num_channels = max(c, numel(color));

if c < num_channels
    img = repmat(img, [1 1 num_channels]);
end

for i = 1:num_channels
    ind_i = (i - 1) * h * w + pix_ind;
    img(ind_i) = color(i);
end

end
