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
        function plot_bt(obj,f1)
            %% put it in the method of the plotting of rootNode or something
            [x,y,h]=treelayout(obj.plotRankArray);
            ha = axes;
            unique_y = fliplr(unique(y));
            hierarchy(1) = obj.plotRankArray(1);
            for i = 2:numel(obj.plotRankArray)
%                 if obj.plotRankArray(i) >= h && obj.plotRankArray(i) > obj.plotRankArray(i-1)
                if obj.plotRankArray(i) > obj.plotRankArray(i-1)   
                    hierarchy(i) = hierarchy(i-1)+1;
%                 elseif obj.plotRankArray(i) >= h && obj.plotRankArray(i) == obj.plotRankArray(i-1)
                elseif obj.plotRankArray(i) == obj.plotRankArray(i-1)
                    hierarchy(i) = hierarchy(i-1);
                elseif obj.plotRankArray(i) >= h && obj.plotRankArray(i) < obj.plotRankArray(i-1)
                    hierarchy(i) = hierarchy(obj.plotRankArray(i))+1;
                else
                    hierarchy(i) = obj.plotRankArray(i);
                end
            end
            
            for i = 1:numel(y)
                if y(i) == unique_y(hierarchy(i)+1)
                    y_reorg(i) = y(i);
                else
                    y_reorg(i) = unique_y(hierarchy(i)+1);
                end
            end
            
            f = find(obj.plotRankArray~=0);
            pp = obj.plotRankArray(f);
            
            X = [x(f); x(pp); NaN(size(f))];
            Y = [y_reorg(f); y_reorg(pp); NaN(size(f))];
            
            X = X(:);
            Y = Y(:);
            % annotation(str1)
            % for i = 1:numel(X)
            plot(ha, X, Y, 'k-');
            hold on
            % [X(i), Y(i)]
            % end
            axis([0 1 0 1]);
            hold on
            col = {};
            for i = 1:numel(obj.outputArg)
                switch obj.outputArg(i)
                    case 0
                        col = [col {'r'}];
                    case 1
                        col = [col {'g'}];
                    otherwise
                        col = [col {'k'}];
                end
                text(x(i),y_reorg(i),obj.str(i),'EdgeColor',col{i},'LineStyle','-','BackgroundColor','w','HorizontalAlignment','center')
            end
            
            ha.Visible = 'off';
        end
    end
end

