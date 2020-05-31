function [path_cost, path_idx] = dp_path_optim(...
    vertex_cost, topleft_cost, top_cost, topright_cost)
% Dynamic programming optimization to find for each vertex of MxN graph the
% shortest vertical path starting in arbitrary first row vertex.
%
% Input:
%   vertex_cost [MxN (double)] vertex_cost(i,j) is cost of the vertex (i,j)
%   topleft_cost [MxN (double)] topleft_cost(i,j) is cost of the edge
%     from the vertex (i-1,j-1) to vertex (i,j)
%   top_cost [MxN (double)] top_cost(i,j) is cost of the edge
%     from the vertex (i-1,j) to vertex (i,j)
%   topright_cost [MxN (double)] topright_cost(i,j) is cost of the edge
%     from the vertex (i-1,j+1) to vertex (i,j)
%
% Output:
%   path_cost [MxN (double)] path_cost(i,j) is the total cost of the
%     shortest vertical path starting in arbitrary first row vertex (1,*)
%     and ending in the vertex (i,j)
%   path_idx [MxN (double)] path_idx(i,j) is the column index of vertex
%     preceding the vertex (i,j) on the shortest vertical path from
%     arbitrary first row vertex (1,*) to the vertex (i,j); path_idx(i,j)
%     for i > 1 is from {j-1,j,j+1}; path_idx(1,j) can be aribtrary
% add your code here
[M,N]=size(vertex_cost); 
path_cost = zeros(M, N);
path_idx = zeros(M, N);
path_cost(1,:)=vertex_cost(1,:); %The cost of the first row is just the vertex cost
path_idx(1,:)=Inf; %There's no path to follow backwards


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
