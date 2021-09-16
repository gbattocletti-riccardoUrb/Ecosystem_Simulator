function [] = display_world(world, population, N_food, N_cycle, N_figure)
    % used for step-by-step plot of the simulation. To be used mainly for debugging
    
    food_color = [58, 213, 19]/255;
    % N_food = size(world.food_vector, 1) to pass one argument less
    
    figure(N_figure)
        clf;    % clear figure (to make eaten food disappear)
        hold on
        axis([0, world.map_dimensions(1), 0, world.map_dimensions(2)])
        axis equal
        plot([0,0], [0, world.map_dimensions(2)], '-k', 'linew', 1.3)
        plot([0, world.map_dimensions(1)], [world.map_dimensions(2), world.map_dimensions(2)], '-k', 'linew', 1.3)
        plot([world.map_dimensions(1), world.map_dimensions(1)], [world.map_dimensions(2), 0], '-k', 'linew', 1.3)
        plot([world.map_dimensions(1), 0], [0,0], '-k', 'linew', 1.3)
        plot(world.food_vector(:,1), world.food_vector(:,2), '.k', 'MarkerSize', 12, 'Color', food_color)
        title_string = sprintf('Food = %i // Cycle = %i // Alive creatures = %i', N_food, N_cycle, length(population.alive_preys)+length(population.alive_predators) );
        title(title_string);
        box on
        
end

