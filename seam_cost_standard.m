function vertex_cost = seam_cost_standard(img, mask_delete, mask_protect)
% Calcula el coste de las vetas para su extraccion.
% El coste de los vertices esta basado en la estimacion del gradiente de la imagen

% Recibe una imagen RGB, y dos mascaras binarias: una de proteccion y otra de eliminacion.
% Se aplican para establecer los costes de los pixeles indicados de forma que siempre o nunca sean
% escogidos para ser eliminados

% Devuelve una matriz con el coste de cada vertice.



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
    newValues = (-2 * M) * mask_delete;
    opositeMask = mask_delete < 1;
    vertexWithoutMask = opositeMask .* vertex_cost;
    vertex_cost = vertexWithoutMask + newValues;
    
    
end

if exist('mask_protect', 'var')
% modificar el coste_vértice de los píxeles protegidos
    newValues = (2 * M) * mask_protect;
    opositeMask = mask_protect < 1;
    vertexWithoutMask = opositeMask .* vertex_cost;
    vertex_cost = vertexWithoutMask + newValues;
    
end

end
