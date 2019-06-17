classdef RootNode < handle & dynamicprops  & matlab.mixin.Heterogeneous
    % RootNode Summary of this class goes here
    % Detailed explanation goes here
    
    properties
        axesHandle
        numChildren = 0
        plotRankArray = []
        plotColor = 1
    end
    
    methods
        function obj = RootNode()
            % RootNode Construct an instance of this class
            %   Detailed explanation goes here
        end
        
    end
end

