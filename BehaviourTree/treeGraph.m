ha = axes;

nodes = [0 1 2 2 1 5 5 7 7,1];
% nodes = [0 1 2 2 2 1 6 6 8 8];
% nodes = [0 1 2 2 1];

str1 = ' ? ';
str2 = '-->';
str3 = '1+2';
str4 = 'Emerg';


str = {str1,str2,str3,str3,str2,str3,str2,str3,str3,str4};

[x,y,h]=treelayout(nodes);


f = find(nodes~=0);
pp = nodes(f);

X = [x(f); x(pp); NaN(size(f))];
Y = [y(f); y(pp); NaN(size(f))];

X = X(:);
Y = Y(:);

% annotation(str1)

plot(ha, X, Y, 'ko-');
axis([0 1 0 1]);
hold on
text(ha,x,y,str,'EdgeColor','k','LineStyle','-','BackgroundColor','w','HorizontalAlignment','center')
ha.Visible = 'off';
