close all

%% Data Load
% Test Wave
wave_num = 149;
test_wave_file = sprintf('/nfs/hpc/share/ohhyun/WEC/Test_waveDataset_Hs3p66_Tp9p7_NW200_JN1000_dt0p1/Wave_%d.mat', wave_num);
wave_data = load(test_wave_file);
w = wave_data.w;
eta = w.eta;

% RL
%load('/nfs/hpc/share/ohhyun/WEC/TestSimulation_Results/Log_Agent_700/Result_Wave_200.mat')
rl_file = sprintf('/nfs/hpc/share/ohhyun/WEC/Validation_Results/EE_lstm_split20_Filter0p25_dt0p1_Best_Seed42_NoTouch/Agent9000_best/Result_Wave_%d.mat', wave_num);
data = load(rl_file);
damp = data.B_pto;
displac = data.rl_obs(:,1);
float = data.rl_obs(:, 3);

% Inst. Freq
inst_data = load('/nfs/hpc/share/ohhyun/WEC/Validation_Results_Control/Control_Validation_Summary.mat');
inst_damp = inst_data.Damping_All(:, wave_num);

%% Plot three individual graph
dt = 0.1;
time = (0:length(eta)-1) * dt;
labelFontSize = 22;
legendFontSize = 24;
titleFontSize = 24;
gcaFontSize = 20;

% Eta
figure('Color', 'w', 'Position', [100, 600, 1400, 600]);
plot(time, eta, 'Color', 'black', 'LineWidth', 1.0);
grid on;
xlabel('Time (s)', 'Interpreter','latex', 'FontSize', labelFontSize);
ylabel('$\eta$ (m)', 'Interpreter', 'latex', 'FontSize', labelFontSize);
legend('Wave Elevation', 'Location', 'northeast', 'FontSize', legendFontSize, 'Interpreter', 'latex');
title(['Wave Elevation: Wave #', num2str(wave_num)], 'FontSize', titleFontSize);
set(gca, 'FontSize', gcaFontSize, 'TickLabelInterpreter', 'latex');
ax1 = gca;

% RL Damp
figure('Color', 'w', 'Position', [100, 300, 1400, 600]);
p1 = plot(time, damp, 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.5);
grid on;
xlabel('Time (s)', 'Interpreter','latex', 'FontSize', labelFontSize);
ylim([0 5e7]);
ytickformat('%.1f');
ylabel('$B_{pto,RL}$ (N$\cdot $s/m)', 'Interpreter', 'latex', 'FontSize', labelFontSize);
legend('RL Control', 'Location', 'northeast', 'FontSize', legendFontSize, 'Interpreter', 'latex');
title(sprintf('RL Control Damping Coefficient: Wave #%d', wave_num), 'FontSize', titleFontSize);
set(gca, 'FontSize', gcaFontSize, 'TickLabelInterpreter', 'latex');
ax2 = gca;

% Inst.Freq Damp
figure('Color', 'w', 'Position', [100, 50, 1400, 600]);
p2 = plot(time, inst_damp, 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 1.5);
grid on;
ylim([0 5e7]);
ytickformat('%.1f');
ylabel('$B_{pto,Inst}$ (N$\cdot $s/m)', 'Interpreter', 'latex', 'FontSize', labelFontSize);
xlabel('Time (s)', 'Interpreter','latex', 'FontSize', labelFontSize);
legend('Inst. Freq Control', 'Location', 'northeast', 'FontSize', legendFontSize, 'Interpreter', 'latex');
title(sprintf('Instantaneous Freq. Control Damping Coefficient: Wave #%d', wave_num), 'FontSize', titleFontSize);
set(gca, 'FontSize', gcaFontSize, 'TickLabelInterpreter', 'latex');
ax3 = gca;

linkaxes([ax1, ax2, ax3], 'x');
xlim([710.1, 780]);

drawnow;

save_dir = 'Plots';

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

file1 = fullfile(save_dir, sprintf('Wave_%d_1_Elevation.png', wave_num));
exportgraphics(ax1.Parent, file1, 'Resolution', 300);

file2 = fullfile(save_dir, sprintf('Wave_%d_2_RL_Damping.png', wave_num));
exportgraphics(ax2.Parent, file2, 'Resolution', 300);

file3 = fullfile(save_dir, sprintf('Wave_%d_3_Inst_Damp.png', wave_num));
exportgraphics(ax3.Parent, file3, 'Resolution', 300);

disp("Save Done");
%% Plot Tile for Damp
dt = 0.1;
time = (0:length(eta)-1) * dt;
fig = figure('Color', 'w', 'Position', [100, 100, 800, 600]);
t = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

% Eta
ax1 = nexttile;
% plot(time, eta, 'Color', [0, 0.4470, 0.7410], 'LineWidth', 1.5);
plot(time, eta, 'Color', 'black', 'LineWidth', 1.0);
grid on;
ylabel('$\eta$ (m)', 'Interpreter','latex', 'FontSize', 14);
legend('Wave Elevation', 'Location', 'northeast', 'FontSize', 11, 'Interpreter', 'latex');
title(sprintf('Performance Analysis: Wave %d', wave_num), 'FontSize', 16);
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');

% Inst.Freq
ax2 = nexttile;
p2 = plot(time, inst_damp, 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 1.5);
grid on;
ylabel('$B_{pto,Inst}$ (N$\cdot $s/m)', 'Interpreter', 'latex', 'FontSize', 14);
ylim([0 5e7]);
legend('Inst. Freq Control', 'Location', 'northeast', 'FontSize', 11, 'Interpreter', 'latex');
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
 
% RL 
ax3 = nexttile;
p1 = plot(time, damp, 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.5);
grid on;
ylim([0 5e7]);
ylabel('$B_{pto,RL}$ (N$\cdot $s/m)', 'Interpreter', 'latex', 'FontSize', 14);
xlabel('Time (s)', 'Interpreter','latex', 'FontSize', 14);
legend('RL Control', 'Location', 'northeast', 'FontSize', 11, 'Interpreter', 'latex');
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');

linkaxes([ax1, ax2, ax3], 'x');
xlim([710, 780]);
% xlim([300, 400]);
% xlim([0, time(end)]);
