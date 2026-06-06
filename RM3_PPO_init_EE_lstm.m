addpath("functions/")

%% Generate a JONSWAP wave time series
if ~exist('duration', 'var'), duration = 20; end
if ~exist('dt', 'var'), dt = 0.1; end
if ~exist('t', 'var'), t = (0:dt:duration)'; end

% Define wave parameters
if ~exist('Tp', 'var'), Tp = 9.7; end             % Peak Period (s)
if ~exist('fp', 'var'), fp = 1/(9.7); end            % Peak frequency (Hz)
if ~exist('wbar', 'var'), wbar = 2*pi*fp; end        % base angular frequency (rad/s)
if ~exist('gamma', 'var'), gamma = 3.3; end        % JONSWAP gamma (spectrum narrowness)
if ~exist('H_s', 'var'), H_s = 3.66; end            % significant wave height (m)
if ~exist('rho', 'var'), rho=1000; end
if ~exist('g', 'var'), g=9.81; end
if ~exist('JONSWAP_N', 'var'), JONSWAP_N = 1000; end
if ~exist('fs', 'var'), fs = 10; end
if ~exist('N_cycle', 'var'), N_cycle=1; end
if ~exist('N_hist', 'var'), N_hist=1; end
% if ~exist('fc', 'var'), fc = 0.8; end
if ~exist('initDamping', 'var'), initDamping = 0; end
if ~exist('initDSS', 'var'), initDSS = zeros(1, 10); end
if ~exist('init_state_vec', 'var'), init_state_vec = zeros(307, 1); end
if ~exist('is_first_part', 'var'), is_first_part = 1; end


% SS model load
ss_model_path = 'rm3_ss_0p1.mat';
if exist(ss_model_path, 'file')
    load("rm3_ss_0p1.mat");
else
    warning('State-space model file not found.');
end

clear eta Fex eta_data eta_JONSWAP;
