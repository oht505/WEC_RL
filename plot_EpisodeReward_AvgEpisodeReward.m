
experiments(1).name = 'PPO-LSTM';
experiments(1).folders = { ...
    'Training_Episode_EE_lstm_split20_Filter0p25_dt0p1_FineTuned_Seed1', ...
    'Training_Episode_EE_lstm_split20_Filter0p25_dt0p1_FineTuned_Seed42', ...
    'Training_Episode_EE_lstm_split20_Filter0p25_dt0p1_FineTuned_Seed777', ...
    'Training_Episode_EE_lstm_split20_Filter0p25_dt0p1_FineTuned_Seed3366', ...
    'Training_Episode_EE_lstm_split20_Filter0p25_dt0p1_FineTuned_Seed58899'
};
experiments(1).color = [0, 0, 1]; % Blue

% experiments(2).name = 'Linear';
% experiments(2).folders = { ...
%     'Training_Episode_linear_split20_dt0p1_Seed5', ...
%     'Training_Episode_linaer_split20_dt0p1_Seed10', ...
%     'Training_Episode_linear_split20_dt0p1_Seed2026'
% };
% experiments(2).color = [1, 0, 0]; % Red

targetEpisodes = 40000;

numExperiments = length(experiments);
allData = cell(numExperiments, 1);

p = gcp('nocreate');
if isempty(p)
    parpool;
end

%% Loop
fprintf('Start Data Collecting...\n');

for expIdx = 1:numExperiments
    currentModelName = experiments(expIdx).name;
    folderNames = experiments(expIdx).folders;
    numSeeds = length(folderNames);

    fprintf("Processing Model: %s (Total Seeds: %d)\n", currentModelName, numSeeds);
    allSeedRewards = zeros(targetEpisodes, numSeeds);
    
    parfor s = 1:numSeeds
        currentFolder = folderNames{s};
        seedRewardsLocal = zeros(targetEpisodes, 1);
        formatSpec = 'Episode_%05d.mat';
        
        for i = 1:targetEpisodes
            fileName = sprintf(formatSpec, i);
            filePath = fullfile(currentFolder, fileName);

            if exist(filePath, 'file')
                tmp = load(filePath, 'episodeData');
    
                try
                    stepRewards = tmp.episodeData.rl_reward{1,1}.Data;
                    seedRewardsLocal(i) = sum(stepRewards);
        
                catch ME
                    if i > 1
                        seedRewardsLocal(i) = seedRewardsLocal(i-1);
                    end
                end
            else
                if i > 1
                    seedRewardsLocal(i) = seedRewardsLocal(i-1);
                end
            end

            if mod(i, 4000) == 0
                fprintf("Seed %d: %d / %d Episodes Processed...\n", s, i, targetEpisodes);
            end
        end
        allSeedRewards(:, s) = seedRewardsLocal;
    end    
    allData{expIdx} = allSeedRewards;
    fprintf("Model %d Complete!\n", currentModelName);
end

save('Aggregated_Rewards_Multi.mat', 'allData', 'experiments', '-v7.3');
fprintf("All Data Collected & Saved!\n");

%% Plot
windowSize = 250; 
% floorWindowSize = 400;
figure('Name', 'Multi-Model RL Learning Curve', 'Position', [100, 100, 750, 450]);
hold on;
grid on;

x_episodes = (1:targetEpisodes)';
h_lines = gobjects(numExperiments, 1);
h_fills = gobjects(numExperiments, 1);
%h_minlines = gobjects(numExperiments, 1);

smoothedData = cell(numExperiments, 1);
for expIdx = 1:numExperiments
    smoothedData{expIdx} = movmean(allData{expIdx}, [windowSize-1, 0], 1);
end

if numExperiments == 2
    for expIdx = 1:2
        if expIdx == 1
            yyaxis left;
        else
            yyaxis right;
        end

        meanReward = mean(smoothedData{expIdx}, 2);
        stdReward = std(smoothedData{expIdx}, 0, 2);
        upperBound = meanReward + stdReward;
        lowerBound = meanReward - stdReward;

        %minEnvelope = movmin(meanReward, [floorWindowSize-1, 0]);

        xPatch = [x_episodes; flipud(x_episodes)];
        yPatch = [upperBound; flipud(lowerBound)];
        mainColor = experiments(expIdx).color;

        h_fills(expIdx) = fill(xPatch, yPatch, mainColor, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
        hold on;
        h_lines(expIdx) = plot(x_episodes, meanReward, 'Color', mainColor, 'LineWidth', 2.5);
        
        %h_minlines(expIdx) = plot(x_episodes, minEnvelope, '-', mainColor, 'LineWidth', 1.5);

        ylabel(sprintf('Reward (%s)', experiments(expIdx).name), 'FontSize', 11, 'FontWeight', 'bold');
        ax = gca;
        ax.YColor = mainColor;
    end
else    % 1 or 3~
    hold on;
    for expIdx = 1:numExperiments
        meanReward = mean(smoothedData{expIdx}, 2);
        stdReward = std(smoothedData{expIdx}, 0, 2);
        upperBound = meanReward + stdReward;
        lowerBound = meanReward - stdReward;

        %minEnvelope = movmin(meanReward, [floorWindowSize-1, 0]);
        
        xPatch = [x_episodes; flipud(x_episodes)];
        yPatch = [upperBound; flipud(lowerBound)];
        mainColor = experiments(expIdx).color;
    
        h_fills(expIdx) = fill(xPatch, yPatch, mainColor, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
        h_lines(expIdx) = plot(x_episodes, meanReward, 'Color', mainColor, 'LineWidth', 2.5);

        % h_minlines(expIdx) = plot(x_episodes, minEnvelope, '--', 'Color', 'red', 'LineWidth', 1.5);
    end
    ylabel('Reward', 'FontSize', 11, 'FontWeight', 'bold');
end

grid on;
xlabel('Episode', 'FontSize', 11, 'FontWeight', 'bold');
set(gca, 'Box', 'on', 'LineWidth', 1);

xlim([1, 10000]);

legend_objs = [];
legend_strs = {};
for expIdx = 1:numExperiments
  legend_objs = [legend_objs, h_lines(expIdx), h_fills(expIdx)];
  legend_strs{end+1} = sprintf("Mean Reward- %s", experiments(expIdx).name);
  legend_strs{end+1} = sprintf("Reward Interval- %s", experiments(expIdx).name);
  %legend_strs{end+1} = sprintf("Min Envelope- %s", experiments(expIdx).name);
end
legend(legend_objs, legend_strs, 'Location', 'southeast', 'FontSize', 10);

hold off;
fprintf('Plotting Done!\n');
