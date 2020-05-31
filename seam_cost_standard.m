function vertex_cost = seam_cost_standard(img, mask_delete, mask_protect)
% Calcular los costos de los vértices para la tarea de tallar las costuras.
% Los costos de los vértices para los píxeles individuales se basan en el 
% gradiente estimado de la imagen.
%
% Entrada:
%    img [MxNx3 (doble)] entrada RGB mask_delete [MxN (lógico)] pixeles de 
%    especulación de matriz para los cuales el costo del vértice debe ser lo 
%    suficientemente bajo para asegurar su prioridad de tallado mask_protector 
%    [MxN (lógico)] pixeles de especulación de matriz para los cuales el 
%    costo del vértice debe ser lo suficientemente bajo para asegurar su 
%    prioridad de tallado
%
% Salida:
%    costo_vértice [MxN (doble)] costo del vértice para los píxeles 
%    individuales basado en el gradiente estimado de la imagen y las máscaras
%    binarias que especifican los píxeles a ser eliminados y protegidos

% estimar los derivados parciales y calcular el coste_vértice



xSobel=[1/8 0 -1/8; 1/4 0 -1/4; 1/8 0 -1/8];
ySobel=[1/8 1/4 1/8; 0 0 0; -1/8 -1/4 -1/8]; 
I=rgb2gray(img);
[M,N]=size(I);

vertex_cost=abs(conv2(I,xSobel))+abs(conv2(I,ySobel));
vertex_cost(1,:)=[];
vertex_cost(M,:)=[];
vertex_cost(:,1)=[];
vertex_cost(:,N)=[];

if exist('mask_delete', 'var')
    %modificar el coste_vértice de los píxeles que deben ser eliminados
    for i=1:M
        for j=1:N
            if(mask_delete(i,j)==1)
                vertex_cost(i,j)=-2*M;
            end
        end
    end
end

if exist('mask_protect', 'var')
    % modificar el coste_vértice de los píxeles protegidos
    for i=1:M
        for j=1:N
            if(mask_protect(i,j)==1)
                vertex_cost(i,j)=2*M;
            end
        end
    end
end

end
