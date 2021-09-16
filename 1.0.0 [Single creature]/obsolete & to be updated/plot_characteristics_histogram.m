function plot_characteristics_histogram(creature, N_figure)
    % creature = vector of creature objects
    
    N = length(creature);
    size = zeros(N, 1);
    age = zeros(N, 1);
    sense_radius = zeros(N, 1);
    max_energy = zeros(N, 1);
    energy_consumption = zeros(N, 1);
    speed = zeros(N, 1);
    nbins = 16;
    
    for ii = 1:N
        obj = creature(ii);
        size(ii) = obj.size;
        age(ii) = obj.age;
        speed(ii) = obj.speed;
        max_energy(ii) = obj.max_energy;
        energy_consumption(ii) = obj.energy_consumption;
        sense_radius(ii) = obj.sense_radius;
    end
    figure(N_figure)
        sgtitle('Characteristic Histograms')
        subplot(231)
            histogram(size, nbins)
            title('Size')
            xlabel('size')
            ylabel('frequency')
            grid on
            box on
        subplot(232)
            histogram(speed, nbins)
            title('Speed')
            xlabel('speed [distance/cycle]')
            ylabel('frequency')
            grid on
            box on
        subplot(233)
            histogram(sense_radius, nbins)
            title('Sense Radius')
            xlabel('sense radius')
            ylabel('frequency')
            grid on
            box on
        subplot(234)
            histogram(energy_consumption, nbins)
            title('Energy Consumption')
            xlabel('energy consumption [en/cycle]')
            ylabel('frequency')
            grid on
            box on
        subplot(235)
            histogram(max_energy, nbins)
            title('Max Energy')
            xlabel('max energy')
            ylabel('frequency')
            grid on
            box on
        subplot(236)
            histogram(age, nbins)
            title('Age')
            xlabel('age [cycles]')
            ylabel('frequency')
            grid on
            box on
end