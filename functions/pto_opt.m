function [pto_damping, pto_stiffness] = pto_opt(w_ref, option,hydro)

% Get parameters from the hydro structure
w = hydro.w;
A_float_norm = hydro.float.A_m(3, 3, :); % Float added mass in Heave direction
B_float_norm = hydro.float.R_damp(3, 3, :); % Float Radiation Damping in Heave direction
A_spar_norm = hydro.spar.A_m(3, 9, :); % Spar added mass in Heave direction
B_spar_norm = hydro.spar.R_damp(3, 9, :); % Spar Radiation Damping in Heave direction

M1 = hydro.float.M;
M2 = hydro.spar.M;
K1 = hydro.float.K_hs(3, 3) * 1000 * 9.8;
K2 = hydro.spar.K_hs(3, 3) * 1000 * 9.8;

% Calculate the stable limit for Kpto
Kpto_stablelimit = -K1 * K2 / (K1 + K2);

% Find the index corresponding to the closest period to T_ref
[~, ix] = min(abs(w_ref - w));
w = w(ix); % Angular frequency

% Get parameters at the selected index
A1 = A_float_norm(ix) * 1000 ;
A2 = A_spar_norm(ix) * 1000;
B1 = B_float_norm(ix) * 1000 * w;
B2 = B_spar_norm(ix) * 1000 * w;

% Calculate impedance terms
Z1 = (1i * w * (M1 + A1)) + (1 / (1i * w) * K1) + B1;
Z2 = (1i * w * (M2 + A2)) + (1 / (1i * w) * K2) + B2;
Zt = Z1 * Z2 / (Z1 + Z2);

% Compute the output based on the option
if option == 0
    pto_damping = abs(Zt);
    pto_stiffness = 0;
elseif option == 1
    pto_damping = real(Zt);
    pto_stiffness = w * imag(Zt);
    if pto_stiffness < Kpto_stablelimit
        pto_stiffness = 0.9 * Kpto_stablelimit;
        pto_damping = sqrt((imag(Zt) - 1 / w * pto_stiffness)^2 + real(Zt)^2);
    end
else
    error('Unknown function option');
end
y = [pto_damping, pto_stiffness];

end