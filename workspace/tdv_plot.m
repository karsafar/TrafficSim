selfCar = sim.horizArm.allCars(1);
s_in = selfCar.s_in;
s_out = selfCar.s_out;

% simplify access to competing cars
oppCars = sim.vertArm.allCars;


%number of competing cars
N = sim.vertArm.numCars;
t_in = [];
t_out = [];
oppDistToJunc = [];
% calc distance to junction every time step
for i = 1:N
    oppDistToJunc(i,:) = s_in - oppCars(i).History(2,:) + (oppCars(i).History(2,:)>s_in).*sim.vertArm.Length;
    t_in(i,:) = oppDistToJunc(i,:)./oppCars(i).History(3,:)+t_rng(:)';
    t_out(i,:) = (oppDistToJunc(i,:)+s_out)./oppCars(i).History(3,:)+t_rng(:)';
end

%%
ha = axes;
% loop through every time step
for i = 1:nIterations-10
    %loop through reach competing car
    for j = 1:N
        t_in = oppDistToJunc(j,i)/oppCars(j).History(3,i)+t_rng(i);
        t_out = (oppDistToJunc(j,i)+(s_out-s_in))/oppCars(j).History(3,i)+t_rng(i);
        
        
        ha = decision_space_plot([t_in, t_out, t_out, t_in],...
                           [s_in, s_in, s_out, s_out],...
                           oppCars(j).maximumVelocity,[3.5, -3.5],ha);
    end
    plot3(selfCar.History(1,1:i),selfCar.History(2,1:i),selfCar.History(3,1:i),'m-*')
%     pause()
    drawnow
%     cla
end
%%
ha = axes;
% decision_space_plot([selfCar.t_in, selfCar.t_out, selfCar.t_out, selfCar.t_in],...
%                            [s_in, s_in, s_out, s_out],...
%                            oppCars(j).maximumVelocity,[3.5, -3.5],ha);
        ha = decision_space_plot([t_in(end), t_out(end), t_out(end), t_in(end)],...
                           [s_in, s_in, s_out, s_out],...
                           oppCars(j).maximumVelocity,[3.5, -3.5],ha);
plot3(selfCar.History(1,:),selfCar.History(2,:),selfCar.History(3,:),'r-o','LineWidth',2)