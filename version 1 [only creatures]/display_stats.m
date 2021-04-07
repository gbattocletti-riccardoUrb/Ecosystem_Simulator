function [] = display_stats(creature_vec)
    % generates and displays a table with the characteristics of all the creatures in creature vec
    
    N = length(creature_vec);
    Number = (1:N)';
    Speed = zeros(N, 1);
    Age = zeros(N, 1);
    Size = zeros(N, 1);
    Energy_Consumption = zeros(N, 1);
    Max_Energy = zeros(N, 1);
    Sense_Radius = zeros(N, 1);
    Birth_Cycle = zeros(N, 1);
    Death_Cycle = zeros(N, 1);
    Food_eaten = zeros(N, 1);
    Generation = zeros(N,1);
    Dead_or_alive = strings(N, 1);
    
    % table columns generation
    for ii = 1:N
        obj = creature_vec(ii);
        Speed(ii) = obj.speed;
        Age(ii) = obj.age;
        Size(ii) = obj.size;
        Energy_Consumption(ii) = obj.energy_consumption;
        Max_Energy(ii) = obj.max_energy;
        Sense_Radius(ii) = obj.sense_radius;
        Birth_Cycle(ii) = obj.birth_cycle;
        Death_Cycle(ii) = obj.death_cycle;
        Generation(ii) = obj.generation;
        Food_eaten(ii) = obj.food_eaten;
        if obj.dead == 0
            Dead_or_alive(ii) = "Alive";
        else
            Dead_or_alive(ii) = "Dead";
        end
    end

    characteristic_table = table(Number, Dead_or_alive ,Birth_Cycle, Generation, Death_Cycle, Age, Size, Speed, Sense_Radius, Max_Energy, Energy_Consumption, Food_eaten);
    characteristic_table = sortrows(characteristic_table, 'Dead_or_alive');
    display(characteristic_table);
end