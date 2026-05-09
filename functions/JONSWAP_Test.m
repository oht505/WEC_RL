clear; clc;

%% JOSWAP case test

duration=400; % simulation time

t = linspace(0,duration,duration*100)';
dt=t(2)-t(1); % timestep

%%% Wave time series generation (JOSWAP Spectrum)
gamma = 5; %% Narrowness of spectrum
fp = 1/9; %% Peak Frequency
wbar = 2*pi*fp;
H_s = 2; %% Significant wave height = (m)
[S_f, S_w] = JONSWAP(gamma,fp,H_s);
% eta_JONSWAP= psd2eta(S_w,fp,t);
% eta = [t eta_JONSWAP];


%% Instantaneous value calculation parameters
window_size = round(10/fp/dt); % real time calulation window
window_size_seconds= round(window_size*dt);
median_window=0.04*window_size;
median_window_seconds = 0.04*window_size_seconds;

