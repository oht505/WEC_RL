function hydro = h5tostruct(filename)
        % Case: Input is a cell array with at least two filenames
        h5BodyName = '/body1';
        h5BodyName2 = '/body2';
    
        % Simulation parameters for the first file
        hydro.T = h5read(filename, '/simulation_parameters/T');
        hydro.w = h5read(filename, '/simulation_parameters/w');

        % Float data from the first file
        hydro.float.A_m =  reverseDimensionOrder(h5read(filename, [h5BodyName '/hydro_coeffs/added_mass/all']));
        hydro.float.R_damp = reverseDimensionOrder(h5read(filename, [h5BodyName '/hydro_coeffs/radiation_damping/all']));
        hydro.float.K_hs = reverseDimensionOrder(h5read(filename, [h5BodyName '/hydro_coeffs/linear_restoring_stiffness']));
        hydro.float.M = 1000* h5read(filename,[h5BodyName '/properties/disp_vol']);
        hydro.float.Fex.re = h5read(filename, [h5BodyName '/hydro_coeffs/excitation/re']);
        hydro.float.Fex.im = h5read(filename, [h5BodyName '/hydro_coeffs/excitation/im']);
        hydro.float.Fex.IRF.f = h5read(filename, [h5BodyName '/hydro_coeffs/excitation/impulse_response_fun/f']);
        hydro.float.Fex.IRF.t = h5read(filename, [h5BodyName '/hydro_coeffs/excitation/impulse_response_fun/t']);
        % Spar data from the first file
        hydro.spar.A_m =  reverseDimensionOrder(h5read(filename, [h5BodyName2 '/hydro_coeffs/added_mass/all']));
        hydro.spar.R_damp = reverseDimensionOrder(h5read(filename, [h5BodyName2 '/hydro_coeffs/radiation_damping/all']));
        hydro.spar.K_hs = reverseDimensionOrder(h5read(filename, [h5BodyName2 '/hydro_coeffs/linear_restoring_stiffness']));
        hydro.spar.M = 1000* h5read(filename,[h5BodyName2 '/properties/disp_vol']);
        hydro.spar.Fex.re = h5read(filename, [h5BodyName2 '/hydro_coeffs/excitation/re']);
        hydro.spar.Fex.im = h5read(filename, [h5BodyName2 '/hydro_coeffs/excitation/im']);
        hydro.spar.Fex.IRF.f = h5read(filename, [h5BodyName2 '/hydro_coeffs/excitation/impulse_response_fun/f']);
        hydro.spar.Fex.IRF.t = h5read(filename, [h5BodyName2 '/hydro_coeffs/excitation/impulse_response_fun/t']);
end
