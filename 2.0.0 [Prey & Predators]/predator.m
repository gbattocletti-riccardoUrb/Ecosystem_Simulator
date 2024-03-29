classdef predator < handle & matlab.mixin.Copyable    %enable the possibility of copying the properties of the objects
    
    properties (Constant)
        food_energy_value = 250;
        coeff_vis_border = 0.2;       % the creature does not go closer to the borders than coeff*sense radius 
        satiety_coeff = 0.6;          % over <coeff>% max energy the creature does not look for more food
        var_ang = 1/4*pi;             % angle variation in random movement
        % mutation_probability?
    end
        
    properties
        age;                % n� of cycles survived           
        size;               % size of the creature. Bigger creatures can store more energy but also consume more
        speed;              % speed of the creature. Faster creatures also consume more energy
        sense_radius;       % sense in which the creature can detect food presence
        position;           % vector [x, y] with the current cohordinates of the creature
        angle_history;      % saves the direction of last movement to be able to follow a "reasonable" path during random movement
        energy;             % current energy of the creature. If <=0 the creature dies   
        max_energy;         % max energy that the creature can store
        energy_consumption; % energy consumed at each time step. Depends on size, speed and sense radius
        eating_distance     % distance from the food at which the creature can eat the food (consider the map to be about 100x100)
        dead;               % boolean. 0 if alive, 1 if dead
        birth_cycle;        % cycle of birth of the creature
        death_cycle;        % cycle of death of the creature
        death_step;         % inside the cycle of death, als o the step of death is saved
        energy_history;     % saves the energy value at each time step
        position_history;   
        memory_vec;         % vector that stores the positions of food sensed by the creature but that the creature has not reached yet. 
                            % Note that those food units could be eaten by other creatures
        go_back_distance;   % distance from already discovered food 
        food_eaten;         % n� of food units eaten --> probably will become a vector (to store all the food eaten during all the cycles)
        generation;         % n�of generation at which the creature appears --> depends on the generation of the father +1
        ID;                 % unique number identifying the creature
        father_ID;          % ID of the father (to be able to trace back the parents of each creature)
    end

    methods
        function obj = predator()
            %CREATURE Construct an instance of this class
            %   Creates a creature object with a set of 
            %   starting characteristics generated by one of
            %   the designated functions (see below). Many
            %   properties, like for example the size,
            %   speed and sense radius are constant, other 
            %   like age and position change with time.
        end

        function obj = predator_vec(obj, x)
            % used to initialize creature column vectors of known dimension
            if x == 0
                obj = [];
            else
                obj(x, 1) = predator();
            end
            % usage:
            % vec_name = creature();
            % vec_name = vec_name.creature_vec(rows, columns);
        end
        
        function obj = random_characteristic_generator(obj, world, N_cycle)     
            %RANDOM_CHARACTERISTIC_GENERATOR generates randomly all the starting
            %   characteristics of a creature.
            % speed = distance covered in 1 turn
            % sense radius = distance at which food is detected
            % size = dimension. bigger size lead to major energy consumption per turn, but
            %        allows a bigger energy storage (major max_energy). Could be also
            %        linked to bigger sense radius and lower velocity.
            global ID
            
            speed_mean = 0.9;
            speed_variance = 0.2;
            sense_radius_mean = 20;
            sense_radius_variance = 5; 
            size_mean = 1;
            size_variance = 0.4;
            max_energy_mean = 500;
            max_energy_variance = 50;
          
            energy_coeff = 0.8;         % 80% of max energy
            n_sigma = 3;                % each variance is the sigma-3 variance (99.7% coverage)
            
            % properties assignation
            obj.sense_radius =  round(abs(normrnd(sense_radius_mean, sense_radius_variance/n_sigma)), 2);            
            obj.size =  round(abs(normrnd(size_mean, size_variance/n_sigma)), 2);
            obj.max_energy =round(abs(normrnd(max_energy_mean, max_energy_variance/n_sigma)), 2);
            obj.speed = round(abs(normrnd(speed_mean, speed_variance/n_sigma)), 2);
            obj.go_back_distance = round(abs(obj.sense_radius*2), 2);
            obj.energy_consumption = round(obj.size^3*obj.speed^2 + obj.sense_radius*0.01 ,2);   % sense radius dependence in order to limit it during mutation
            obj.eating_distance = obj.size;      
            
            obj.energy = energy_coeff*obj.max_energy;                       % initial energy
            obj.birth_cycle = N_cycle;                                      % cycle of birth
            obj.position = round([rand()*world.map_dimensions(1,1), rand()*world.map_dimensions(1,2)], 2);     % random positioning of creature
               
            % fixed characteristics
            obj.age = 0;
            obj.death_cycle = NaN;
            obj.death_step = NaN;
            obj.dead = 0;
            obj.food_eaten = 0;
            obj.generation = 1;
            obj.ID = ID;
            obj.father_ID = 0;
            
            % vector initialization
            obj.position_history(1, :) = obj.position;
            obj.energy_history = [obj.energy, zeros(1, N_cycle-1)];
        end
        
        function obj = action(obj, world, population)
            %ACTION is the main creature function. Inside action, it is decided which task 
            %    the creature will try to achieve, all the properties are updated and so
            %    on. It is runned, for each creature, once every step of the simulation.
            global Step 
             
            % 	Function definition:
            current_pos = obj.position;                                     % current creature position
            N_preys = length(population.alive_preys);
            food_position = zeros(N_preys,2);
            for ii = 1:N_preys
                food_position(ii,:) = population.alive_preys(ii).position_history(end,:);
            end                         
            delta_x = food_position(:,1) - current_pos(1);
            delta_y = food_position(:,2) - current_pos(2);
            [~, food_idx] = min(delta_x.^2+delta_y.^2);                     % select closest food as next target
            
            mem_ind = delta_x.^2 + delta_y.^2 <= obj.sense_radius^2;        % find the seen food index
            obj.memory_vec = [obj.memory_vec;[food_position(mem_ind,1),food_position(mem_ind,2)]];  % update the memory vector
            obj.memory_vec = unique(obj.memory_vec,'rows');                 % delete the duplicates (if the same food is seen more than once)
            
            delta_x = food_position(food_idx, 1) - current_pos(1);
            delta_y = food_position(food_idx, 2) - current_pos(2);
            
            if obj.energy <= 0                                              % check if the creature is alive
                obj.death(population);             
            else      
                if obj.energy <= obj.satiety_coeff*obj.max_energy && ~isempty(food_position)           % check if it is hungry and avoid the cycle in case of no food
                    theta = atan2(delta_y, delta_x);
                    if delta_x^2+delta_y^2 <= obj.eating_distance^2         % check if the food is eatable        
                        distance = sqrt(delta_x^2+delta_y^2);
                        directed_movement(obj, theta, distance, world);
                        obj.eat(population, food_idx);
                        [~,mem_erase_ind] = ismember(obj.memory_vec,[food_position(food_idx, 1),food_position(food_idx, 2)],'rows');    % find food in memory vector
                        obj.memory_vec(logical(mem_erase_ind),:) = [];                                                                  % erase food from memory
                    
                    elseif delta_x^2+delta_y^2 <= obj.sense_radius^2        % check if the food is food visible     
                        if delta_x^2+delta_y^2 < obj.speed^2
                            distance = sqrt(delta_x^2+delta_y^2);
                            directed_movement(obj, theta, distance, world);
                        else
                            directed_movement(obj, theta, obj.speed, world);
                        end
                        
                    elseif ~isempty(obj.memory_vec)                         % check if the food is in memory
                        [~, food_idx] = min((obj.memory_vec(:, 1) - current_pos(1)).^2+(obj.memory_vec(:, 2) - current_pos(2)).^2);     % find the closest food in memory
                        if sqrt((obj.memory_vec(food_idx, 1) - current_pos(1)).^2+(obj.memory_vec(food_idx, 2) - current_pos(2)).^2) <= obj.go_back_distance    % if food is inside the go back distance
                            if (obj.memory_vec(food_idx, 1) - current_pos(1))^2 + (obj.memory_vec(food_idx, 2) - current_pos(2))^2 <= obj.sense_radius^2 && ~ismember([obj.memory_vec(food_idx, 1),obj.memory_vec(food_idx, 2)],food_position,'rows')  % check if food is inside sense radius and if it has already been eaten
                                obj.memory_vec(food_idx,:) = [];
                                random_movement(obj, world);
                            else                                            % go to food in memory
                                delta_x = obj.memory_vec(food_idx, 1) - current_pos(1);
                                delta_y = obj.memory_vec(food_idx, 2) - current_pos(2);
                                theta = atan2(delta_y, delta_x);         
                                directed_movement(obj, theta, obj.speed, world); 
                            end      
                        else
                            random_movement(obj, world);                    % food is outside the go back distance
                        end
                    else
                        random_movement(obj, world);                        % no food in memory 
                    end
                else
                    random_movement(obj, world);                            % no hungry
                end
                obj.energy_history(Step) = obj.energy;
            end         
        end
        
        function obj = death(obj, population)
            global Step      
            obj.death_cycle = obj.birth_cycle+obj.age;
            obj.death_step = Step;
            obj.dead = 1;
            obj.position_history = [obj.position_history; obj.position];
            obj.energy_history(Step) = obj.energy;
            population.dead_predators = [population.dead_predators; obj];
            population.dead_position = [population.dead_position; obj.position];
        end
        
        function obj = eat(obj, population, idx)
           population.alive_preys(idx).death(population);
           obj.energy = obj.energy + obj.food_energy_value;
           obj.food_eaten = obj.food_eaten + 1;
           if obj.energy >= obj.max_energy
               obj.energy = obj.max_energy;
           end
        end
        
        function obj = directed_movement(obj, theta, distance, world)
        	%DIRECTED_MOVEMENT is the function used to move
        	% 	straight toward any food unit detected in 
        	% 	the neighborhood of the creature.
        	%	The value m represents the direction of movement.
        	%	The value delta_x is used to understand the
        	%	"verse" of the movement along direction m
        	move_x = round(distance*cos(theta), 2);
            move_y = round(distance*sin(theta), 2);
            [move_x, move_y] = check_borders(obj, move_x, move_y, world);
	        obj.position = obj.position + [move_x, move_y];
            obj.angle_history = [obj.angle_history,theta];
            obj.energy = obj.energy - obj.energy_consumption;
            obj.position_history = [obj.position_history; obj.position];
        end

        function obj = random_movement(obj, world)
        	%RANDOM_MOVEMENT is the function used to move
        	% 	in an arbitrary direction; it is used if
        	%	no food unit has been detected
            if isempty(obj.angle_history)
                theta = rand*2*pi;
            else
                theta = obj.angle_history(end)+2*obj.var_ang*rand-obj.var_ang;  %+-45� variation
            end
            move_x = round(obj.speed*cos(theta), 2);
            move_y = round(obj.speed*sin(theta), 2);
            [move_x, move_y] = borders_vision(obj, move_x, move_y, world);
            obj.position = obj.position + [move_x, move_y];
            theta = atan2(move_y, move_x);
            obj.angle_history=[obj.angle_history,theta];
            obj.energy = obj.energy - obj.energy_consumption;
            obj.position_history = [obj.position_history; obj.position];
        end
        
        function [move_x, move_y] = check_borders(obj, move_x, move_y, world)
            %CHECK_BORDERS verifies that the next movement action does not
            %   lead the creature to go outside the world borders
            if obj.position(1) + move_x < 0
                move_x = obj.position(1);
            elseif obj.position(1) + move_x > world.map_dimensions(1,1)
                move_x = world.map_dimensions(1,1) - obj.position(1);
            end
            if obj.position(2) + move_y < 0
                move_y = obj.position(2);
            elseif obj.position(2) + move_y > world.map_dimensions(1,2)
                move_y = world.map_dimensions(1,2) - obj.position(2);
            end
        end
        
        function [move_x, move_y] = borders_vision(obj, move_x, move_y, world)
            %BORDER_VISION verifies that the next random movement does not
            %   lead the creature to go too close to the world borders
            if obj.position(1) - obj.coeff_vis_border * obj.sense_radius < 0
                move_x = obj.speed;
                move_y = 0;
            elseif obj.position(1) + obj.coeff_vis_border * obj.sense_radius > world.map_dimensions(1,1)
                move_x = -obj.speed;
                move_y = 0;
            end          
            if obj.position(2) - obj.coeff_vis_border * obj.sense_radius < 0
                move_y = obj.speed;
                move_x = 0;
            elseif obj.position(2) + obj.coeff_vis_border * obj.sense_radius > world.map_dimensions(1,2)
                move_y = -obj.speed;
                move_x = 0;
            end         
        end
        
        function obj = generate_child(obj)
            global cycle
            % standard parameters for
            energy_coeff = 0.5;                     % 80% of max energy
            obj.father_ID = obj.ID;
            obj.ID = obj.father_ID + 1;
            obj.generation = obj.generation + 1;
            obj.birth_cycle = cycle;		
            obj.age = 0;
            obj.food_eaten = 0;
            obj.memory_vec = [];
            obj.energy = energy_coeff*obj.max_energy;
            
            % mutation laws:
            obj.size = obj.size + obj.size * (rand - 0.5) * 0.5;
            obj.sense_radius = obj.sense_radius + obj.sense_radius * (rand - 0.5) * 0.5;
            obj.speed = obj.speed + obj.speed * (rand - 0.5) * 0.5;
            
            % minimum value for each characteristic
            if obj.size < 0.3
                obj.size = 0.3;
            end
            if obj.sense_radius < 5
                obj.sense_radius = 5;
            end
            if obj.speed < 0.2
                obj.speed = 0.2;
            end
            
            % characteristics derived from the other ones
            obj.energy_consumption = round(obj.size^3*obj.speed^2 + obj.sense_radius/20 ,2);
            obj.go_back_distance = round(abs(obj.sense_radius*2), 2);
        end
        
        function obj = update(obj)
            obj.age = obj.age+1;
            obj.position_history = [];
            obj.memory_vec = [];
            obj.energy_history = [];
            obj.angle_history = [];
        end
        
    end
end