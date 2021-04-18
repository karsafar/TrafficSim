function s = calc_safe_gap(a,b,v,v_0,T,s_0,del,a_min,varargin)
%% redesign as it is not consistent for type A and B 
if nargin == 8
    %% used for comfortableStopGap && minStopDistGapToJunc in type A. Type B doesn't use it any more
    s = sqrt(max(0,((s_0 + T*v + v^2/(2*(a*b)^(1/2)))^2/(-(v/v_0)^del - a_min/a + 1))));
else
    %% only futureMinStopGap uses it for type A
    % a_min has to be with positive sign, because derived from the equation v^2 =
    % v_0^2+2a(s-s_0)
%     s = s_0 + T*v - v^2/(2*a_min);
    s = - v^2/(2*a_min);
end
