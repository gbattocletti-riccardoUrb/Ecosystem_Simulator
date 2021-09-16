function plot_population_vs_food_evolution(N_figure, creature_counter, food_counter) 

    figure(N_figure)
        sgtitle('Population evolution')
        subplot(211)
            hold on
            title('Creatures number')
            plot(creature_counter(2:end),'linew',1.2)
            axis([-inf inf 0 inf]);
            xlabel('N° of cycle')
            ylabel('Alive creatures')
            grid on
            grid minor
            box on
            
        subplot(212)
            hold on
            title('Food number')
            plot(food_counter(2:end),'linew',1.2)
            axis([-inf inf 0 inf]);
            xlabel('N° of cycle')
            ylabel('Food present')
            grid on
            grid minor
            box on 
end