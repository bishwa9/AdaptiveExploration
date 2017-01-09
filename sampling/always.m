classdef always<sampling
    %% RANDOM SAMPLING Alg. 2
    %% Member variables of the class
    properties
    end
    %% Member functions of this class
    methods
        function init(self)
        end
        
        function engage = sample(self, curModel, ...
                                    samplesTaken, budgetRemaining)
            if budgetRemaining > 0
                engage = 1;
            else
                engage = 0;
            end
        end
    end  
end