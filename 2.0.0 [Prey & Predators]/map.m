classdef map < handle
	
	properties
		map_dimensions
		food_vector
		food_probability_matrix
		food_probability_matrix_dimensions
		cell_size
	end

	methods

		function obj = map(x_dimension, y_dimension)
            % some argument checks - not strictly necessary
			if nargin < 2
				warning('not enough input arguments - default map dimensions will be used (200x200)')
				x_dimension = 200;
				y_dimension = 200;
			end
			if ~isnumeric(x_dimension) || ~isnumeric(y_dimension)
				error('map dimensions must be numeric arguments');
			end

			% map object creation and basic property assignation
			obj.map_dimensions = [x_dimension, y_dimension];	% store info about map dimensions
            
            %probability matrix default generation
            obj.food_probability_matrix_generation(10, 10, 3.5, 0.5);		
        end

		function display_map_info(obj)
        	fprintf('The variable %c has the following properties:\n', inputname(1))
        	fprintf('\tmap x dimension: %.2f\n', obj.map_dimensions(1))
        	fprintf('\tmap y dimension: %.2f\n', obj.map_dimensions(2))
        	fprintf('\tn° of rows: %i\n', obj.food_probability_matrix_dimensions(2))
        	fprintf('\tn° of columns: %i\n', obj.food_probability_matrix_dimensions(1))
        end
   
        function obj = remove_food(obj, position)
			[~, food_idx] = min(vecnorm((obj.food_vector - position)'));
			obj.food_vector(food_idx, :) = [];
		end
        
		function obj = clear_food(obj)
			obj.food_vector = [];
		end

        function obj = food_probability_matrix_generation(obj, m, n, steepness, amplification)  %%%%
            % m = number of rows of the probability matrix (x direction)
            % n = number of columns of the probability matrix (y direction)
            % steepness = how much the central peak is marked with respect to map peripheral areas
            % amplification = a secondary parameter to increase or decrease relative probability 
            % between the center of the matrix and the outer areas

            % argument default values if not declared
            if nargin == 3 
                amplification = 0.6;
                if nargin == 2
                    steepness = 3.5;
                    if nargin == 1
                        n = 10;
                        if nargin == 0
                            m = 10;
                        end
                    end
                end
            end

            % check arguments type
            if (floor(m) ~= m) || (floor(n) ~= n)
                error('m and n must be integers')
            end
            if ~isnumeric(steepness)
                error('steepness must be a numeric argument')
            end
            if ~isnumeric(amplification)
                error('amplification must be a numeric argument')
            end

            % save matrix dimensions in the object --> n° of columns, n° of rows (!!!)
            obj.food_probability_matrix_dimensions = [n, m];    

            % save cell dimensions  = sides of each cell (x side, y side)
            obj.cell_size = obj.map_dimensions./obj.food_probability_matrix_dimensions;

            % build m*n matrix with normal shape (peak of probability at the center of the matrix)
            normal_prob_distribution = makedist('Normal');
            x = linspace(-n/steepness, n/steepness, n); % steepness represent how distant from the mean value 
                                                        % the points of the normal distribution are taken.
                                                        % More distant points mean more difference between 
                                                        % peripheral region and center + the peak is circumscribed.
            y = linspace(-m/steepness, m/steepness, m);
            x_distribution = pdf(normal_prob_distribution, x);
            y_distribution = pdf(normal_prob_distribution, y);
            normal_matrix = y_distribution'*x_distribution;
            normal_matrix = normal_matrix*amplification;

            % build m*n rand matrix to add some randomness/variability to the distribution
            rand_matrix = rand(m, n);
            rand_matrix = rand_matrix.^2; % amplification of difference in rand probability (3 can also be used)          

            % combine the 2 matrices to build the final probability matrix
            temp_probability_matrix = rand_matrix.*normal_matrix;

            % normalization (total probability = 1)
            obj.food_probability_matrix = temp_probability_matrix/sum(sum(temp_probability_matrix));   
        end

		function food_probability_matrix_plot(obj, figure_number)

            Z = obj.food_probability_matrix;

            figure(figure_number)
                plot_obj = bar3(Z);
                for k = 1:length(plot_obj)
                    zdata = plot_obj(k).ZData;
                    plot_obj(k).CData = zdata;
                    plot_obj(k).FaceColor = 'interp';
                    % https://it.mathworks.com/help/matlab/creating_plots/color-3-d-bars-by-height-1.html
                    % https://it.mathworks.com/help/matlab/ref/matlab.graphics.primitive.patch-properties.html
                end
                xlabel('x')
                ylabel('y')
                zlabel('food spawn probability')
                title('food probability matrix')
                colorbar
                grid on
                box on
                axis vis3d
                campos([5, 5, 5])
                view(60, 40)
        end

        function obj = random_food_placement(obj, N)
			obj.food_vector = round(rand(N, 2).*obj.map_dimensions, 2);
        end

        function obj = sector_food_placement(obj, N)
        	% N is the number of food elements to be placed. 

        	% food vector initialization - not initialized with "zeros" since the exact length of the vector is not exactly known
            % TODO --> initialize as zeros with length equal to N plus some ""
            obj.food_vector = [];

            % number of food units to be placed in each cell of the matrix
            number_food_per_cell = round(obj.food_probability_matrix*N);

            for ii = 1:obj.food_probability_matrix_dimensions(2)        % rows
                for jj = 1:obj.food_probability_matrix_dimensions(1)	% columns 
                	cell_food = [ii-1, jj-1].*obj.cell_size + rand(number_food_per_cell(ii, jj), 2).*obj.cell_size;	% food spawning in one cell
                    obj.food_vector = [obj.food_vector; cell_food];     % add new food to the food vector	                               
                end
            end	

            % random place some foods if less than N have been placed
            if size(obj.food_vector, 1) ~= N % size(A, 1) is equivalent to lenght(A) in most cases
            	N_food_missing =  N - size(obj.food_vector, 1);
                %random_food_placement(obj, N_food_missing);
                food_missing = round(rand(N_food_missing, 2).*obj.map_dimensions, 2);
            else
                food_missing = 0;
            end
            obj.food_vector = [obj.food_vector; food_missing]; 

            % round food position to 2 decimal values
            obj.food_vector = round(obj.food_vector, 2);
        end

        function obj = food_spawn(obj, spawn_ratio)
            % spawn_ratio is any real number = new_food_unit/cycle.
            
            % kind of rounding process for non-integer spawn ratio - the decimal part is rounded "probabilistically"
            if ~isinteger(spawn_ratio)  
               decimal = mod(spawn_ratio, 1);
               integer = spawn_ratio - decimal;
               random_number = rand();
               if random_number <= decimal	% if the rand number is <= than the decimal part then one more food unit
               								% is spawned. Repeating this each cycle should converge to the desired
               								% spawn ratio (for sufficiently large repetitions)
                   spawn_ratio = integer + 1;
               else
                   spawn_ratio = integer;
               end
            end

            for ii = 1:obj.food_probability_matrix_dimensions(2)	% rows
                for jj = 1:obj.food_probability_matrix_dimensions(1)	% columns 
                	% New food number in a certain cell: the number is found by generating N random numbers and counting
                	% how many of them are under the spawn probability of a certain cell. That many food units are spawned.
                	rand_numbers_cell = rand(1, spawn_ratio);
                    number_food_per_cell = nnz(rand_numbers_cell <= obj.food_probability_matrix(ii,jj));

                    % food unit generation
                    food_vector_temp = round([ii-1, jj-1].*obj.cell_size + rand(number_food_per_cell, 2).*obj.cell_size, 2);
                    obj.food_vector = [obj.food_vector; food_vector_temp];  % add new food to the food vector
                end
            end
        end

	end    % end of methods

end