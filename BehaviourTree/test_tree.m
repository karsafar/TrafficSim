close all
clear
clc

%%
bb = BlackBoard;
% condition to go ahead
bb.add_item('canGoAhead',0); 
bb.add_item('noCarsOpposite',0);
bb.add_item('Accel',0);
bb.add_item('canGoBehind',1); 
bb.add_item('dist2Junc',10);

%% 
% go ahead sequence
a_cond1 = ConditionNode(bb.noCarsOpposite>0,'noCarsOpposite>0');
a_cond2 = ConditionNode(bb.dist2Junc<10,'dist2Junc<10');
a_cond3 = ConditionNode(bb.canGoAhead==1,'canGoAhead==1');
a_act  = ActionNode('Accel','3.5',bb);
a_seq = SequenceNode([SequenceNode([a_cond1,a_cond2],bb),a_cond3,a_act],bb);

% go behind sequence
b_cond1 = ConditionNode(bb.dist2Junc>=10,'dist2Junc>=10');
b_cond2 = ConditionNode(bb.canGoBehind==1,'canGoBehind==1');
b_act  = ActionNode('Accel','-3.5',bb);
b_sel = SelectorNode([b_cond1,b_cond2],bb);
b_seq = SequenceNode([b_sel,b_act],bb);

c_act = ActionNode('Accel','0',bb);
% full tree
full_select = SelectorNode([a_seq,b_seq],bb);

% full_select = SelectorNode([sel1,c_act],bb);
output = tick(full_select);


ha = axes;
full_select.plot_tree(ha,0)

%% put it in the method of the plotting of rootNode or something
[x,y,h]=treelayout(full_select.plotRankArray);

unique_y = fliplr(unique(y));
hierarchy(1) = full_select.plotRankArray(1);
for i = 2:numel(full_select.plotRankArray)
    if full_select.plotRankArray(i) > h && full_select.plotRankArray(i) > full_select.plotRankArray(i-1) 
        hierarchy(i) = hierarchy(i-1)+1;
    elseif full_select.plotRankArray(i) > h && full_select.plotRankArray(i) == full_select.plotRankArray(i-1) 
        hierarchy(i) = hierarchy(i-1);
    elseif full_select.plotRankArray(i) > h && full_select.plotRankArray(i) < full_select.plotRankArray(i-1)
        hierarchy(i) = full_select.plotRankArray(full_select.plotRankArray(i))+1;
    else
        hierarchy(i) = full_select.plotRankArray(i);
    end
end

for i = 1:numel(y)
    if y(i) == unique_y(hierarchy(i)+1)
        y_reorg(i) = y(i);
    else
        y_reorg(i) = unique_y(hierarchy(i)+1);
    end
end

f = find(full_select.plotRankArray~=0);
pp = full_select.plotRankArray(f);

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
for i = 1:numel(full_select.output)
    switch full_select.output(i)
        case 0
            col = [col {'r'}];
        case 1
            col = [col {'g'}];
        otherwise
            col = [col {'k'}];
    end
    text(ha,x(i),y_reorg(i),full_select.str(i),'EdgeColor',col{i},'LineStyle','-','BackgroundColor','w','HorizontalAlignment','center')
end   

ha.Visible = 'off';

%% change the bt and tick and plot
%
%
%
%











