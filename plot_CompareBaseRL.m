clear; clc; close all;

%% 1. Settings
numWaves = 200;
device_width = 20;
dt = 0.1;

models = [
    struct('name', sprintf('Baseline'), 'dir', fullfile('Validation_Results', 'baseline', 'Damping_1p8_best/')), ...    
    struct('name', 'Inst. Freq', 'dir', fullfile('Validation_Results_Control')), ...
    struct('name', 'PPO-LSTM', 'dir', fullfile('Validation_Results', 'EE_lstm_split20_Filter0p25_dt0p1_Best_Seed42_NoTouch', 'Agent9000_best'))
    
];

controlFile = fullfile('Validation_Results_Control', 'Control_Validation_Summary.mat');
if ~exist(controlFile, 'file')
    error('No Control Summary File');
end
load(controlFile, 'SummaryTable', 'P_wave_a'); 

%% 2. Load RL Data & Integrate Summary Table
MergedTable = table();
MergedTable.WaveIdx = (1:numWaves)';
MergedTable.TheoreticalMaxEnergy = SummaryTable.TheoreticalMaxEnergy_J;

for m = 1:length(models)
    current_Epto = zeros(numWaves, 1);
    current_CWR = zeros(numWaves, 1);

    fprintf("Processing: %s...\n", models(m).name);

    if strcmp(models(m).name, 'Inst. Freq')
        current_Epto = SummaryTable.Final_Epto_J;
        current_CWR = SummaryTable.CWR_Percent;
    else
        for i = 1:numWaves
            filePath = fullfile(models(m).dir, sprintf("Result_Wave_%d.mat", i));
    
            if exist(filePath, 'file')
                data = load(filePath);
    
                if isfield(data, 'Epto')
                    final_E = data.Epto(end);
                    p_len = length(data.Ppto);
                else
                    final_E = NaN;
                end
    
                sim_duration = (p_len - 1) * dt;
                p_avg = final_E / sim_duration / device_width;
    
                current_Epto(i) = final_E;
                current_CWR(i) = (p_avg / P_wave_a) * 100;
            else
                current_Epto(i) = NaN;
                current_CWR(i) = NaN;
            end
        end
    end

    MergedTable.([genvarname(models(m).name) '_Energy']) = current_Epto;
    MergedTable.([genvarname(models(m).name) '_CWR']) = current_CWR;
end

%% 3. Plot 
figure('Name', 'Performance Comparison', 'Position', [100, 100, 1400, 600], 'Color', 'w');
t = tiledlayout(1, 3, 'TileSpacing', 'compact');

% Energy Box Plot ---
nexttile([1, 2]); hold on;

energyCols = contains(MergedTable.Properties.VariableNames, '_Energy');
energyMatrix = MergedTable{:, energyCols};
energyMatrix = double(energyMatrix);
numModels = size(energyMatrix, 2);

theoreticalMax = mean(MergedTable.TheoreticalMaxEnergy, 'omitnan') / 2;
% bar(1, theoreticalMax, 0.7, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
avgEnergies = mean(energyMatrix, 1, 'omitnan');

allAverages = [theoreticalMax, avgEnergies];

x_coords = 1: length(allAverages);

b = bar(1:(numModels+1), allAverages, 0.7);

b.FaceColor = 'flat';
b.CData(1,:) = [0.9 0.9 0.9];

colors = lines(numModels);
for i = 1:numModels
    b.CData(i+1, :) = colors(i, :);
end

for idx = 1:length(allAverages)
    val = allAverages(idx);
    p_exp = floor(log10(val));
    p_man = val / (10^p_exp);

    labelStr = sprintf("%.2f\\times 10^{%d}", p_man, p_exp);
    text(x_coords(idx), allAverages(idx), labelStr, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 20, ...
    'FontWeight', 'bold');
end

%practicalLimit = theoreticalMax * 0.5;
%line([0.6 1.4], [practicalLimit practicalLimit], 'Color', [1 0.4 0.4], 'LineWidth', 2, 'LineStyle', '--', 'DisplayName', 'Practical Limit (50%)');
%text(1, practicalLimit, '         50% Limit', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold', 'Color', [1 0.4 0.4]);

% for i = 1:numModels
%     boxchart(ones(size(energyMatrix, 1), 1) * (i + 1), energyMatrix(:, i), ...
%         'MarkerStyle', 'x', ...
%         'BoxFaceColor', colors(i, :), ...
%         'MarkerColor', colors(i, :));
% end

ylabel('Average Energy (J)');
ylim([0 7e+08])
% title('Average Energy Extraction Comparison');

set(gca, 'XTick', x_coords, 'XTickLabel', [{'Theoretical Max'}, {models.name}], 'FontSize', 20);
xtickangle(45);
grid on;

% CWR Box Plot 
nexttile; hold on;
cwrCols = contains(MergedTable.Properties.VariableNames, '_CWR');
cwrMatrix = double(MergedTable{:, cwrCols});
numModels = size(cwrMatrix, 2);

colors = lines(numModels);

for i = 1:numModels
    boxchart(ones(size(cwrMatrix, 1), 1) * i, cwrMatrix(:, i), ...
        'MarkerStyle', 'x', ...
        'BoxFaceColor', colors(i, :), ...
        'MarkerColor', colors(i, :));
end

% yline(50, '--', 'Practical Limit (50%)', 'Color', [1.0 0.4 0.4], 'LineWidth', 1.5);

set(gca, 'XTick', 1:numModels, 'XTickLabel', {models.name}, 'FontSize', 20);
ylabel('Capture Width Ratio (%)');
%title('CWR Performance Comparison');
grid on;

% sgtitle('Control Strategy Comparison: Fixed vs InstFreq vs RL');

%% Damping Plot
% waveIdx = 1;
% testDatasetDir = 'Test_waveDataset_Hs3p66_Tp9p7_NW200_JN1000_dt0p1';
% 
% figure('Name', sprintf('Damping Analysis - Wave %d', waveIdx), 'Color', 'w');
% 
% waveFileName = fullfile(testDatasetDir, sprintf("Wave_%d.mat", waveIdx));
% if exist(waveFileName, 'file')
%     waveData = load(waveFileName);
%     t_axis = waveData.w.t;
%     eta_val = waveData.w.eta;
% else
%     error('No Test Wave!: %s', waveFileName);
% end
% 
% yyaxis left
% plot(t_axis, eta_val, 'Color', [0.5 0.5 0.5 0.3], 'DisplayName', 'Wave Elevation (eta)');
% ylabel('Wave Elevation (m)');
% 
% yyaxis right
% hold on;
% 
% for m = 1:length(models)
%     resFileName = fullfile(models(m).dir, sprintf('Result_Wave_%d.mat', waveIdx));
% 
%     if exist(resFileName, 'file')
%         mRes = load(resFileName);
% 
%         d_val = [];
% 
%         if isfield(mRes, 'B_pto') && isstruct(mRes.B_pto)
%             d_val = mRes.B_pto.Data;
%         elseif isfield(mRes, 'TimeSeriesData') && iscell(mRes.TimeSeriesData)
%             d_val = mRes.TimeSeriesData{waveIdx}.damping;
%         else
%             continue;
%         end
% 
%         if ~isempty(d_val)
%             plot(t_axis(1:length(d_val)), d_val, 'LineWidth', 1.5, 'DisplayName', models(m).name);
%         end
%     else
%         fprintf("Warning: No result file %d in %s model\n", waveIdx, models(m).name);
%     end
% end
% 
% ylabel('Damping Coefficient (N\cdots/m)');
% legend('Location', 'northeast', 'FontSize', 9);
% grid on;
% title(sprintf('Wave %d: Damping Control Strategy Comparison', waveIdx));
% 
% xlim([t_axis(1), t_axis(end)]);
% xlabel('Time (s)');
