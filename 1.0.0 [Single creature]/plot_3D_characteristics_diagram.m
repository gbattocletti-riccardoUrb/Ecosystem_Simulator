function plot_3D_characteristics_diagram(creature, N_figure)
    % creature = vector of creature objects   
    N = length(creature);
    
    size = zeros(N, 1);
    age = zeros(N, 1);
    sense_radius = zeros(N, 1);
    speed = zeros(N, 1);
    generation = zeros(N, 1);
    color_vector = winter(N);
    
    for ii = 1:N
        obj = creature(ii);
        size(ii) = obj.size;
        age(ii) = obj.age;
        speed(ii) = obj.speed;
        sense_radius(ii) = obj.sense_radius;
        generation(ii) = obj.generation;
    end

    x_min=min(speed)-(mean(speed)-min(speed));
    x_max=max(speed)+(mean(speed)-min(speed));
    y_min=min(size)-(mean(size)-min(size));
    y_max=max(size)+(mean(size)-min(size));
    z_min=min(sense_radius)-(mean(sense_radius)-min(sense_radius));
    z_max=max(sense_radius)+(mean(sense_radius)-min(sense_radius));
          
    [~,idx] = sort(generation);
    generation = generation(idx);
    speed = speed(idx);
    size = size(idx);
    sense_radius = sense_radius(idx);
    
    figure(N_figure)
        title('Creature characteristic')
        hold on
        for ii=1:N
            if creature(ii).dead == 1
                plot3(speed(ii),size(ii),sense_radius(ii),'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[color_vector(ii,1), color_vector(ii,2), color_vector(ii,3)],'MarkerSize',8);
            else
                plot3(speed(ii),size(ii),sense_radius(ii),'o','MarkerEdgeColor',[1 0 0],'LineWidth',1.2,'MarkerFaceColor',[color_vector(ii,1), color_vector(ii,2), color_vector(ii,3)],'MarkerSize',8);
            end
        end
        plot3(mean(speed), mean(size), (mean(sense_radius)), 'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1.00 0.27 0],'MarkerSize',10)
        axis([x_min x_max y_min y_max z_min z_max])
        xlabel('Speed')
        ylabel('Size')
        zlabel('Sense radius')
        c = colorbar();
        c.Label.String = 'Generation';
        c.TickLabels = round(linspace(generation(1),generation(end),10));

        colormap winter
        %campos([5, 5, 5])
        grid on
        box on
        
        axis vis3d
        view(60,40)
        
%         ax = gca;
%         ax.Clipping = 'off';    % turn clipping off
end