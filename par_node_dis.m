dim = 3;
oct = 2^dim;
% 
% vertices of the unit cube
cube_vectors = zeros(oct,3);
count=1;
for i=0:1
    for j=0:1
        for k=0:1
            cube_vectors(count,:) = [i j k];
            count = count + 1;
        end
    end
end

N = 40; %    number of boxes per side of the cube

max_nodes_per_box = 20; 
tolerance = 1e-4;


corners = -ones(N^dim,dim);
nodes = zeros(N^dim, max_nodes_per_box+1,dim); % the first element or vector will contain the number 
                    %  of nodes in the current box
                    
tic

parfor i=1:N^dim
    corners(i,:) = [rem((i-1), N)/N  floor(rem(i-1, N^2)/N)/N floor((i-1)/N^2)/N];   % TODO
    eval_pts = num2cell(bsxfun(@plus, corners(i,1:2), cube_vectors(:,1:2)/N),2);
%     eval_pts = num2cell(bsxfun(@plus, corners(i,:), cube_vectors/N),2);
%     fun_values = cellfun(@density, eval_pts);
    fun_values = cellfun(@trui, eval_pts);
 % % % % % % % %            
%     [max_dens, ind1] = max(fun_values);
%     [min_dens, ind2] = min(fun_values);
%     radius_min = 2/(2+3*max_dens);
%     radius_max = 2/(2+3*min_dens);
%     current_box = make_fcc_scaled(corners(i,:)+radius_min/2/N, corners(i,:)+1/N-radius_min/2/N, radius_min/N, radius_max/radius_min, cell2mat(eval_pts(ind1)),cell2mat(eval_pts(ind2)));
%         if(size(current_box,1)>max_nodes_per_box)
%             fprintf ('Warning: Nodes in box exceeds maximum. Consider raising maximum or adjusting radius function')
%             break
%         end    
% % % % % % % %             
    current_box = make_irrational_nodes(corners(i,:), corners(i,:)+1/N, floor(max_nodes_per_box * mean(fun_values)));   
% % % % % % %     

    nodes = writeNodes(nodes, current_box, i);
end



% nodes_sparse = reshape(nodes(:,2:end,:),3,[]);       % this contains
% all the sparsity; we will turn nodes into a full matrix instead

num_nodes = sum(nodes(:,1,1));

cnf = zeros(num_nodes,dim);
count = 1;
for i=1:N^dim
    cur_num = nodes(i,1,1);
    cnf(count:(count+cur_num-1),:) = nodes(i, 2:cur_num+1, :);
    count = count + cur_num;
end

% % % % % % % % % % % % % 

pbaspect([1 1 1])
figure(1);
fprintf( 'Number of nodes:      %d\n\n',  num_nodes )
plot3(cnf(:,1), cnf(:,2), cnf(:,3),  '.k');


k_value = 15;           % number of nearest neighbors used in the knnsearch
repel_steps = 1;

cnf = repel(cnf, k_value, repel_steps);
toc 

pbaspect([1 1 1])
figure(2);
plot3(cnf(:,1), cnf(:,2), cnf(:,3),  '.k');