function [path, path_cost, path_idx] = dp_path(...
    vertex_cost, topleft_cost, top_cost, topright_cost)
		
% Combina las funciones de busqueda optima de camino
% y trazado del mismo.
%
% Se recibe como entrada el coste del vertice y el de los adyacentes por arriba
%
% Se devuelve el par de las coordenadas del vertice en path si el camino vertical mas corto pasa por este
% En path_cost se devuelve el coste total del camino
% En path_idx se devuelve el indice de columna del vertice anterior al (i,j), en el camino vertical 
% mas corto desde ek vertice de la primera columna (escogido de forma aleatoria) al vertice (i,j)



[h, w] = size(vertex_cost);

% Gestiona los vertices sin coste definido
if ~exist('topleft_cost', 'var')
    topleft_cost = zeros(h, w);
end
if ~exist('top_cost', 'var')
    top_cost = zeros(h, w);
end
if ~exist('topright_cost', 'var')
    topright_cost = zeros(h, w);
end


[path_cost, path_idx] = dp_path_optim(vertex_cost, topleft_cost, top_cost, topright_cost);
path = dp_path_trace(path_cost, path_idx);

end
