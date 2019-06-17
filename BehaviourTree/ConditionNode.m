classdef ConditionNode < LeafNode
    %ConditionNode Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        output = NaN
        condArray = []
        str
    end
    
    methods
        function obj = ConditionNode(varargin)
            if nargin > 1
                obj.condArray = varargin{1};                
                obj.str = varargin{2};
            end
        end
        function outputArg = tick(obj)
            %tick Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = sum(obj.condArray) == numel(obj.condArray);
            obj.output = outputArg;
        end
        function output = plot_tree(obj,ha,rank)
            obj.axesHandle = ha;
            obj.plotRankArray = [obj.plotRankArray rank];
            for i = 1:obj.numChildren
                obj.Children(i).plot_tree(obj.axesHandle)
            end
        end
    end
end

