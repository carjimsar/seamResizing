function [img_carved, seams] = seam_carving(img, direction, num_seams, ...
	cost_method, mask_delete, mask_protect)
% Talla de forma incremental las costuras de la imagen dada tomando 
%en cuenta los píxeles a ser eliminados y los píxeles a ser protegidos. 
%También se puede especificar la dirección y el número mínimo de costuras.
%
% Entrada:
%  img [MxNx3 (double)] entrada RGB dirección de la imagen [string] 
%   especificando la dirección de las costuras {'vertical', 'horizontal'} 
%   a tallar de la imagen num_seams [int] número mínimo de costuras talladas;
%   el número real de costuras talladas se determina de manera que todos 
%   los píxeles marcados para ser eliminados serán tallados cost_method 
%   [string] especificando qué función de costo debe ser usada para los 
%   vértices y bordes {'estándar', 'forward'} mask_delete [MxN (lógico)] 
%   máscara que denota los píxeles a ser eliminados, mask_protect 
%   [MxN (lógico)] máscara que denota los píxeles a ser protegidos
%
%  Salida:
%   img_carved [Mx(N-K)x3 o (M-K)xNx3 (double)] imagen RGB de salida 
%   que tiene costuras K talladas [MxK o KxN] matriz que contiene costuras
%   K verticales u horizontales que han sido talladas

img_carved = img;

% el siguiente algoritmo funciona sólo con costuras verticales, así que 
% transponer la imagen que queremos tallar en las costuras horizontales
if strcmpi(direction, 'horizontal')%compara sting
	img_carved = permute(img_carved, [2 1 3]);%permuta segun el orden
	mask_delete = mask_delete';
	mask_protect = mask_protect';
end

[h, w, ~] = size(img_carved);

% determinamos el número de costuras maximas podemos borrar,usamos 
% el número de costuras deseado para no usar más costuras que columnas

mask_delete_width = max(sum(mask_delete, 2));
num_seams = min(max(mask_delete_width, num_seams), w);
%se mira si es mas grande el numero optenido o el propuesto y el mas
%pequeño entre el total y el optenido

% tallar costuras verticales de la imagen y de ambas máscaras iterativas
seams = zeros(h, num_seams); %creamos un array vacio del tampaño requerido
for i = 1:num_seams
%   utilizamos el mismo procedimiento de programación dinámica para encontrar
%   la costura más corta, pero con diferentes costes de vértices y bordes
%  dependiendo de la funcion elegida
	if strcmpi(cost_method, 'standard')%si es estandar
		vertex_cost = seam_cost_standard(...
			img_carved, mask_delete, mask_protect);
        seams(:,i) = dp_path(vertex_cost);
    else %si no es forward
		[vertex_cost, topleft_cost, top_cost, topright_cost] = ...
            seam_cost_forward(img_carved, mask_delete, mask_protect);
        seams(:,i) = dp_path(...
			vertex_cost, topleft_cost, top_cost, topright_cost);
	end
	
	%tallar la costura que se encuentra actualmente en la imagen y ambas 
    %máscaras
	img_carved = carve_seam(seams(:,i), img_carved);
	mask_delete = carve_seam(seams(:,i), mask_delete);
	mask_protect = carve_seam(seams(:,i), mask_protect);
end

% y devolvemos la imagen, pero si es horizontal tenemos que darle la vuelta
if strcmpi(direction, 'horizontal')
	img_carved = permute(img_carved, [2 1 3]);
end

end
