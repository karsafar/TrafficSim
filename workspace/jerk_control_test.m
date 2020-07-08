j = 1;
a = 0;
v = 0;
d = 0;
t = 0;

t_f = 10;

dt = 0.2;

states = [];
while t < t_f
    states = [states; j a v d t];
    a = a + j*dt;
    v = v + a*dt;
    d = d + v*dt;
        
    %% 
    t = t+dt;
    if abs(t-5) < 0.001
        j = -1;
    end
end

%% Plotting

figure
t = tiledlayout(4,1);
xlabel(t,'Time (s)', 'FontSize', 16)

% jerk
nexttile(t)
plot(states(:,5),states(:,1),'-','LineWidth',2)

% acceleration
nexttile(t)
plot(states(:,5),states(:,2),'-','LineWidth',2)

% velocity
nexttile(t)
plot(states(:,5),states(:,3),'*-','LineWidth',2)

% displacement
nexttile(t)
plot(states(:,5),states(:,4),'*-','LineWidth',2)