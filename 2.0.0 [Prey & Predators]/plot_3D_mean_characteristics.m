function plot_3D_mean_characteristics(creature, N_figure, selector)
    % creature = vector of creature objects   
    N = length(creature{selector});
    
    size = zeros(N, 1);
    age = zeros(N, 1);
    sense_radius = zeros(N, 1);
    speed = zeros(N, 1);
    generation = zeros(N, 1);
    birth_cycle = zeros(N, 1);
    %color_vector = winter(N);
    
    for ii = 1:N
        obj = creature{selector}(ii);
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
          
    sort_selector = generation;
    N_sort = length(unique(sort_selector));
    
    % initialize the vectors
    speed_mean = zeros(N_sort, 1);
    size_mean = zeros(N_sort, 1);
    sense_radius_mean = zeros(N_sort, 1);
    
    for jj = 1:N_sort      
            [~,idx]=ismember(jj,sort_selector);
            speed_mean(jj) = mean(speed(idx));
            size_mean(jj) = mean(size(idx));
            sense_radius_mean(jj) = mean(sense_radius(idx));
    end
    
        figure(N_figure);
        title('Creature characteristic evolution')
        hold on   
        plot3(speed_mean(end),size_mean(end),sense_radius_mean(end),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.6784 1 0.1843],'MarkerSize',8)
        plot3(speed_mean(1),size_mean(1),sense_radius_mean(1),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0.2 0.8],'MarkerSize',8)
        scatter3(speed_mean(2: end-1),size_mean(2: end-1),sense_radius_mean(2: end-1),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 0.27 0],'MarkerFaceAlpha',0.5)
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