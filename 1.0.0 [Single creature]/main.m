%% Evolution Simulator 0.2.0
% 20/7/2020

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
N_cycles = 50;
N_steps = 150;
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
daily_food = 30;

% creature generation + properties
N0_creatures = 15;									% creatures initial number
creature_counter = zeros(N_cycles, 1);
creature_vector = creature();
creature_vector = creature_vector.creature_vec(N0_creatures);

for ii = 1:length(creature_vector)   
	creature_vector(ii).random_characteristic_generator(world, 1);
end

% population
pop = population();
pop.alive = creature_vector;
pop.all = creature_vector;
reproduction_probability = 0.1;         % 20% of reproduction probability

% global variable representing unique ID for each creature - it's basically a counter
ID = 1;
% population counter
pop.alive_counter = zeros(N_cycles, 1);
%% simulation
image_counter = image_counter + 1;
for cycle = 1:N_cycles
	cycle_begin_time = toc;
	world.clear_food();							% clear food vector
	world.sector_food_placement(daily_food);	% new food vector
    
    pop.alive_counter(cycle) = length(pop.alive);
    
    if ~isempty(pop.alive)
        
        % ///// cycle simulation begins /////
        for Step = 1:N_steps
            %display_world(world, pop, size(world.food_vector, 1), cycle, image_counter);
            if ~isempty(pop.alive)
                N_creatures = length(pop.alive);
                for ii = 1:N_creatures
                    pop.alive(ii).action(world, pop);
                    %plot(pop.alive(ii).position_history(end,1), pop.alive(ii).position_history(end,2),  '.k', 'MarkerSize', 12);      
                end           
                pop.remove_dead(N_creatures);
            end
        end
        % ////// cycle simulation ends /////

        % update population --> new generation of creatures + mutations
        if ~isempty(pop.alive)
            pop.reproduce(reproduction_probability);
        
            % update characteristics of the alive creatures (included the new created - this, however, is not a problem)
            for ii = 1:length(pop.alive)	% note: n° of alive creatures could be different from above
                pop.alive(ii).update();
            end 
        end
    end
	pop.alive_counter(cycle) = length(pop.alive);
	% end of cycle - computation of elapsed time
	cycle_end_time = toc;
	cycle_time(cycle, :) = print_elapsed_time(cycle_begin_time, cycle_end_time, 0);
    fprintf('Cycle n°: %i \n', cycle);
end

%% elapsed time
final_time = toc;
final_time = print_elapsed_time(begin_time, final_time, 1);

%% stats display
characteristic_table = display_stats(pop.all);

image_counter = image_counter + 1;
plot_3D_characteristics_diagram(pop.all, image_counter)

image_counter = image_counter + 1;
plot_3D_mean_characteristics(pop.all, image_counter)

%% population number plot
image_counter = image_counter + 1;
figure(image_counter) 
    plot(pop.alive_counter, 'linew', 1.2)
    grid on
    grid minor
    xlabel('cycle')
    ylabel('population')
    title('population over time')
    legend('begin of cycle', 'end of cycle')
