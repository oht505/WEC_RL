%% Compare Multiple Models
disp('--- Compare Best Agents Across Models ---');

baseDir = 'Validation_Results';
searchPattern = 'linearScale_hist10_split*';

modelItems = dir(fullfile(baseDir, searchPattern));
modelFolders = modelItems([modelItems.isdir]);

if isempty(modelFolders)
    error('No folder: %s', searchPattern);
end

numModels = length(modelFolders);
fprintf('Compare %d folders\n', numModels);

figure('Name', 'RL Agent Comparison (Best Models)', 'Position', [100, 100, 1400, 900]);
colorPalette = lines(numModels); 

for i = 1:numModels
    currentModelDir = modelFolders(i).name;
    fullModelPath = fullfile(baseDir, currentModelDir);

    splitToken = regexp(currentModelDir, 'split(\d+)', 'tokens');
    if ~isempty(splitToken)
        legendName = sprintf('Split %s', splitToken{1}{1});
    else
        legendName = strrep(currentModelDir, '_', '\_'); 
    end
    
    summaryPath = fullfile(fullModelPath, 'Final_Validation_Summary.mat');
    if exist(summaryPath, 'file')
        summaryData = load(summaryPath);
        episodes = [summaryData.agentPerformanceList.Episode];
        avgEnergy = [summaryData.agentPerformanceList.AvgEnergy];
        
        subplot(2, 2, 1);
        hold on;
        plot(episodes, avgEnergy, '-o', 'Color', colorPalette(i,:), ...
            'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', legendName);
    end
    
    bestPattern = fullfile(fullModelPath, '*_best*');
    bestItems = dir(bestPattern);
    bestFolders = bestItems([bestItems.isdir]);
    
    if isempty(bestFolders)
        fprintf('⚠️ [%s] Cannot find Best model\n', currentModelDir);
        continue;
    end
    
    bestAgentDir = bestFolders(1).name;
    bestDataPath = fullfile(fullModelPath, bestAgentDir, 'Result_Wave_1.mat');
    
    if exist(bestDataPath, 'file')
        saveData = load(bestDataPath);
        
        B_pto = saveData.B_pto;
        P_pto = saveData.Ppto;
        E_pto = saveData.Epto;
        
        num_samples = length(B_pto);
        time = linspace(0, 1200, num_samples); 
        
        subplot(2, 2, 2);
        hold on;
        plot(time, E_pto, '-', 'Color', colorPalette(i,:), ...
            'LineWidth', 1.5, 'DisplayName', legendName);
        
        subplot(2, 2, 3);
        hold on;
        plot(time, P_pto, '-', 'Color', colorPalette(i,:), ...
            'LineWidth', 1.2, 'DisplayName', legendName);
            
        subplot(2, 2, 4);
        hold on;
        stairs(time, B_pto, '-', 'Color', colorPalette(i,:), ...
            'LineWidth', 1.2, 'DisplayName', legendName);
    end
end


subplot(2, 2, 1);
grid on;
title('Validation Performance (Avg Extracted Energy)');
xlabel('Saved Episode Agent');
ylabel('Avg Extracted Energy (J)');
legend('show', 'Location', 'best');

subplot(2, 2, 2);
grid on;
title('Cumulative Energy E_{pto}');
xlabel('Time (s)');
ylabel('Energy (J)');
legend('show', 'Location', 'best');

subplot(2, 2, 3);
grid on;
title('Instantaneous Power P_{pto}');
xlabel('Time (s)');
ylabel('Power (W)');
% legend('show', 'Location', 'best'); 

subplot(2, 2, 4);
grid on;
title('Control Input B_{pto}');
xlabel('Time (s)');
ylabel('Damping (Ns/m)');

sgtitle('Comparison of Best RL Agents Across Different Data Split Sizes', ...
    'FontSize', 16, 'FontWeight', 'bold');
disp('--- Plot Completed ---');