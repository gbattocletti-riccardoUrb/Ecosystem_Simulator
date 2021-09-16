classdef population < handle 
   % stores info about creature population
   
    properties
        all;    % all creatures ever existed are stored in this vector
        alive;  % all alive creatures during one cycle are saved here
        dead;   % all creatures who are dead during this cycle are stored here
        dead_position;  % position of all the creatures dead during this cycle.
                        % this vector may become obsolete (cycles will not be always printed now)
        new_generation; % at the end of one cycle, this vector is used to store the newborn creatures
        alive_counter;  % column matrix - 2 columns. The first contains the number of alive creatuyres at the beginning of a cycle, the 2nd the alive creatures at the end of the cycle
    end
    
    methods
        function obj = population()
            obj.all =  [];
            obj.alive = [];
            obj.dead = [];
            obj.dead_position = [inf, inf];
            obj.new_generation = [];
            obj.alive_counter = [];
        end

        function obj = reproduce(obj, reproduction_probability)
            % NB: N_creatures_alive*reproduction_probability corresponds to the number of new creatures that will spawn!
            N = length(obj.alive);
            N_new_creatures = round(N*reproduction_probability);
            
            if N_new_creatures ~= 0             % if N=0 means no reproduction
                pd = makedist('HalfNormal', 'mu', 0, 'sigma', N/5); % probability distribution to select the creatures that will reproduce
                selected_idx = round(random(pd, N_new_creatures, 1));
                selected_idx(selected_idx > N) = N; % to ensure no index is out of range
                selected_idx(selected_idx == 0) = 1;

                % create vector with the final energy of each creature
                final_energy_vector = zeros(N, 1);
                for ii = 1:N
                    final_energy_vector(ii) = obj.alive(ii).energy_history(end);
                end
                % tric & trac with indexes
                [~, idx_vec] = sort(final_energy_vector,'descend');
                idx_vec = idx_vec(selected_idx);                    % vector with the indexes of the creatures that will reproduce!
                % here the new empty creatures are created. 
                creature_append = creature();
                creature_append = creature_append.creature_vec(N_new_creatures);

                % new created creatures are now modified to be exact copies of their parents + some mutations
                for ii = 1:N_new_creatures
                    creature_append(ii) = copy(obj.alive(idx_vec(ii)));
                    creature_append(ii).generate_child();
                end
                obj.alive = [obj.alive; creature_append];
                obj.all=[obj.all ; obj.alive(N+1:end)];
            end
            
        end
        
        function obj = remove_dead(obj, N_creatures)
            idx = zeros(N_creatures, 1);
            for ii = 1:N_creatures
                if obj.alive(ii).dead == 1
                    idx(ii) = 1;
                else
                    idx(ii) = 0;
                end
            end
            idx = logical(idx);
            obj.alive(idx) = [];
        end
        
        
    end
    
end