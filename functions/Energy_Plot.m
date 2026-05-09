addpath("functions/")
%%% Wave time series generation (JOSWAP Spectrum)
gamma = 4; %% Narrowness of spectrum
fp = 1/9; %% Peak Frequency

Te=1/1.1/fp;
wbar = 2*pi*fp;
H_s = 2.4; %% Significant wave height = (m)
[S_f, S_w] = JONSWAP(gamma,fp,H_s);
rho=1000;
g=9.81;

E_wave_theoretical = (1/16) * rho * g * H_s^2;

k = (2*pi*S_f(:,1)).^2/g;
v_g = 1/2*sqrt(g./k);
P_wave = rho*g*trapz(S_f(:,1),v_g.*S_f(:,2));
P_wave_a = rho*g^2*H_s^2*Te/64/pi;

% Define the control strategies and estimation methods
control_strategies = {'Damping Only', 'PI Control'};
estimation_methods = {'PLL', 'Hilbert', 'Full access', 'Fixed T9'};
scale=1;
% Initialize a matrix to hold the final energy values
final_energies = NaN(2, 4); % 2 control strategies x 4 estimation methods

% Load the data and extract the final energy value for each combination
for ctrl_idx = 0:1
    for est_idx = 1:3
        % Determine the file location based on control strategy and estimation method
        switch ctrl_idx
            case 0
                switch est_idx
                    case 1
                        location = "Output/SS_model/PLL_damping.mat";
                    case 2
                        location = "Output/SS_model/Hilbert_damping.mat";
                    case 3
                        location = "Output/SS_model/Cheat_damping.mat";
                end
            case 1
                switch est_idx
                    case 1
                        location = "Output/SS_model/PLL_PI.mat";
                    case 2
                        location = "Output/SS_model/Hilbert_PI.mat";
                    case 3
                        location = "Output/SS_model/Cheat_PI.mat";
                end
        end
        
        % Load the data
        if isfile(location)
            loaded_data = load(location, 'out');
            % Extract the final energy value (in MJ)
            final_energy = loaded_data.out.Epto.Data(end) / 1e6;
            final_energies(ctrl_idx+1, est_idx) = final_energy;
        else
            warning('File not found: %s', location);
        end
    end
end

% Load the fixed parameter model data at T9 for both Damping Only and PI Control
fixed_locations = {"Output/SS_model/T9_ctrl.mat", "Output/SS_model/T9_PI_ctrl.mat"};
for ctrl_idx = 1:2
    if isfile(fixed_locations{ctrl_idx})
        loaded_data = load(fixed_locations{ctrl_idx}, 'out');
        % Extract the final energy value (in MJ)
        final_energy_T9 = loaded_data.out.Epto.Data(end) / 1e6;
        % Assign this value to the corresponding control strategy and 'Fixed T9' estimation method
        final_energies(ctrl_idx, 4) = final_energy_T9;
    else
        warning('File not found: %s', fixed_locations{ctrl_idx});
    end
end
P_pto = final_energies/20/1200*1e6;
CWR = P_pto' ./ P_wave_a * 100;
formattedCWR = arrayfun(@(x) sprintf('%.2f', x), CWR, 'UniformOutput', false);

% Plot the final energy values
figure;
bar(final_energies);
set(gca, 'XTickLabel', control_strategies);
legend(estimation_methods, 'Location', 'NorthWest',fontsize=28);
xlabel('Control Strategy');
ylabel('Final Energy (MJ)');
%title('Comparison of Final Energy Across Control Strategies and Estimation Methods');
grid on;
ax = gca;
ax.FontSize = 24 * scale;
ax.XAxis.FontSize = 28 * scale;
ax.YAxis.FontSize = 28 * scale;
set(gca, 'LineWidth', 2 * scale);
% Adjust figure size and position
wdw = gcf;
wdw.Position = [0, 661, 1920, 920] * scale/2;
