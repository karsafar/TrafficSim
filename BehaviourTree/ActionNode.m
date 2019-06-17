classdef ActionNode < LeafNode
    %ActionNode Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        output = NaN
        setValue
        bb_copy
        str
        name
    end
    
    methods
        function obj = ActionNode(varargin)
            if nargin > 1
                obj.str = sprintf('Set %s to %s',varargin{1},varargin{2});
            end
            obj.name = varargin{1};
            obj.setValue = str2double(varargin{2});            
            obj.bb_copy = varargin{3};
        end
        function outputArg = tick(obj)
            %tick Summary of this method goes here
            %   Detailed explanation goes here
            nm = obj.name;
            obj.bb_copy.(nm) = obj.setValue;
            outputArg = true;
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

