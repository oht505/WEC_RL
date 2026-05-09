clear; clc;

%% JONSWAP wave generator

duration=400; % simulation time

t = linspace(0,duration,duration*100)';
dt=t(2)-t(1); % timestep

%%% Wave time series generation (JOSWAP Spectrum)
gamma = 5; %% Narrowness of spectrum
fp = 1/9; %% Peak Frequency
wbar = 2*pi*fp;
H_s = 2; %% Significant wave height = (m)
% [S_f, S_w] = JONSWAP(gamma,fp,H_s);
% eta_JONSWAP= psd2eta(S_w,fp,t);
% eta = [t eta_JONSWAP];


%% load files
filename = "hydro/rm3.h5";
hydro=h5tostruct(filename);

Fex_ts=load("rm3excitationforces_H2p4T9p0_0p1_seed1.mat");
Fex_ts.Fex_1 = Fex_ts.Fex_RM3_H2p4T9p0_0p1_seed1.data;
Fex_ts.Fex_2 = Fex_ts.Fex_RM3_H2p4T9p0_0p1_seed1.data;
load("rm3_ss_0p1.mat")

%% Instantaneous value calculation parameters
window_size = round(10/fp/dt); % real time calulation window
window_size_seconds= round(window_size*dt);
median_window=0.04*window_size;
median_window_seconds = 0.04*window_size_seconds;

