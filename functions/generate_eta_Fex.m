function [eta, Fex, P_wave_a, E_wave_theoretical,f_mean] = generate_eta_Fex(t, fp, gamma, H_s, hydro_filename)
% generate_eta_Fex: Generates wave elevation (eta) and excitation forces (Fex) 
% from given wave parameters and hydrodynamic data.
%
% Inputs:
%   duration        - total simulation time [s]
%   fs              - sampling frequency [Hz]
%   fp              - peak frequency [Hz]
%   gamma           - JONSWAP peak enhancement factor
%   H_s             - significant wave height [m]
%   hydro_filename  - path to hydro.h5 file (hydrodynamic data)
%
% Outputs:
%   eta             - timeseries object of surface elevation [m]
%   Fex             - array of timeseries objects for excitation force [N]
%   P_wave          - theoretical wave power per unit width [W/m]
%   E_wave_theoretical - theoretical wave energy density [J/m^2]

% Constants
rho = 1000;          % water density [kg/m^3]
g = 9.81;            % gravity [m/s^2]


% Generate JONSWAP spectrum and wave elevation
[~, S_w, f_mean] = JONSWAP(gamma, fp, H_s);
Te = 1/f_mean;
eta_raw = psd2eta(S_w, fp, t);

% Apply ramp-up function
t_ramp = 10/f_mean;
Ramp.fct = ones(size(t));
Ramp.t_index = find(t >= t_ramp, 1);
Ramp.fct(1:Ramp.t_index) = 0.5*(1 + cos(pi + pi/t_ramp * t(1:Ramp.t_index)));
eta_signal = eta_raw .* Ramp.fct;

% Store eta as timeseries
eta = timeseries(eta_signal, t);
eta.Name = 'Surface Elevation (eta)';

% Load hydrodynamic impulse response function (IRF)
[IRF_t, FIR_combined] = Excitation_FIR(hydro_filename);
dt_irf = IRF_t(2) - IRF_t(1);

IRF.b1 = FIR_combined.b1;
IRF.b2 = FIR_combined.b2;

% Resample eta to IRF resolution
t_ex_fine = (t(1):dt_irf:t(end))';
eta_ex_fine = interp1(t, eta_signal, t_ex_fine, 'linear', 'extrap');

% Convolve eta with IRFs
Fex_b1_full = conv(eta_ex_fine, IRF.b1, 'full') * dt_irf;
Fex_b2_full = conv(eta_ex_fine, IRF.b2, 'full') * dt_irf;

% Generate corresponding time vector
t_conv = (t_ex_fine(1) + IRF_t(1)) : dt_irf : (t_ex_fine(end) + IRF_t(end));
t_conv = t_conv(1:length(Fex_b1_full));  % match lengths

% Downsample back to original time resolution
Fex_b1 = interp1(t_conv, Fex_b1_full, t, 'linear', 'extrap');
Fex_b2 = interp1(t_conv, Fex_b2_full, t, 'linear', 'extrap');

% Create timeseries for excitation forces
Fex(1) = timeseries(Fex_b1, t);
Fex(2) = timeseries(Fex_b2, t);
Fex(1).Name = 'Body 1 Excitation Force';
Fex(2).Name = 'Body 2 Excitation Force';

% Theoretical wave energy and power
E_wave_theoretical = (1/16) * rho * g * H_s^2;
P_wave_a = rho*g^2*H_s^2*Te/64/pi;
end
