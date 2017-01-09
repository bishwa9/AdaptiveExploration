classdef (Abstract) sampling < handle
    %% SAMPLING This is an abstract class defining SAMPLING METHOD.
    %% Member variables of the class
    properties
    end
    %% Member functions of this class
    methods (Abstract)
        engage = sample(self, curModel, samplesTaken, budgetRemaining);
    end    
end

