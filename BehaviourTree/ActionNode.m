classdef ActionNode < LeafNode
    %ActionNode Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        output = -1
        name1
        name2
        bb_copy
        str
    end
    
    methods
        function obj = ActionNode(varargin)
            if nargin > 1
                obj.str = sprintf('Set %s to %s',varargin{1},varargin{2});
            end
            obj.name1 = varargin{1};
            obj.name2 = varargin{2};            
            obj.bb_copy = varargin{3};
        end
        function outputArg = tick(obj,parentOutput)
            if parentOutput == 1
                outputArg = 1;
                obj.set_value()
            else
                outputArg = -1;
            end
            obj.output = outputArg;
        end
        function set_value(obj)
%             nm1 = obj.name1;
            nm2 = obj.name2;
%             obj.bb_copy.(nm1) = obj.bb_copy.(nm2);
            tempBB = obj.bb_copy; 
%             tempBB = setfield(tempBB,nm1,tempBB.(nm2));
            tempBB.A = tempBB.(nm2);
%             obj.bb_copy = tempBB;
        end
        function plot_tree(obj,rank)
            obj.plotRankArray = rank;
            obj.outputArg = obj.output;
        end
    end
end

