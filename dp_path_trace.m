function path = dp_path_trace(path_cost, path_idx)

% Realiza el camino vertical más corto en un grafo MxN desde un primer 
% vértice aleatorio de la primera fila hasta otro vértice aleatorio de
% la última fila.
%
% Entrada:
%	path_cost es el coste total del camino más corto definido anteriormente
%
%   path_idx es el índice columna del vertice anterior a aquel con el que 
%   se esta trabajando  en el camino más corte definido anteriormente.
%
% Salida:
%   path(i) = j en el caso de que el camino mas corto desde la primera columna
%   hasta la ultima pasa por el vertice (i,j)

[M,~]=size(path_cost);
path=zeros(1,M);
[~,idx]=min(path_cost(M,:));
path(M)=idx;
for i=1:M-1
    path(M-i)=path_idx(M-i+1,path(M-i+1));
end
path=path';
end