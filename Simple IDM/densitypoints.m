function k = densitypoints(v,s0,s1,v0,T,delta)

k = (sqrt(1-(v/v0).^delta))./(s0+s1.*sqrt(v/v0)+T.*v);

end