function q = flowpoints(v,s0,s1,v0,T,delta)

q = (v.*sqrt(1-(v/v0).^delta))./(s0+s1.*sqrt(v/v0)+T.*v);

end