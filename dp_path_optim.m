function [path_cost, path_idx] = dp_path_optim(...
    vertex_cost, topleft_cost, top_cost, topright_cost)
% Solucion optima para encontrar de forma dinamica, para cada vertice del grafo MxN, el camino
% vertical mas corto empezando en el vertice de la primera fila (escogido de forma aleatoria) 
%
% Se recibe como entrada el coste del vertice y el de los adyacentes por arriba
%
% En path_cost se devuelve el coste total del camino
% En path_idx se devuelve el indice de columna del vertice anterior al (i,j), en el camino vertical 
% mas corto desde ek vertice de la primera columna (escogido de forma aleatoria) al vertice (i,j)

[M,N]=size(vertex_cost); 
path_cost = zeros(M, N);
path_idx = zeros(M, N);
path_cost(1,:)=vertex_cost(1,:); 
path_idx(1,:)=Inf; 


for i=2:M
 [valores, indices]=min([Inf, path_cost(i-1,1:N-1) + topleft_cost(i,2:N);
 path_cost(i-1,:) + top_cost(i,:);
 path_cost(i-1,2:N) + topright_cost(i,1:N-1), Inf]);
 path_cost(i,:)=valores+vertex_cost(i,:);
 for j=1:N
     switch indices(j)
         case 1
             indices(j)=j-1;
         case 2
             indices(j)=j;
         case 3
             indices(j)=j+1;
    end
 end
 path_idx(i,:)=indices;
end
end
