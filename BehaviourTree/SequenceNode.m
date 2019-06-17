classdef SequenceNode < CompositeNode
    % SequenceNode Summary of this class goes here
    % Detailed explanation goes here
    
    properties
        output = NaN
        bb_copy
        
    end
    
    methods
        function obj = SequenceNode(varargin)
            if nargin > 1
                obj.Children = varargin{1};
                obj.numChildren = numel(obj.Children);
                obj.bb_copy = varargin{2};
                obj.str = {'-->'};
            end
        end
        
        function outputArg = tick(obj)
            %tick Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = 1;
            for i = 1:obj.numChildren
                NodeState = obj.Children(i).tick;
                if NodeState == 0
                    outputArg = 0;
                    obj.output = outputArg;
                    return
                end
                obj.output = outputArg;
            end
        end
        function plot_tree(obj,ha,rank)
            obj.axesHandle = ha;
            obj.plotRankArray = [obj.plotRankArray, rank];
            for i = 1:obj.numChildren
                obj.Children(i).plot_tree(obj.axesHandle,rank+1)
                if obj.plotRankArray(end)>=obj.Children(i).plotRankArray(1)
                    obj.Children(i).plotRankArray(2:end) = (numel(obj.plotRankArray)+1)+obj.plotRankArray(1)+(obj.Children(i).plotRankArray(2:end)-min(obj.Children(i).plotRankArray(2:end)));
                end
                obj.plotRankArray = [obj.plotRankArray, obj.Children(i).plotRankArray];
                obj.str =  cat(2,obj.str,obj.Children(i).str);
                obj.output = cat(2,obj.output,obj.Children(i).output);
            end
        end
    end
end

