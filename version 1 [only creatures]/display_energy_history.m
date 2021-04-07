function display_energy_history(creature, N_figure)

    N = length(creature);

    figure(N_figure)
        hold on
        for ii = 1:N
            txt = ['creature n° ',num2str(ii)];
            obj = creature(ii);
            plot(obj.energy_history, 'linew', 1.2, 'DisplayName',txt);
        end
        axis([0 inf 0 inf])
        hold off
        legend show
        legend('Location', 'eastoutside')
        grid on
        box on
        title('Energy History')
        xlabel('# (cycle number)')
        ylabel('energy')
        
end