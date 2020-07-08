function ha = decision_space_plot(xlimit, ylimit,v_max,a_max,ha)
%%
% cla(ha)
axes(ha);
camlight;

%% rectangle plotting
p1 = [xlimit(1) ylimit(1) 0]; 
p2 = [xlimit(2) ylimit(2) 0];
p3 = [xlimit(3) ylimit(3) 0];
p4 = [xlimit(4) ylimit(4) 0];
p5 = [xlimit(1) ylimit(1) v_max]; 
p6 = [xlimit(2) ylimit(2) v_max];
p7 = [xlimit(3) ylimit(3) v_max];
p8 = [xlimit(4) ylimit(4) v_max];
poly_rectangle(p1, p2, p3, p4,ha)
poly_rectangle(p1, p2, p6, p5,ha)
poly_rectangle(p4, p1, p5, p8,ha)
poly_rectangle(p3, p4, p8, p7,ha)
poly_rectangle(p2, p3, p7, p6,ha)
poly_rectangle(p5, p6, p7, p8,ha)


n = 100;
%% Pass ahead plot
t_rng = linspace(0, xlimit(1),n);
u_rng = linspace(v_max,0,n);
t_in = xlimit(1);
s0 = ylimit(3);

pass_ahead(u_rng,t_in,s0,t_rng,a_max(2),ha);



%% Pass ahead at max vel plot
t_rng = linspace(xlimit(1),0,n);
u = v_max;
s0 = fliplr(ylimit(3) - u*(t_rng));

T_in = zeros(n,n);
k = 1;
for t_in = t_rng
%     T_in = [ T_in; linspace(t_in,0,n)];
    T_in(k,:) = linspace(t_in,0,n);
    k = k + 1;
end

pass_ahead_at_max_vel(u,s0,T_in,a_max(2),ha)


%% Pass behind plot
t_rng = linspace(0, xlimit(2),n);
u_rng = linspace(v_max,0,n);
t_out = xlimit(2);
s0 = ylimit(1);

pass_behind(u_rng,t_out,s0,t_rng,a_max(1),ha);



%% Stop and wait plot
t_rng = linspace(xlimit(1)-xlimit(1),xlimit(2),n);
u = 0;
s0 = ylimit(1);

    
% T_out = [];
T_out = zeros(n,n);
k = 1;
for t_out = t_rng
%     T_out = [ T_out; linspace(0,t_out,n)];
    T_out(k,:) = linspace(t_out,0,n);
    k = k + 1;
end

stop_and_wait(u,t_rng,s0,T_out,a_max(2),ha)

ha = gca;
% axis(ha,[xlimit(2)-10   (xlimit(2)+5) -20 10 0 v_max],'vis3d')
% view(ha,3); camlight; 
xlabel(ha,'Time (s)');
ylabel(ha,'Displacement (m)');
zlabel(ha,'Velocity (m/s)');
zlim([0 13])
ylim([ylimit(1)-30 ylimit(4)+20])
end

%-----------------------------------------------------------------------

%% sub-functions
function pass_ahead(u0_rng,t1,s0,t_rng,a_max,ha)

[T_rng,U] = meshgrid((t1-t_rng),u0_rng); 
U_rng = fliplr(U + a_max*(T_rng)); 
S = fliplr(s0 - u0_rng'.* T_rng - 0.5*a_max*T_rng.*T_rng); 

surface(ha,T_rng,S,U_rng, 'FaceColor', 'g', 'EdgeColor', 'none');
end

%-----------------------------------------------------------------------

function pass_ahead_at_max_vel(u0,s0,T,a_max,ha)

U = fliplr(u0 + a_max*T); % minus sign due to backwards drawing
S = fliplr(s0' - u0*T - 0.5*a_max*T.*T); % minus sign due to backwards drawing

surface(ha,T,S,U, 'FaceColor', 'c', 'EdgeColor', 'none');
end
%-----------------------------------------------------------------------

function pass_behind(u0_rng,t1,s0,t_rng,a_max,ha)

[T_rng,U] = meshgrid((t1 - t_rng),u0_rng);
U_rng = U + a_max*(T_rng);                 
S = s0 - u0_rng'.*T_rng - 0.5*a_max*T_rng.*T_rng; 

surface(ha,T_rng,fliplr(S),fliplr(U_rng), 'FaceColor', 'm', 'EdgeColor', 'none');
end

%-----------------------------------------------------------------------

function stop_and_wait(u0,t1_rng,s0,T,a_max,ha)

U = u0 - a_max*(-T+repmat(t1_rng,size(T,2),1)'); % minus sign due to backwards drawing
S = s0 - u0*(-T+repmat(t1_rng,size(T,2),1)') + 0.5*a_max*(T-repmat(t1_rng,size(T,2),1)')...
    .*(T-repmat(t1_rng,size(T,2),1)'); % minus sign due to backwards drawing

surface(ha,T,S,U, 'FaceColor', 'b', 'EdgeColor', 'none');
end

%-----------------------------------------------------------------------

%% draw the rectangluar obstacle shape
function poly_rectangle(p1, p2, p3, p4,ha)
% The points must be in the correct sequence.
% The coordinates must consider x, y and z-axes.
x = [p1(1) p2(1) p3(1) p4(1)];
y = [p1(2) p2(2) p3(2) p4(2)];
z = [p1(3) p2(3) p3(3) p4(3)];
fill3(ha,x, y, z, rand(size(p1)),'FaceColor', [1 0 0]);
hold on
end