classdef population < handle 
   % stores info about creature population
   
    properties
        all;    % all creatures ever existed are stored in this vector
        alive_all; % all alive creatures during one cycle are saved here
        alive_preys;  % all alive prey during one cycle are saved here
        alive_predators;  % all alive predators during one cycle are saved here
        dead_predators;   % all creatures who are dead during this cycle are stored here
        dead_preys;   % all creatures who are dead during this cycle are stored here
        dead_position;  % position of all the creatures dead during this cycle.
                        % this vector may become obsolete (cycles will not be always printed now)
        new_generation; % at the end of one cycle, this vector is used to store the newborn creatures
        alive_counter;  % column matrix - 2 columns. The first contains the number of alive creatuyres at the beginning of a cycle, the 2nd the alive creatures at the end of the cycle
        alive_predators_counter;
        alive_preys_counter;
    end
    
    methods
        function obj = population()
            obj.all =  [];
            obj.alive_preys = [];
            obj.alive_predators = [];
            obj.dead_predators = [];
            obj.dead_preys = [];
            obj.dead_position = [inf, inf];
            obj.new_generation = [];
            obj.alive_counter = [];
            obj.alive_predators_counter = [];
            obj.alive_preys_counter = [];
        end

        function obj = reproduce_prey(obj, reproduction_probability)
            % NB: N_creatures_alive*reproduction_probability corresponds to the number of new creatures that will spawn!
            N = length(obj.alive_preys);   
            min_energy_reproduction = 70;  %minimum energy in order to reproduct a creature
            % create vector with the final energy of each creature
            final_energy_vector = zeros(N, 1);
            for ii = 1:N
                final_energy_vector(ii) = obj.alive_preys(ii).energy_history(end);
            end
            N_energy = length(final_energy_vector(final_energy_vector > min_energy_reproduction));    %number of preys with energy > min energy to reproduction
            N_new_creatures = round(N_energy*reproduction_probability);
                    
            if N_energy ~= 0 && reproduction_probability ~= 0
                if N_new_creatures == 0 && N_energy ~= 0        % in case of one alive prey with a low reproduction probability
                    N_new_creatures = 1;
                end
                pd = makedist('HalfNormal', 'mu', 0, 'sigma', N/5); % probability distribution to select the creatures that will reproduce
                selected_idx = round(random(pd, N_new_creatures, 1));
                selected_idx(selected_idx > N) = N; % to ensure no index is out of range
                selected_idx(selected_idx == 0) = 1;

                % tric & trac with indexes
                [~, idx_vec] = sort(final_energy_vector,'descend');
                idx_vec = idx_vec(selected_idx);                    % vector with the indexes of the creatures that will reproduce!
                % here the new empty creatures are created. 
                creature_append = creature();
                creature_append = creature_append.creature_vec(N_new_creatures);

                % new created creatures are now modified to be exact copies of their parents + some mutations
                for ii = 1:N_new_creatures
                    creature_append(ii) = copy(obj.alive_preys(idx_vec(ii)));
                    creature_append(ii).generate_child();
                end
                obj.alive_preys = [obj.alive_preys; creature_append];
                obj.all{1} = [obj.all{1} ; obj.alive_preys(N+1:end)];
                obj.alive_all{1} = [obj.alive_all{1} ; obj.alive_preys(N+1:end)];
            end
                    
        end
        
        function obj = reproduce_predator(obj, reproduction_probability)
            % NB: N_creatures_alive*reproduction_probability corresponds to the number of new creatures that will spawn!
            N = length(obj.alive_predators);   
            min_energy_reproduction = 150;  %minimum energy in order to reproduct a creature
            % create vector with the final energy of each creature
            final_energy_vector = zeros(N, 1);
            for ii = 1:N
                final_energy_vector(ii) = obj.alive_predators(ii).energy_history(end);
            end
            N_energy = length(final_energy_vector(final_energy_vector > min_energy_reproduction));    %number of predators with energy > min energy to reproduction
            N_new_creatures = round(N_energy*reproduction_probability);
                  
            if N_energy ~= 0 && reproduction_probability ~= 0
                if N_new_creatures == 0 && N_energy ~= 0      % in case of one alive predator with a low reproduction probability
                    N_new_creatures = 1;
                end
                pd = makedist('HalfNormal', 'mu', 0, 'sigma', N/5); % probability distribution to select the creatures that will reproduce
                selected_idx = round(random(pd, N_new_creatures, 1));
                selected_idx(selected_idx > N) = N; % to ensure no index is out of range
                selected_idx(selected_idx == 0) = 1;
                % tric & trac with indexes
                [~, idx_vec] = sort(final_energy_vector,'descend');
                idx_vec = idx_vec(selected_idx);                    % vector with the indexes of the creatures that will reproduce!
                % here the new empty creatures are created. 
                predator_append = predator();
                predator_append = predator_append.predator_vec(N_new_creatures);

                % new created creatures are now modified to be exact copies of their parents + some mutations
                for ii = 1:N_new_creatures
                    predator_append(ii) = copy(obj.alive_predators(idx_vec(ii)));
                    predator_append(ii).generate_child();
                end
                obj.alive_predators = [obj.alive_predators; predator_append];
                obj.all{2} = [obj.all{2} ; obj.alive_predators(N+1:end)];
                obj.alive_all{2} = [obj.alive_all{2} ; obj.alive_predators(N+1:end)];
            end
            
        end
        
        function obj = remove_dead_preys(obj, N_creatures)
            idx = zeros(N_creatures, 1);
            for ii = 1:N_creatures
                if obj.alive_preys(ii).dead == 1
                    idx(ii) = 1;
                else
                    idx(ii) = 0;
                end
            end
            idx = logical(idx);
            obj.alive_preys(idx) = [];
            obj.alive_all{1}(idx) = [];
        end
        
        function obj = remove_dead_predators(obj, N_creatures)
            idx = zeros(N_creatures, 1);
            for ii = 1:N_creatures
                if obj.alive_predators(ii).dead == 1
                    idx(ii) = 1;
                else
                    idx(ii) = 0;
                end
            end
            idx = logical(idx);
            obj.alive_predators(idx) = [];
            obj.alive_all{2}(idx)=[];
        end
        
        
    end
    
end