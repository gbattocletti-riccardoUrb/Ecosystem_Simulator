classdef analysis < handle

	% OBSOLETO --> CLASSE DA CANCELLARE
	
	properties
		X 			% column matrix; each row is a point (each column corresponds to a property)
		X_tilde		% column matrix equal to X but the points are weighted with respect to x_mean
		x_mean 		% barycenter of the point cloud X
		principal_directions	% direction in which the point cloud X_tilde presents
								% the most variability. Found with PCA method.
	end

	methods
		function obj = analysis()
			%
		end

		function obj = add_data(obj, creature)
			% creature is a vector of creature objects from which X and X_tilde are built
			
			% build X matrix
			N = length(creature);
			obj.X = zeros(N, 4);
		    for ii = 1:N
		        creature_obj = creature(ii);
		        obj.X(ii, 1) = creature_obj.size;
		        obj.X(ii, 2) = creature_obj.age;
		        obj.X(ii, 3) = creature_obj.speed;
		        obj.X(ii, 4) = creature_obj.sense_radius;
		    end

		    % compute barycenter
		    obj.x_mean = 1/N*sum(obj.X);

		    % compute "centered" point cloud
		    obj.X_tilde = obj.X - obj.x_mean;	% x_tilde(i) = x(i) - x_mean
		end

		function obj = PCA(obj)

		    % compute the proncipal component analysis
		    obj.principal_directions = pca(obj.X);
		end

		function plot_3D_characteristics_diagram(obj, N_figure)

			figure(N_figure)
		        title('Creature characteristics')
		        hold on
		        for ii=1:N
		            if creature(ii).dead == 1
		                plot3(speed(ii),size(ii),sense_radius(ii),'o','MarkerEdgeColor',[1 0 0],'LineWidth',1.3,'MarkerFaceColor',[color_vector(ii,1), color_vector(ii,2), color_vector(ii,3)],'MarkerSize',8)
		            else
		                plot3(speed(ii),size(ii),sense_radius(ii),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[color_vector(ii,1), color_vector(ii,2), color_vector(ii,3)],'MarkerSize',8)
		            end
		        end
		        plot3(mean(speed), mean(size), (mean(sense_radius)), 'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1.00 0.27 0],'MarkerSize',7)
		        axis([x_min x_max y_min y_max z_min z_max])
		        xlabel('Speed')
		        ylabel('Size')
		        zlabel('Sense radius')
		        
		        campos([5, 5, 5])
		        grid on
		        box on
		        
		        axis vis3d
		        view(60,40)

		end
	end

end