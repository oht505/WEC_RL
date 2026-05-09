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

% % Simple Sine Wave Parameters
% % fp = 1/9;              % Peak frequency (Hz)
% % wbar = 2*pi*fp;        % base angular frequency (rad/s)
% % gamma = 3.3;           % JONSWAP gamma (spectrum narrowness)
% % H_s = 2.4;             % significant wave height (m)
% % rho=1000;
% % g=9.81;
% amplitude = H_s / 2;
% eta_data = amplitude * sin(wbar * t);
% Te = 1/fp;
% t_ramp = 10/Te;
% Ramp.fct = ones(1,length(t));
% Ramp.t_index = find(t_ramp<=t,1);
% Ramp.fct(1,1:Ramp.t_index) = 0.5*(1+cos(pi+pi/t_ramp.*t(1:Ramp.t_index)));
% eta_data = eta_data .* Ramp.fct';
% eta_JONSWAP = [t, eta_data];
% %fprintf("Simple Sine Wave!\n");
% 
% % Generate the JONSWAP spectrum and convert to a time series (psd2eta)
% [S_f, S_w,f_mean] = JONSWAP(gamma, fp, H_s);
% Te = 1/f_mean;
% eta = psd2eta(S_w, fp, t);
% 
% % ramp function
% % t_ramp = 10/f_mean;
% % Ramp.fct = ones(1,length(t));
% % Ramp.t_index = find(t_ramp<=t,1);
% % Ramp.fct(1,1:Ramp.t_index) = 0.5*(1+cos(pi+pi/t_ramp.*t(1:Ramp.t_index)));
% % eta_JONSWAP = [t, eta.*Ramp.fct'];  % column 1: time, column 2: wave elevation
% 
% 
% %% Excitation Force Estimation
% % Load impulse responses for both bodies
% location = 'hydro/rm3.h5';
% [IRF_t, FIR_combined] = Excitation_FIR(location);
% dt_irf = IRF_t(2) - IRF_t(1);  % dt_irf = 0.01 s
% 
% % Store impulse responses in a structure
% IRF.b1 = FIR_combined.b1;
% IRF.b2 = FIR_combined.b2;
% 
% % Create time vector for excitation and upsample to IRF resolution (dt_irf)
% t_ex = (0:dt:(length(eta_JONSWAP(:,2))-1)*dt)';
% t_ex_fine = (t_ex(1):dt_irf:t_ex(end))';
% eta_ex_fine = interp1(t_ex, eta_JONSWAP(:,2), t_ex_fine, 'linear', 'extrap');
% 
% % Perform convolution for each body (scale by dt_irf)
% Fex_b1 = conv(eta_ex_fine, IRF.b1, 'full') * dt_irf;
% Fex_b2 = conv(eta_ex_fine, IRF.b2, 'full') * dt_irf;
% 
% % Create time vector for the convolution result (fine grid)
% t_conv = (t_ex_fine(1) + IRF_t(1)) : dt_irf : (t_ex_fine(end) + IRF_t(end));
% t_conv = t_conv(1:length(Fex_b1));  % Ensure matching length
% 
% % Downsample the convolved force back to the original excitation time vector 't'
% Fex_b1 = interp1(t_conv, Fex_b1, t, 'linear', 'extrap');
% Fex_b2 = interp1(t_conv, Fex_b2, t, 'linear', 'extrap');
% E_wave_theoretical = (1/16) * rho * g * H_s^2;
% 
% k = (2*pi*S_f(:,1)).^2/g;
% v_g = 1/2*sqrt(g./k);
% P_wave = rho*g*trapz(S_f(:,1),v_g.*S_f(:,2));
% P_wave_a = rho*g^2*H_s^2*Te/64/pi;
% 
% %% load files
% filename = "hydro/rm3.h5";
% hydro=h5tostruct(filename);
% % % Fex_ts=load("rm3excitationforces_H2p4T9p0_0p1_seed1.mat");
% % % Fex = Fex_ts.Fex_RM3_H2p4T9p0_0p1_seed1;
% % 
% % % t=Fex_ts.eta_RM3_H2p4T9p0_0p1_seed1.Time;
% % % dt = round(t(2)-t(1),1);
% % % eta= Fex_ts.eta_RM3_H2p4T9p0_0p1_seed1;
% % 
% % Create a 1×2 timeseries array (one per body)
% Fex(1) = timeseries(Fex_b1, t);
% Fex(2) = timeseries(Fex_b2, t);
% 
% % Optionally, assign names to each timeseries for clarity
% Fex(1).Name = 'Body 1 Excitation Force';
% Fex(2).Name = 'Body 2 Excitation Force';
% eta = timeseries(eta_JONSWAP(:,2),t);
% 
% N_Fex = Fex(1)/max(Fex(1));
% 
% if ~exist('FIR_combined', 'var')
%     [IRF_t, FIR_combined] = Excitation_FIR(location);
%     dt_irf = IRF_t(2) - IRF_t(1);
%     IRF.b1 = FIR_combined.b1;
%     IRF.b2 = FIR_combined.b2;
% end

%% Butterworth Filter Setting
% f_low = 6/(2*pi);
% f_high = 14/(2*pi); 
% 
% Wn = [f_low f_high] / (fs/2);
% [b, a] = butter(2, Wn, 'bandpass');
