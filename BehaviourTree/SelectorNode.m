classdef SelectorNode < CompositeNode
    % SelectorNode Summary of this class goes here
    % Detailed explanation goes here
    
    properties
        output = -1
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
            end
            
        end
        function outputArg = tick(obj,varargin)
            %tick Summary of this method goes here
            %   Detailed explanation goes here
            %             returnFlag = 1;
            outputArg = varargin{1};
            %             NodeState = [];
            if outputArg == 1
                Children = obj.Children;
                for i = 1:obj.numChildren
                    %                 NodeState = [NodeState,Children(i).tick(outputArg)];
                    iChild = Children(i);
                    NodeState = iChild.tick(outputArg);
                    if NodeState(end) == 1
                        %                     obj.output = NodeState(i);
                        %                     outputArg = NodeState;
                        outputArg = 1;
                        obj.output = outputArg;
                        %                     outputArg = [outputArg,NodeState];
                        return
                    end
                end
                outputArg = 0;
            else
                outputArg = -1;
            end
            %             if any(NodeState) == 0
            %                 outputArg = 0;
            %             else
            %                outputArg = -1;
            %             end
            obj.output = outputArg;
            %               outputArg = [outputArg,NodeState];
        end
        function plot_tree(obj,rank)
            obj.str = {' ? '};
            obj.plotRankArray = rank;
            obj.outputArg = obj.output;
            for i = 1:obj.numChildren
                obj.Children(i).plot_tree(rank+1)
                if obj.plotRankArray(end)>=obj.Children(i).plotRankArray(1)
                    obj.Children(i).plotRankArray(2:end) = (numel(obj.plotRankArray)+1)+obj.plotRankArray(1)+(obj.Children(i).plotRankArray(2:end)-min(obj.Children(i).plotRankArray(2:end)));
                end
                obj.plotRankArray = [obj.plotRankArray, obj.Children(i).plotRankArray];
                obj.str =  cat(2,obj.str,obj.Children(i).str);
                obj.outputArg = cat(2,obj.outputArg,obj.Children(i).outputArg);
            end
        end
        
    end
end

