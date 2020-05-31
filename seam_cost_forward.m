function [vertex_cost, topleft_cost, top_cost, topright_cost] = ...
    seam_cost_forward(img, mask_delete, mask_protect)
% Calcular los costos de los v�rtices para la tarea de tallado de costuras. 
% Los costos de los bordes se basan en los p�xeles potencialmente tallados. 
% Los costos de los v�rtices aseguran la eliminaci�n o protecci�n de los 
% p�xeles deseados.
%
% Entrada:
%    img [MxNx3 (double)] imagen RGB de entrada mask_delete [MxN (logical)] 
%    p�xeles de especulaci�n de la matriz para los cuales el costo del v�rtice
%    debe ser lo suficientemente bajo como para asegurar su prioridad de 
%    tallado mask_protect [MxN (l�gico)] p�xeles de especulaci�n de la matriz
%    para los cuales el costo del v�rtice debe ser lo suficientemente bajo 
%    como para asegurar su prioridad de tallado


%
%  Salida:
%    costo_vertical [MxN (doble)] costos de v�rtices para p�xeles individuales 
%    basados en las m�scaras de supresi�n y protecci�n costo_vertical [MxN 
%    (double)]    costos de los bordes superiores izquierdos costo_vertical 
%    [MxN (double)] costos de los bordes superiores derechos

[M, N, ~] = size(img);

% agregar c�digo para computar topleft_cost, top_cost y topright_cost

% El coste_de_v�rtice por defecto es cero
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
    % modificar el coste_v�rtice de los p�xeles que deben ser eliminados
    for i=1:M
        for j=1:N
            if(mask_delete(i,j)==1)
                vertex_cost(i,j)=-2*sqrt(3)*(M-1);
            end
        end
    end
end

if exist('mask_protect', 'var')
    % modificar el coste_v�rtice de los p�xeles protegidos
    for i=1:M
        for j=1:N
            if(mask_protect(i,j)==1)
                vertex_cost(i,j)=2*sqrt(3)*(M-1);
            end
        end
    end
end

end
