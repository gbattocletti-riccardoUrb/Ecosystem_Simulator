function plot_3D_mean_characteristics(creature, N_figure)
    % creature = vector of creature objects   
    N = length(creature);
    
    size = zeros(N, 1);
    age = zeros(N, 1);
    sense_radius = zeros(N, 1);
    speed = zeros(N, 1);
    generation = zeros(N, 1);
    birth_cycle = zeros(N, 1);
    %color_vector = winter(N);
    
    for ii = 1:N
        obj = creature(ii);
        generation(ii) = obj.generation;
        size(ii) = obj.size;
        age(ii) = obj.age;
        speed(ii) = obj.speed;
        sense_radius(ii) = obj.sense_radius;
        birth_cycle(ii) = obj.birth_cycle;
    end

    x_min=min(speed)-(mean(speed)-min(speed));
    x_max=max(speed)+(mean(speed)-min(speed));
    y_min=min(size)-(mean(size)-min(size));
    y_max=max(size)+(mean(size)-min(size));
    z_min=min(sense_radius)-(mean(sense_radius)-min(sense_radius));
    z_max=max(sense_radius)+(mean(sense_radius)-min(sense_radius));
          
    
    N_birth_cycle = length(unique(birth_cycle));
    
    % initialize the vectors
    speed_mean = zeros(N_birth_cycle, 1);
    size_mean = zeros(N_birth_cycle, 1);
    sense_radius_mean = zeros(N_birth_cycle, 1);
    
    for jj = 1:N_birth_cycle       
            [~,idx]=ismember(jj,birth_cycle);
            speed_mean(jj) = mean(speed(idx));
            size_mean(jj) = mean(size(idx));
            sense_radius_mean(jj) = mean(sense_radius(idx));
    end
    
    figure(N_figure)
        title('Creature characteristic evolution')
        hold on   
        plot3(speed_mean,size_mean,sense_radius_mean,'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 0.27 0],'MarkerSize',8)
        plot3(speed_mean(end),size_mean(end),sense_radius_mean(end),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.6784 1 0.1843],'MarkerSize',8)
        plot3(speed_mean(1),size_mean(1),sense_radius_mean(1),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0.2 0.8],'MarkerSize',8)
        plot3(speed_mean,size_mean,sense_radius_mean,'LineWidth',1.2,'color',[0.055 0.34 0.49 0.5])
        
        axis([x_min x_max y_min y_max z_min z_max])
        xlabel('Speed')
        ylabel('Size')
        zlabel('Sense radius')
        
        %campos([5, 5, 5])
        grid on
        box on
        
        axis vis3d
        view(60,40)
        
%         ax = gca;
%         ax.Clipping = 'off';    % turn clipping off

end