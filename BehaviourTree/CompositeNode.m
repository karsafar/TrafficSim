classdef CompositeNode < RootNode
    % CompositeNode Summary of this class goes here
    % Detailed explanation goes here
    
    properties
        Children
        str
    end
    
    methods
        function obj = CompositeNode(varargin)
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

