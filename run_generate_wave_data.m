%% Wave Data Generation Runner
clear; clc;

% Param Settings
N_waves = 1000;             % Number of Samples
duration = 1200;            % Simulation Duration
dt = 0.1;                   % Time Step 
Tp = 9.7;                   % Peak Period
gamma = 3.3;                % JONSWAP Gamma Parameter
H_s = 3.66;                 % Significant Wave Height
JONSWAP_N = 1000;           % Number of JONSWAP Frequency
hydro_location = 'hydro';   % Location of Hydrodynamic Functions

% Add the 'functions' folder path
addpath('functions');

% Run the code generating wave data
generate_wave_data(N_waves, duration, dt, Tp, gamma, H_s, JONSWAP_N, hydro_location);

disp('Complete Train & Validation Data Generation!');


