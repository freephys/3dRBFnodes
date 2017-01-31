function cnf = repel(cnf, k_value, repel_steps,s, outfile)

bins = 100;
offset = 15;         % divides the minimal separation in the main loop
% riesz_s = @(x)riesz(x,s+1);
dim = size(cnf,1);
pt_num = size(cnf,2);
directions = zeros(size(cnf));        

[IDX, D] = knnsearch(cnf', cnf', 'k', k_value+1);
IDX = IDX(:,2:end)';                     % drop the trivial first column in IDX

step = min(D(:,2));
cutoff = k_value*step;
fprintf( outfile, 'Minimal separation before repel steps:      %f\n', step);
fprintf( 'Minimal separation before repel steps:      %f\n', step)
outtemp = mean(D(:,2));
fprintf( outfile, 'Mean separation before repel steps:      %f\n\n',   outtemp);
fprintf(   'Mean separation before repel steps:      %f\n\n',   outtemp)
% % % % % % % % % % % % % % % % % % % % 
% % %  histogram
fprintf('\n')
clf;
clf;
figure(2);
h1=histogram(D(:,2),bins);
h1.FaceColor = [0 0 0.9];        % blue
hold on;
% % % % % % % % % % % % % % % % % % % % 
D_old=D;
D = reshape(D(:,2:end)',1,[]);


for iter=1:repel_steps
       cnf_neighbors = cnf(:,IDX);
       cnf_repeated = reshape(repmat(cnf,k_value,1), dim, k_value*pt_num); 
       riesz_gradient = cnf_repeated - cnf_neighbors;
%      vectors pointing from each node to its k_value nearest neighbors       
       within_cutoff = D<cutoff;
       norms_riesz = D.^(-(s+1)).*within_cutoff;
%      norms of riesz_gradient raised to the power -s-1
       riesz_gradient = repmat(norms_riesz.*(norms_riesz>0),3,1).*riesz_gradient;
       riesz_gradient = sum(reshape(riesz_gradient, dim, k_value, pt_num),2);
       riesz_gradient = reshape(riesz_gradient, dim, pt_num);
%      Riesz gradient for the node configuration       
       inverse_norms = sum(riesz_gradient.^2,1).^(-0.5);
       directions =  repmat(inverse_norms,3,1).*riesz_gradient; 
%      normalized Riesz gradient
       cnf_tentative = cnf + directions*step/offset/iter;
       domain_check = in_domain( cnf_tentative(1,:), cnf_tentative(2,:), cnf_tentative(3,:) );
       cnf(domain_check) = cnf_tentative(domain_check);    
end


[~, D] = knnsearch(cnf', cnf', 'k', k_value+1);   
outtemp = min(D(:,2));
fprintf( outfile, 'Minimal separation after:      %f\n',  outtemp );
fprintf(   'Minimal separation after:      %f\n',  outtemp );
outtemp =  mean(D(:,2));
fprintf( outfile, 'Mean separation after:      %f\n',  outtemp);
fprintf( 'Mean separation after:      %f\n',  outtemp)

% % % % % % % % % % % % % % % % % % % % 
% % %  histogram
figure(2);
h2 = histogram(D(:,2),bins);
h2.FaceColor = [0.9 0 0];       % red
saveas(h2,'./Output/histogram.png');
hold off;
