function s = calc_safe_gap(a,b,v,v_0,T,s_0,del,a_min,varargin)
if nargin == 8
    s = sqrt((s_0 + T*v + v^2/(2*(a*b)^(1/2)))^2/(-(v/v_0)^del - a_min/a + 1));
else
    s = s_0 + T*v + v^2/(2*a_min);
end

