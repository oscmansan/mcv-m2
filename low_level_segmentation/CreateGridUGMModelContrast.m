function [edgePot,edgeStruct]=CreateGridUGMModelContrast(im, K, gamma)
% Reference: https://www.microsoft.com/en-us/research/wp-content/uploads/2004/08/siggraph04-grabcut.pdf

tic

nRows = size(im,1);
nCols = size(im,2);
nNodes = nRows*nCols;

adj = sparse(nNodes,nNodes);

% Add Down Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],repmat(nRows,[1 nCols]),1:nCols); % No Down edge for last row
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+1)) = 1;

% Add Right Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],1:nRows,repmat(nCols,[1 nRows])); % No right edge for last column
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+nRows)) = 1;

% Add Up/Left Edges
adj = adj+adj';
edgeStruct = UGM_makeEdgeStruct(adj,K);

imRGB = double(Lab2RGB(im));

% Compute beta constant
sdiff = zeros(edgeStruct.nEdges, 1);
for e = 1:edgeStruct.nEdges
   n1 = edgeStruct.edgeEnds(e,1);
   n2 = edgeStruct.edgeEnds(e,2);
   [i1,j1] = ind2sub([nRows, nCols], n1);
   [i2,j2] = ind2sub([nRows, nCols], n2);
   p1 = imRGB(i1,j1,:);
   p2 = imRGB(i2,j2,:);
   sdiff(e) = norm(squeeze(p1-p2))^2;
end
beta = 1/(2*mean(sdiff(:)));

edgePot = zeros(K,K,edgeStruct.nEdges);
for e = 1:edgeStruct.nEdges
   w = gamma * exp(beta*sdiff(e));
   edgePot(:,:,e) = ones(K,K);
   for i = 1:K
       edgePot(i,i,e) = w;
   end
end

toc;
