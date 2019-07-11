
figure(1)
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);

figure(2)
ax3 = subplot(2,1,1);

ax4 = subplot(2,1,2);

a_aggerg_e = 0;
a_aggerg_n = 0;
a_aggerg_norm_e = 0;
a_aggerg_norm_n = 0;
for i = 1:sim.horizArm.numCars
    
%{
    %% East Arm
    a_vec_e = sim.horizArm.allCars(i).bbStore;
    a_vec_e(a_vec_e == -1) = NaN;
    
    b_vec_e(:,1) = max(a_vec_e(:,1),a_vec_e(:,4));
    b_vec_e(:,2) = max(a_vec_e(:,2),a_vec_e(:,5));
    b_vec_e(:,3) = a_vec_e(:,3);
    b_vec_e(:,4) = a_vec_e(:,6);
    
    a_vec_val_e = [b_vec_e(:,1), b_vec_e(:,2)*2,b_vec_e(:,3)*3,b_vec_e(:,4)*4];
    
    c_vec_n = max(a_vec_val_e,[],2);
    plot(ax1,c_vec_n,'b-','LineWidth',2);
    %     plot(ax1,b_vec(:,1),'c.','LineWidth',20);
    %     hold(ax1,'on')
    %     plot(ax1,b_vec(:,2),'g.','LineWidth',20);
    %     plot(ax1,b_vec(:,3),'b.','LineWidth',20);
    %     plot(ax1,b_vec(:,4),'r.','LineWidth',20);
    yticks(ax1,[1 2 3 4])
    ylim(ax1,[1 4])
    yticklabels(ax1,{'Follow Car','Junc Stop','Go Ahead','Emerg Brake'})
    xlim(ax1,[0 nIterations])
    ylabel(ax1,'Acceleration States','FontSize',14)
    xlabel(ax1,'Iteration No','FontSize',14)
    
%     title(ax2,'East Arm Acceleration trajectory','FontSize',16)
    plot(ax2,sim.horizArm.allCars(i).History(3,:)+(i-1)*10,'b-','LineWidth',2);
    xlim(ax2,[0 nIterations])
    ylabel(ax2,'Acceleration, m/s^2','FontSize',14)
    xlabel(ax2,'Iteration No','FontSize',14)
    hold(ax2,'on')
%     xlim(ax2,[0 500])
    %     plot(b_vec(:,1),'r-s','LineWidth',10);
    %     hold on
    %     plot(b_vec(:,2),'g-.','LineWidth',10);
    %     plot(b_vec(:,3),'b-.','LineWidth',10);
    %     plot(b_vec(:,4),'y-.','LineWidth',10);
    %     pause(1)
    %     cla
    
    
    
    temp1 = sim.horizArm.allCars(i).History(2,:);
    temp2 = b_vec_e;
    b_vec_e_temp = temp2((temp1>-10 & temp1<=2.825),:);
    a_aggerg_e = a_aggerg_e + (nansum(b_vec_e_temp,1));
    a_aggerg_norm_e = a_aggerg_norm_e + (nansum(b_vec_e,1)/nIterations);
%}    
    %% North Arm
    a_vec_n = sim.vertArm.allCars(i).bbStore;
    a_vec_n(a_vec_n == -1) = NaN;
    
    b_vec_n(:,1) = max(a_vec_n(:,1),a_vec_n(:,4));
    b_vec_n(:,2) = max(a_vec_n(:,2),a_vec_n(:,5));
    b_vec_n(:,3) = a_vec_n(:,3);
    b_vec_n(:,4) = a_vec_n(:,6);
    
    a_vec_val_n = [b_vec_n(:,1), b_vec_n(:,2)*2,b_vec_n(:,3)*3,b_vec_n(:,4)*4];
    
    c_vec_n = max(a_vec_val_n,[],2);
    
    plot(ax3,c_vec_n,'b-','LineWidth',2);
    
    yticks(ax3,[1 2 3 4])
    ylim(ax3,[1 4])
    yticklabels(ax3,{'Follow Car','Junc Stop','Go Ahead','Emerg Brake'})
    xlim(ax3,[0 nIterations])
    ylabel(ax3,'Acceleration States','FontSize',14)
    xlabel(ax3,'Iteration No','FontSize',14)
    
%     title(ax4,'North Arm Acceleration trajectory','FontSize',16)
    plot(ax4,sim.vertArm.allCars(i).History(4,:),'b-','LineWidth',2);
    xlim(ax4,[0 nIterations])
    ylabel(ax4,'Acceleration, m/s^2','FontSize',14)
    xlabel(ax4,'Iteration No','FontSize',14)
%     hold(ax4,'on')
%     xlim(ax4,[0 500])

    temp1 = sim.vertArm.allCars(i).History(2,:);
    temp2 = b_vec_n;
    b_vec_n_temp = temp2((temp1>-10 & temp1<=2.825),:);
    a_aggerg_n = a_aggerg_n + (nansum(b_vec_n_temp,1));
    a_aggerg_norm_n = a_aggerg_norm_n + (nansum(b_vec_n_temp,1)/nIterations);
    title(ax1,' East Arm','FontSize',16)
    title(ax3,'North Arm','FontSize',16)
end
%{
%% East Arm
figure(3)
a_aggerg_e = a_aggerg_e/sim.horizArm.numCars;
c = categorical({'Follow Car','Junc Stop','Go Ahead','Emerg Brake'});
bar(c,a_aggerg_e,'stacked');
title(' East Arm aggregared decisions','FontSize',16)

figure(4)
a_aggerg_norm_e = a_aggerg_norm_e/sim.horizArm.numCars;
c = categorical({'Follow Car','Junc Stop','Go Ahead','Emerg Brake'});
bar(c,a_aggerg_norm_e,'stacked');
title('East Arm aggregared decisions normalised','FontSize',16)
%}
%% North Arm
figure(5)
a_aggerg_n = a_aggerg_n/sim.horizArm.numCars;
c = categorical({'Follow Car','Junc Stop','Go Ahead','Emerg Brake'});
bar(c,a_aggerg_n,'stacked');
title(' North Arm aggregared decisions','FontSize',16)

figure(6)
a_aggerg_norm_n = a_aggerg_norm_n/sim.horizArm.numCars;
c = categorical({'Follow Car','Junc Stop','Go Ahead','Emerg Brake'});
bar(c,a_aggerg_norm_n,'stacked');
title('North Arm aggregared decisions normalised','FontSize',16)
