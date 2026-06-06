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
time_to_split = 20;         % Define Episode Length

hs_str = strrep(num2str(H_s), '.', 'p');
tp_str = strrep(num2str(Tp), '.', 'p'); 
N_train = round(N_waves * 0.8);
N_test = N_waves - N_train;

% Add the 'functions' folder path
addpath('functions');

% Run the code generating wave data
generate_wave_data(N_waves, duration, dt, Tp, gamma, H_s, JONSWAP_N, hydro_location);
train_folder = sprintf("Train_waveDataset_Hs%s_Tp%s_NW%d_JN%d", hs_str, tp_str, N_train, JONSWAP_N); 
test_folder = sprintf("Test_waveDataset_Hs%s_Tp%s_NW%d_JN%d", hs_str, tp_str, N_train, JONSWAP_N);

% Split smaller data
split_wave_dataset(train_folder, test_folder, time_to_split);

disp('Complete Train & Validation Data Generation!');


