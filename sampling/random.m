classdef random<sampling
    %% RANDOM SAMPLING Alg. 2
    %% Member variables of the class
    properties
        samplingFrequency
    end
    %% Member functions of this class
    methods
        function init(self, samplingF)
            self.samplingFrequency = samplingF;
        end
        
        function engage = sample(self, curModel, ...
                                    samplesTaken, budgetRemaining)
            rand_ = rand(1);
            if rand_ < self.samplingFrequency
                engage = 1;
            else
                engage = 0;
            end
        end
    end  
end