classdef SelectorNode < CompositeNode
    % SelectorNode Summary of this class goes here
    % Detailed explanation goes here
    
    properties
        output = NaN
        bb_copy
    end
    
    methods
        function obj = SelectorNode(varargin)
            %SelectorNode Construct an instance of this class
            %   Detailed explanation goes here
            if nargin > 1
                obj.Children = varargin{1};
                obj.numChildren = numel(obj.Children);
                obj.bb_copy = varargin{2};
                obj.str = {' ? '};
                % then write a function in the RootNode (plot) to plot
                % everything based on the sucess or failure. Potentially
                % add output of [0 1 2] to choose between those states.
                % then colour each box around them.
            end

        end
        
        function outputArg = tick(obj)
            %tick Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = 0;
            for i = 1:obj.numChildren
                NodeState = obj.Children(i).tick;
                if NodeState
                    outputArg = 1;
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

