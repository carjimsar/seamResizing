function data_carved = carve_seam(seam, data)
% Elimina una costura de una matriz MxNx3, tipica de una imagen RGB
%
% Recibe la matriz en data y el seam, que es una columa de pares que representan
% las coordenadas de los pixeles a extraer
%
% Devuelve una matriz del mismo tipo, con una columna menos

[h, w, c] = size(data);

if islogical(data)
    data_carved = false(h, w - 1, c);
else
    data_carved = zeros(h, w - 1, c);
end


for i=1:h
    mientras=data(i,:,:);
    mientras(:,seam(i),:)=[];
    data_carved(i,:,:)=mientras;
end


end
