function p = prob(probs, ns)
% Probability of success

    p = 1 - prod(1 - probs.^ns);
end

