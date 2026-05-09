function out = eta2Fex(eta, Fs, hydroFile, varargin)
%ETA2FEX  Compute excitation force via two-sided IRF convolution.
%
%   out = ETA2FEX(eta, Fs, hydroFile)
%   out = ETA2FEX(eta, Fs, hydroFile, 'IRFWindow', [-20 20], ...
%                 'Rho', 1025, 'g', 9.81, 'Index', [1 3], ...
%                 'RemoveMean', true, 'PeakPeriod', [])
%
% Inputs
%   eta       : wave elevation time series (Nx1 or 1xN) [m]
%   Fs        : sampling rate of eta [Hz] (e.g., 5)
%   hydroFile : path to .h5 hydro file (e.g., "hydro/rm3.h5")
%
% Name-Value options
%   'IRFWindow'   : [tmin tmax] seconds for two-sided IRF (default [-20 20])
%   'Rho'         : water density [kg/m^3] (default 1025)
%   'g'           : gravity [m/s^2] (default 9.81)
%   'Index'       : [ih idof] indices into f(:,ih,idof) (default [1 3])
%   'RemoveMean'  : logical, remove mean of eta (default true)
%   'PeakPeriod'  : peak period Tp [s] for extracting coefficients (default [])
%
% Output struct 'out'
%   out.t, out.eta
%   out.tIRF, out.hFloat, out.hSpar
%   out.FexFloat, out.FexSpar
%   out.hydro (optional): hydro coefficients and Tp-sliced values if PeakPeriod is provided
%   out.heave (optional): heave-only coefficients (float/spar) at PeakPeriod

% -------------------- parse inputs --------------------
p = inputParser;
p.addRequired("eta", @(x) isnumeric(x) && isvector(x));
p.addRequired("Fs",  @(x) isnumeric(x) && isscalar(x) && x>0);
p.addRequired("hydroFile", @(x) isstring(x) || ischar(x));

p.addParameter("IRFWindow", [-20 20], @(x) isnumeric(x) && numel(x)==2 && x(2)>x(1));
p.addParameter("Rho", 1025, @(x) isnumeric(x) && isscalar(x) && x>0);
p.addParameter("g", 9.81,  @(x) isnumeric(x) && isscalar(x) && x>0);
p.addParameter("Index", [1 3], @(x) isnumeric(x) && numel(x)==2);
p.addParameter("RemoveMean", true, @(x) islogical(x) && isscalar(x));
p.addParameter("PeakPeriod", [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>0));

p.parse(eta, Fs, hydroFile, varargin{:});
opt = p.Results;

dt = 1/opt.Fs;

% eta conditioning
x = opt.eta(:);
if opt.RemoveMean
    x = x - mean(x);
end
N = numel(x);
t = (0:N-1).' * dt;

% -------------------- load hydro + extract IRFs --------------------
hydro = h5tostruct(opt.hydroFile);

ih   = opt.Index(1);
idof = opt.Index(2);

getIRF = @(H) deal( ...
    H.Fex.IRF.t(:), ...
    (opt.Rho*opt.g) * squeeze(H.Fex.IRF.f(:,ih,idof)) );

[tF, hF] = getIRF(hydro.float);
[tS, hS] = getIRF(hydro.spar);

hF = hF(:); hS = hS(:);

% -------------------- resample to eta dt over two-sided window --------------------
tmin = opt.IRFWindow(1);
tmax = opt.IRFWindow(2);
tIRF = (tmin:dt:tmax).';

hF = interp1(tF, hF, tIRF, "linear", 0);
hS = interp1(tS, hS, tIRF, "linear", 0);

% zero-time index (robust)
[~, k0] = min(abs(tIRF));

% -------------------- convolution + align output to eta timestamps --------------------
Ff_full = dt * conv(x, hF, "full");
Fs_full = dt * conv(x, hS, "full");

% Align so that out.t corresponds to eta time stamps
Ff = Ff_full(k0 : k0+N-1);
Fs = Fs_full(k0 : k0+N-1);

% -------------------- pack --------------------
hydroOut = struct( ...
    "w", hydro.w, "T", hydro.T, ...
    "float", struct("A_m", hydro.float.A_m, "R_damp", hydro.float.R_damp, "K_hs", hydro.float.K_hs, "M", hydro.float.M), ...
    "spar",  struct("A_m", hydro.spar.A_m,  "R_damp", hydro.spar.R_damp,  "K_hs", hydro.spar.K_hs,  "M", hydro.spar.M) );

if ~isempty(opt.PeakPeriod)
    wp = 2*pi/opt.PeakPeriod;
    [~, idx] = min(abs(hydro.w - wp));
    hydroOut.Tp = opt.PeakPeriod;
    hydroOut.idx = idx;
    hydroOut.float.A_m_Tp = hydro.float.A_m(:,:,idx);
    hydroOut.float.R_damp_Tp = hydro.float.R_damp(:,:,idx);
    hydroOut.spar.A_m_Tp = hydro.spar.A_m(:,:,idx);
    hydroOut.spar.R_damp_Tp = hydro.spar.R_damp(:,:,idx);
    if ndims(hydro.float.K_hs) >= 3
        hydroOut.float.K_hs_Tp = hydro.float.K_hs(:,:,idx);
    else
        hydroOut.float.K_hs_Tp = hydro.float.K_hs;
    end
    if ndims(hydro.spar.K_hs) >= 3
        hydroOut.spar.K_hs_Tp = hydro.spar.K_hs(:,:,idx);
    else
        hydroOut.spar.K_hs_Tp = hydro.spar.K_hs;
    end
end

out = struct( ...
    "t", t, "eta", x, ...
    "Fs", opt.Fs, "dt", dt, ...
    "tIRF", tIRF, "hFloat", hF, "hSpar", hS, ...
    "FexFloat", Ff, "FexSpar", Fs, ...
    "hydro", hydroOut, ...
    "meta", struct("hydroFile", string(opt.hydroFile), "IRFWindow", opt.IRFWindow, ...
                   "rho", opt.Rho, "g", opt.g, "Index", opt.Index, "RemoveMean", opt.RemoveMean, ...
                   "PeakPeriod", opt.PeakPeriod) );

% -------------------- heave-only summary at top level --------------------
if ~isempty(opt.PeakPeriod)
    heave = struct();
    heave.omega = wp;
    heave.Tp = opt.PeakPeriod;

    dofFloat = 3; % heave for body 1

    % Determine spar heave indices based on matrix shape:
    % 6x6   -> spar-only block, use (3,3)
    % 6x12  -> row = spar (3), column = combined (6+3=9)
    % 12x12 -> combined, use (9,9)
    nRowS = size(hydro.spar.A_m, 1);
    nColS = size(hydro.spar.A_m, 2);
    if nRowS == 6 && nColS == 12
        sparRow = 3;
        sparCol = 9;
    elseif nRowS >= 12 && nColS >= 12
        sparRow = 9;
        sparCol = 9;
    else
        sparRow = 3;
        sparCol = 3;
    end

    heave.float.A_m_prime = hydro.float.A_m(dofFloat, dofFloat, idx);
    heave.float.R_damp_prime = hydro.float.R_damp(dofFloat, dofFloat, idx);
    heave.float.K_hs_prime = hydro.float.K_hs(dofFloat, dofFloat);
    heave.spar.A_m_prime = hydro.spar.A_m(sparRow, sparCol, idx);
    heave.spar.R_damp_prime = hydro.spar.R_damp(sparRow, sparCol, idx);
    heave.spar.K_hs_prime = hydro.spar.K_hs(3, 3);

    % Denormalize using: A = A' * rho; B = B' * rho * omega; C = C' * rho * g
    heave.float.A_m = heave.float.A_m_prime * opt.Rho;
    heave.float.R_damp = heave.float.R_damp_prime * opt.Rho * heave.omega;
    heave.float.K_hs = heave.float.K_hs_prime * opt.Rho * opt.g;
    heave.spar.A_m = heave.spar.A_m_prime * opt.Rho;
    heave.spar.R_damp = heave.spar.R_damp_prime * opt.Rho * heave.omega;
    heave.spar.K_hs = heave.spar.K_hs_prime * opt.Rho * opt.g;

    heave.units = struct( ...
        "A_m_prime", "nondim", ...
        "R_damp_prime", "nondim", ...
        "K_hs_prime", "nondim", ...
        "A_m", "kg", ...
        "R_damp", "kg/s", ...
        "K_hs", "N/m", ...
        "omega", "rad/s", ...
        "Tp", "s");

    out.heave = heave;
end
end
