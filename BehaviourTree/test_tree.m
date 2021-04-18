close all
clear
clc

%%
bb = BlackBoard;
% condition to go ahead
bb.add_item('canGoAhead',0);
bb.add_item('noCarsOpposite',1);
bb.add_item('Accel',0);
bb.add_item('canGoBehind',1);
bb.add_item('dist2Junc',9);
bb.add_item('Zero',0);
bb.add_item('maxAccel',0);
bb.add_item('maxDecel',0);

%%
% go ahead sequence
a_cond1 = ConditionNode(bb.noCarsOpposite>0,'noCarsOpposite>0');
a_cond2 = ConditionNode(bb.dist2Junc<10,'dist2Junc<10');
a_cond3 = ConditionNode(bb.canGoAhead==1,'canGoAhead==1');
a_act  = ActionNode('Accel','maxAccel',bb);
a_seq = SequenceNode([SequenceNode([a_cond1,a_cond2],bb),a_cond3,a_act],bb);

% go behind sequence
b_cond1 = ConditionNode(bb.dist2Junc>=10,'dist2Junc>=10');
b_cond2 = ConditionNode(bb.canGoBehind==1,'canGoBehind==1');
b_act  = ActionNode('Accel','maxDecel',bb);
% b_sel = SelectorNode([b_cond1,b_cond2],bb);
b_seq = SequenceNode([b_cond1,b_cond2,b_act],bb);

c_act = ActionNode('Accel','Zero',bb);

c_act1 = ActionNode('Accel','Zero',bb);

% full tree
full_select = SelectorNode([a_seq,b_seq,c_act1],bb);


%% change the bt and tick and plot
ha = axes;
while true
    output = tick(full_select,1);
    full_select.plot_tree(ha,0)
    full_select.plot_bt(ha);
    if bb.canGoAhead && bb.noCarsOpposite
        bb.noCarsOpposite = false;
        bb.canGoAhead = false;
    else
        bb.noCarsOpposite = true;
        bb.canGoAhead = true;
    end
    a_cond1.condArray = bb.noCarsOpposite;
    a_cond3.condArray = bb.canGoAhead;
    pause(1)
    cla(ha)
end



