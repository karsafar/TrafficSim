classdef LeafNode < RootNode
    % LeafNode Summary of this class goes here
    % Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = LeafNode(varargin)
            %LeafNode Construct an instance of this class
            %   Detailed explanation goes here

        end
%         function plot_tree(obj,ha)
%             obj.axesHandle = ha;
%             for i = 1:obj.numChildren
%                 obj.plotRankArray = [obj.plotRankArray, numel(obj.plotRankArray)];
%                 obj.str = {obj.str, obj.Children(i).str};
%                 obj.Children(i).plot_tree(obj.axesHandle)
%             end
%         end
    end
end

