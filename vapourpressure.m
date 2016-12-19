function vp = vapourpressure(T, rh)
% calculate the vapour pressure for given temperature and relative
% humidity.
psat = 100*exp(18.965 - 4030/(T+235));
vp = rh * psat;
end

