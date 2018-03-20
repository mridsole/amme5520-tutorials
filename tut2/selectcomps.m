function [prob, ns] = selectcomps(budget, costs, probs)
% budget: integer > 0, costs: integers > 0, 0. < probs (fail) < 1

    % TODO: Greatest common divisor on { budget } U costs to reduce
    % workload.

    assert(length(costs) == length(probs));
    N = length(costs);

    % The value function.
    V = zeros(length(costs), budget);
    
    % Quantity of each component type.
    ns = zeros(1,N);
    
    % compute cost to go for every possible state
    for i = 1:N
        for B = 1:budget
            
            % Possible choices are 0 to M, where
            M = floor(B / costs(i));
            % Find the n_i which minimise -log(1 - probs(i)^(n + 1)) + s V(i,B)
            V_possible = zeros(M + 1, 1);
            for n = 0:M
                V_possible(n + 1) = -log(1 - probs(i)^n) + getV(V, probs, i - 1, B - n * costs(i));
            end
            
            V(i,B) = min(V_possible);
        end
    end
    
    % Compute probability of success based on final cost to go
    value = V(N,B);
    prob = exp(-value);
    
    % Now backtrack to obtain the n_i's
    % Start at V(N, budget), use table to backtrack
    B = budget;
    for i = N:-1:1
        
        % What are the options to get to here?
        M = floor(B / costs(i));
        V_possible = zeros(M + 1, 1);
        for n = 0:M
            V_possible(n + 1) = -log(1 - probs(i)^n) + getV(V, probs, i - 1, B - n * costs(i));
        end
        [a, nmin] = min(V_possible);
        B = B - (nmin - 1) * costs(i);
        ns(i) = nmin - 1;
    end
end

function v = getV(V, probs, i, B)

    if i == 0
        % If a system has no component stages, it can't fail.
        % ((1 - p_fail) = 1 => -log(1 - p_fail) = 0)
        v = 0;
    elseif B == 0
        % If a system needs component stages but can't afford any,
        % it will fail ((1 - p_fail) = 0 => -log(1 - p_fail) = Inf)
        v = Inf;
    else
        % Otherwise, use the table.
        v = V(i,B);
    end
end

