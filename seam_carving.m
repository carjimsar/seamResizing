function [img_carved, seams] = seam_carving(img, direction, num_seams, ...
	cost_method, mask_delete, mask_protect)
% Elimina las vetas una a una de la imagen de entrada, teniendo
% en cuenta las mascaras de eliminacion y proteccion. Se puede especificar
% direccion de eliminacion y numero de seams a extraer.
%
% Entrada:
%  Matriz de imagen RGB
%  Direcccion de calculo de las vetas,
%	Simplemente hace o no la traspuesta de la imagen original
%	
%  num_seams, opcional, para establecer cuantas vetas eliminar
%
%  cost_method para establecer el metodo que se quiere usar para la extraccion
% 
%  mascaras binarias de eliminacion proteccion, opcionales
%
%
%  Salida:
%	imagen con vetas eliminadas
%	matriz que contiene las vetas que han sido eliminadas


img_carved = img;

% Solo se implementa el metodo vertical, si se quiere hacer horizontal, se traspone
if strcmpi(direction, 'horizontal')
	img_carved = permute(img_carved, [2 1 3]);
	mask_delete = mask_delete';
	mask_protect = mask_protect';
end

[h, w, ~] = size(img_carved);

% determinamos el número de costuras maximas podemos borrar,usamos 
% el número de costuras deseado para no usar más costuras que columnas

mask_delete_width = max(sum(mask_delete, 2));
num_seams = min(max(mask_delete_width, num_seams), w);

% Comprueba si es mas grande el numero de vetas que se quieren eliminar
% o las que son necesarias, se selecciona el mas grande, y se comprueba que no
% es mayor que la propia imagen.

% Elimina vetas tanto de la imagen original como de las mascaras.
seams = zeros(h, num_seams); %creamos un array vacio del tampaño requerido
for i = 1:num_seams
% Para ambos metodos, se usa la misma funcion de eliminacion pero varia la de calculo de costes
	if strcmpi(cost_method, 'standard')%si es estandar
		vertex_cost = seam_cost_standard(...
			img_carved, mask_delete, mask_protect);
        seams(:,i) = dp_path(vertex_cost);
    else 
		[vertex_cost, topleft_cost, top_cost, topright_cost] = ...
            seam_cost_forward(img_carved, mask_delete, mask_protect);
        seams(:,i) = dp_path(...
			vertex_cost, topleft_cost, top_cost, topright_cost);
	end
	
	% Elimina la veta encotnrada de la imagen y de las mascaras.
	img_carved = carve_seam(seams(:,i), img_carved);
	mask_delete = carve_seam(seams(:,i), mask_delete);
	mask_protect = carve_seam(seams(:,i), mask_protect);
end

% Traspone otra ve la imagen en caso de que se hiciese al principio
if strcmpi(direction, 'horizontal')
	img_carved = permute(img_carved, [2 1 3]);
end

end
