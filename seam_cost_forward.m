function [vertex_cost, topleft_cost, top_cost, topright_cost] = ...
    seam_cost_forward(img, mask_delete, mask_protect)
% Calcula el coste de los vertices en funcion de los pixeles que pudieran ser eliminados.
% Respeta la configuracion de proteccion y eliminacion.
%
% Entrada:
%    Matriz de una imagen RGB y mascaras binarias de eliminacion y preoteccion.


%
%  Salida:
%   Matriz con coste de los vertices basado en las mascaras de proteccion y eliminacion.
%	Costes de vertices superiores. 

[M, N, ~] = size(img);

% El coste de los vértices por defecto es cero
vertex_cost = zeros(M, N);
topleft_cost = zeros(M, N);
top_cost = zeros(M, N);
topright_cost = zeros(M, N);
I=squeeze(img);

for i=2:M
    for j=1:N-1
        if j>1
          topleft_cost(i,j)=abs(I(i,j+1)-I(i,j-1))+abs(I(i-1,j)-I(i,j-1));
          top_cost(i,j)=abs(I(i,j+1)-I(i,j-1));
          topright_cost(i,j)=abs(I(i,j+1)-I(i,j-1))+abs(I(i-1,j)-I(i,j+1));
        end
    end
end

topleft_cost(:,N)=Inf;
top_cost(:,1)=Inf;
top_cost(:,N)=Inf;
topright_cost(:,1)=Inf;

if exist('mask_delete', 'var')
    newValues = (-2*sqrt(3)* (M-1)) * mask_delete;
 % Aplica mascara de eliminacion
    opositeMask = mask_delete < 1;
    vertexWithoutMask = opositeMask .* vertex_cost;
    vertex_cost = vertexWithoutMask + newValues;
   

end

if exist('mask_protect', 'var')
% Aplica mascara de proteccion
    newValues = (2*sqrt(3)* (M-1)) * mask_protect;
    opositeMask = mask_protect < 1;
    vertexWithoutMask = opositeMask .* vertex_cost;
    vertex_cost = vertexWithoutMask + newValues;
    

end

end
