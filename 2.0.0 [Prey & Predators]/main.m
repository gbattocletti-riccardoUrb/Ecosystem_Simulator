%% Evolution Simulator 0.2.1
% 29/7/2020

clc;
close all;
clear variables;
format bank;		% 2 digit decimal precision
% format short;

% start clock
tic;
begin_time = toc;

% set up image numbering
image_counter = 0;

%% simulation parameters
global ID cycle Step;

% cycle and step numbers
N_cycles = 100;
N_steps = 170;
cycle_time = zeros(N_cycles, 2);					% column vector to save elapsed time for every cycle - column 1 for minutes, column 2 for seconds

% world generation
world_width = 200;
world_height = 200;
world = map(world_width, world_height);
% optional: modification of the food probability matrix --> switch the 
custom_food_probability_matrix = 1;
if custom_food_probability_matrix
	world.food_probability_matrix_generation(10, 10, 4, 0.7);	% --> arguments are m, n, steepness, amplification
	%image_counter = image_counter + 1;
	%world.food_probability_matrix_plot(image_counter);
else
	% default food prob. matrix is used
end

% food spawn parameters
daily_food = 70;

% creature generation + properties
N0_prey = 50;									% preys initial number
N0_predators = 5;								% predators initial number
creature_counter = zeros(N_cycles, 1);
prey_vector = creature();
prey_vector = prey_vector.creature_vec(N0_prey);

predator_vector = predator();
predator_vector = predator_vector.predator_vec(N0_predators);

for ii = 1:length(prey_vector)   
	prey_vector(ii).random_characteristic_generator(world, 1);
end

for ii = 1:length(predator_vector)   
	predator_vector(ii).random_characteristic_generator(world, 1);
end

% population
pop = population();
pop.alive_all = {prey_vector ; predator_vector};
pop.all = {prey_vector ; predator_vector};
pop.alive_preys = prey_vector;
pop.alive_predators = predator_vector;
reproduction_probability_prey = 0.6;  
reproduction_probability_predator = 0.17;

% global variable representing unique ID for each creature - it's basically a counter
ID = 1;
% population counter
pop.alive_counter = zeros(N_cycles, 1);
pop.alive_preys_counter = zeros(N_cycles, 1);
pop.alive_predators_counter = zeros(N_cycles, 1);

%% simulation
image_counter = image_counter + 1;
for cycle = 1:N_cycles
	cycle_begin_time = toc;
	world.clear_food();							% clear food vector
	world.sector_food_placement(daily_food);	% new food vector
    
    pop.alive_counter(cycle) = length(pop.alive_all{1}) + length(pop.alive_all{2});
    pop.alive_preys_counter(cycle) = length(pop.alive_all{1});
    pop.alive_predators_counter(cycle) = length(pop.alive_all{2});
    
    if ~isempty(pop.alive_all{1}) || ~isempty(pop.alive_all{2})     
        % ///// cycle simulation begins /////
        for Step = 1:N_steps
            %display_world(world, pop, size(world.food_vector, 1), cycle, image_counter);
            %N_creatures = length(pop.alive_all);
            N_preys = length(pop.alive_preys);
            for ii = 1:N_preys
                pop.alive_preys(ii).action(world, pop);
                %plot(pop.alive_preys(ii).position_history(end,1), pop.alive_preys(ii).position_history(end,2),  '.k', 'MarkerSize', 12);      
            end           
            pop.remove_dead_preys(N_preys);
            N_preys = length(pop.alive_preys);
            N_predators = length(pop.alive_predators);
            for ii = 1:N_predators
                pop.alive_predators(ii).action(world, pop);
                %plot(pop.alive_predators(ii).position_history(end,1), pop.alive_predators(ii).position_history(end,2),  '.r', 'MarkerSize', 12);      
            end 
            pop.remove_dead_predators(N_predators);
            pop.remove_dead_preys(N_preys);  
        end
        % ////// cycle simulation ends /////

        % update population --> new generation of creatures + mutations
        if ~isempty(pop.alive_preys) 
            pop.reproduce_prey(reproduction_probability_prey);
            % update characteristics of the alive creatures 
            for ii = 1:length(pop.alive_preys)
                pop.alive_preys(ii).update();             
            end 
        end
        
        if ~isempty(pop.alive_predators) 
            pop.reproduce_predator(reproduction_probability_predator);         
            for ii = 1:length(pop.alive_predators)	
                pop.alive_predators(ii).update();             
            end
        end
        
    end
	pop.alive_counter(cycle) = length(pop.alive_all{1}) + length(pop.alive_all{2});
    pop.alive_preys_counter(cycle) = length(pop.alive_all{1});
    pop.alive_predators_counter(cycle) = length(pop.alive_all{2});
    
	% end of cycle - computation of elapsed time
	cycle_end_time = toc;
	cycle_time(cycle, :) = print_elapsed_time(cycle_begin_time, cycle_end_time, 0);
    fprintf('\n Cycle n°: %i \n', cycle);    
    if isempty(pop.alive_predators) 
        disp('Predators are all dead')
    else
        fprintf('Alive predators: %i \n', length(pop.alive_predators));
    end
    if isempty(pop.alive_preys) 
        disp('Preys are all dead')
    else
        fprintf('Alive preys: %i \n', length(pop.alive_preys));
    end
    print_elapsed_time(begin_time, cycle_end_time, 1);
end

%% elapsed time
final_time = toc;
final_time = print_elapsed_time(begin_time, final_time, 1);

%% stats display
disp('Preys')
characteristic_table_prey = display_stats(pop.all, 1);          % 1 for preys // 2 for predators 
disp('Predators')
characteristic_table_predator = display_stats(pop.all, 2);      % 1 for preys // 2 for predators 

image_counter = image_counter + 1;
plot_3D_characteristics_diagram(pop.all, image_counter, 1)      % 1 for preys // 2 for predators 

image_counter = image_counter + 1;
plot_3D_mean_characteristics(pop.all, image_counter, 1)         % 1 for preys // 2 for predators

%% population number plot
image_counter = image_counter + 1;
figure(image_counter) 
    hold on
    plot(pop.alive_counter, 'linew', 1.2)
    plot(pop.alive_predators_counter, 'linew', 1.2)
    plot(pop.alive_preys_counter, 'linew', 1.2)
    grid on
    grid minor
    xlabel('cycle')
    ylabel('population')
    title('population over time')
    legend('All creatures','Predators','Preys')
