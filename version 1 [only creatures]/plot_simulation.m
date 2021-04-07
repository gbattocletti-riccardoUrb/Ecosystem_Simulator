function plot_simulation(world, creature_vec, population, N_cycle, N_figure, position_history_flag)

    N = length(creature_vec);
    p = zeros(1, N);

    % plot - starts by using display_world and then adds the creatures
    display_world(world, population, size(world.food_vector, 1), N_cycle, N_figure);
    hold on
    for ii = 1:N
        obj = creature_vec(ii);
        txt = ['creature n° ',num2str(ii)];
        if position_history_flag
            p(ii) = plot(obj.position_history(:,1), obj.position_history(:,2), 'linew', 1.1, 'DisplayName', txt);
        end
    end
    for jj = 1:length(population.alive)  
        creature = population.alive(jj);
        plot(creature.position(1), creature.position(2), '.k', 'MarkerSize', 12)
    end
    plot(population.dead_position(:,1), population.dead_position(:,2),  'xr', 'MarkerSize', 8, 'linew', 1.5);
    hold off
    if position_history_flag
        legend(p)
        legend show
        legend('Location', 'eastoutside')
        grid on
    end
    box on
    title_string = sprintf('Simulation Final View \n Alive creatures = %i', length(population.alive));
    title(title_string)  % da cambiare ma che cazzo di titolo è
end