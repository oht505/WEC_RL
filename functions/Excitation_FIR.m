function [IRF_t, FIR_combined] = Excitation_FIR(Hydro_coef_location)
    % For Body 1:
    IRF_Fex_b1 = 1000 * 9.81 * h5read(Hydro_coef_location, '/body1/hydro_coeffs/excitation/impulse_response_fun/f');
    IRF_Fex_b1 = squeeze(IRF_Fex_b1(:,1,3));  % Extract the relevant column
    IRF_t = h5read(Hydro_coef_location, '/body1/hydro_coeffs/excitation/impulse_response_fun/t');  % Time vector (assumed same for both bodies)
    
    indx_zero = find(IRF_t == 0);
    if isempty(indx_zero)
        error('No zero time found in IRF_t for body 1.');
    end
    FIR_non_causal.b1 = IRF_Fex_b1(1:indx_zero-1);
    FIR_causal.b1     = IRF_Fex_b1(indx_zero:end);
    FIR_combined.b1   = [FIR_non_causal.b1; FIR_causal.b1];
    
    % For Body 2:
    IRF_Fex_b2 = 1000 * 9.81 * h5read(Hydro_coef_location, '/body2/hydro_coeffs/excitation/impulse_response_fun/f');
    IRF_Fex_b2 = squeeze(IRF_Fex_b2(:,1,3));  % Extract the relevant column
    % We assume the time vector is the same as for body 1.
    indx_zero_b2 = find(IRF_t == 0);
    if isempty(indx_zero_b2)
        error('No zero time found in IRF_t for body 2.');
    end
    FIR_non_causal.b2 = IRF_Fex_b2(1:indx_zero_b2-1);
    FIR_causal.b2     = IRF_Fex_b2(indx_zero_b2:end);
    FIR_combined.b2   = [FIR_non_causal.b2; FIR_causal.b2];
end
