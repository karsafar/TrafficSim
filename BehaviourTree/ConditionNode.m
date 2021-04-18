classdef ConditionNode < LeafNode
    %ConditionNode Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        output = -1
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
        function outputArg = tick(obj,parentOutput)
            %tick Summary of this method goes here
            %   Detailed explanation goes here
            if parentOutput == 1
                outputArg = all(obj.condArray);
            else
                outputArg = -1;
            end
            obj.output = outputArg;
%             obj.output = outputArg;
%             obj.treeOut = outputArg;
        end
        function plot_tree(obj,rank)
            obj.plotRankArray = rank;
            obj.outputArg = obj.output;
        end
    end
end

