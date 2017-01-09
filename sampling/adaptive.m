classdef adaptive<sampling
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
            %% unpackage curModel into feature vectors
            x_ = curModel(:,:,1);
            x_ = x_(:);
            y_ = curModel(:,:,2);
            y_ = y_(:);
            z_ = curModel(:,:,3);
            z_ = z_(:);
            feature_vector = [x_.';y_.';z_.'].';
            %% calculate clusters
        end
    end  
end