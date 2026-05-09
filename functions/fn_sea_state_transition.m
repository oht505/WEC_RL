function [eta,t] = fn_sea_state_transition(Hs_1,Tp_1,Hs_2,Tp_2,t_end)
% PM spectrum from
% https://www.codecogs.com/library/engineering/fluid_mechanics/waves/spectra/pierson_moskowiTp.php

dt = 0.1;

w_start = 2*pi/15;
w_end = 2*pi/1;
dw = 2*pi/t_end;

w = [w_start:dw:w_end];
f = w/(2*pi);

t = [0:dt:t_end];
length_t = length(t);
phase = rand(size(w))*2*pi;
for c = 1:length_t
    Tp_c = Tp_1 + (Tp_2 - Tp_1)*c/length_t;
    Hs_c = Hs_1 + (Hs_2 - Hs_1)*c/length_t;
    S_c = 5*pi^4*Hs_c^2/Tp_c^4*(1./w.^5).*exp(-20*pi^4/Tp_c^4*(1./w.^4))*(w(2)-w(1));
    eta(c) = sum(sqrt(2*S_c).*sin(w*t(c)+phase));
end