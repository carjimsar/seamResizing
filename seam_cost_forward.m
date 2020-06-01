function [vertex_cost, topleft_cost, top_cost, topright_cost] = ...
    seam_cost_forward(img, mask_delete, mask_protect)
% Calcular los costos de los vértices para la tarea de tallado de costuras. 
% Los costos de los bordes se basan en los píxeles potencialmente tallados. 
% Los costos de los vértices aseguran la eliminación o protección de los 
% píxeles deseados.
%
% Entrada:
%    img [MxNx3 (double)] imagen RGB de entrada mask_delete [MxN (logical)] 
%    píxeles de especulación de la matriz para los cuales el costo del vértice
%    debe ser lo suficientemente bajo como para asegurar su prioridad de 
%    tallado mask_protect [MxN (lógico)] píxeles de especulación de la matriz
%    para los cuales el costo del vértice debe ser lo suficientemente bajo 
%    como para asegurar su prioridad de tallado


%
%  Salida:
%    costo_vertical [MxN (doble)] costos de vértices para píxeles individuales 
%    basados en las máscaras de supresión y protección costo_vertical [MxN 
%    (double)]    costos de los bordes superiores izquierdos costo_vertical 
%    [MxN (double)] costos de los bordes superiores derechos

[M, N, ~] = size(img);

% agregar código para computar topleft_cost, top_cost y topright_cost

% El coste_de_vértice por defecto es cero
vertex_cost = zeros(M, N);
topleft_cost = zeros(M, N);
top_cost = zeros(M, N);
topright_cost = zeros(M, N);
I=squeeze(img);%devuelve una matriz con los mismos elementos que la matriz
%de entrada A, pero con dimensiones de longitud 1 eliminadas.
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
 % modificar el coste_vértice de los píxeles que deben ser eliminados
    newValues = (-2*sqrt(3)* (M-1)) * mask_delete;
    opositeMask = mask_delete < 1;
    vertexWithoutMask = opositeMask .* vertex_cost;
    vertex_cost = vertexWithoutMask + newValues;
   

end

if exist('mask_protect', 'var')
% modificar el coste_vértice de los píxeles protegidos
    newValues = (2*sqrt(3)* (M-1)) * mask_protect;
    opositeMask = mask_protect < 1;
    vertexWithoutMask = opositeMask .* vertex_cost;
    vertex_cost = vertexWithoutMask + newValues;
    

end

end
