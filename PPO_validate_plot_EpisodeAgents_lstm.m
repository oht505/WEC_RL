clear; clc; close all;

%% For Prarllel Computing

delete(gcp('nocreate'));
slurm_cpus = getenv('SLURM_CPUS_PER_TASK');
if ~isempty(slurm_cpus)
    numWorkers = str2double(slurm_cpus);
else
    numWorkers = 5;
end
parpool('Processes', numWorkers);

%% Load Folder Setting
run('PPO_init_revised.m');
modelName = 'EE_lstm_split20_Filter0p25_dt0p1_Best_Seed2026';
agentFolder = sprintf("TrainedAgents_%s", modelName); 
envName = 'EE_lstm_main';
currentEnv = sprintf("RM3_PPO_Env_%s", envName);
waveFolder = "Test_waveDataset_Hs3p66_Tp9p7_NW200_JN1000_dt0p1";
resultDir = fullfile('Validation_Results', modelName);
if ~exist(resultDir, 'dir'), mkdir(resultDir); end

N_hist = 1;

load('rm3_ss_0p1.mat');

% episodes = 50:50:3500; 
episodes = 100:100:45200;
% episodes = 600:600:45000;
% episodes = 200:200:1600; % 600s
% episodes = 100:100:1600; % 600s
% episodes = 200:200:2400; % 400s
% episodes = 100:100:2400;
% episodes = 200:200:3200; % 300s
% episodes = 200:200:4800; % 200s
% episodes = 100:100:4800; 
% episodes = 200:200:9600; % 100s
% episodes = 200:200:19200; % 50s
% episodes = 800:800:46400; % 20s

numWavesPhase1 = 10;
numWavesPhase2 = 200;
topAgentRatio = 0.1;

%% Pre-building
load_system(currentEnv);
set_param(currentEnv, 'SimulationMode', 'normal');

%% Quick Test

phase1AvgEnergy = zeros(length(episodes), 1);

for i = 1:length(episodes)
    ep = episodes(i);
    agentFile = fullfile(agentFolder, sprintf("Agent%d.mat", ep));
    data = load(agentFile);
    current_agent = data.saved_agent;
    current_agent.UseExplorationPolicy = false;

    simInArray(numWavesPhase1) = Simulink.SimulationInput(currentEnv);

    for waveIdx = 1:numWavesPhase1
        waveFile = fullfile(waveFolder, sprintf("Wave_%d.mat", waveIdx));
        w_data = load(waveFile);
        w = w_data.w;

        fex_temp = [timeseries(w.Fex1, w.t); timeseries(w.Fex2, w.t)];
        eta_temp = timeseries(w.eta, w.t);

        simIn = Simulink.SimulationInput(currentEnv);
        simIn = simIn.setModelParameter('StartTime', '0');
        totalTime = num2str(w.t(end));
        simIn = simIn.setModelParameter('StopTime', totalTime);

        simIn = simIn.setVariable('agent', current_agent);
        simIn = simIn.setVariable('Fex', fex_temp);
        simIn = simIn.setVariable('Eta', eta_temp);
        simIn = simIn.setVariable('rm3_ss_0p1', rm3_ss_0p1);
        simIn = simIn.setVariable('initDSS', zeros(1, 10));
        simIn = simIn.setVariable('initDamping', 0);
        simIn = simIn.setVariable('init_state_vec', zeros(307, 1));
        simIn = simIn.setVariable('is_first_part', 1);
        % simIn = simIn.setVariable('init_eta_hist', zeros(1, N_hist));
        % simIn = simIn.setVariable('init_eta_filt_hist', zeros(1, N_hist));
        simIn = simIn.setVariable('duration', double(w.t(end)));
        simIn = simIn.setModelParameter('SimulationMode', 'normal');

        simInArray(waveIdx) = simIn;
    end

    fprintf('\n Running Phase 1 for Agent %d...\n', ep);
    simOutArray = parsim(simInArray);

    tempEnergy = zeros(numWavesPhase1, 1);
    for waveIdx = 1:numWavesPhase1
        simOut = simOutArray(waveIdx);
        if ~isempty(simOut.ErrorMessage)
            tempEnergy(waveIdx) = NaN;
        else
            tempEnergy(waveIdx) = simOut.Epto.Data(end);
        end
    end

    phase1AvgEnergy(i) = mean(tempEnergy(~isnan(tempEnergy)));
    fprintf("Avg Energy: %.2f J \n", phase1AvgEnergy(i));
end

%% Top Selection 
numTopAgents = max(1, round(length(episodes) * topAgentRatio));
[sortedEnergy, sortIdx] = sort(phase1AvgEnergy, 'descend');
topEpisodes = episodes(sortIdx(1:numTopAgents));

%% Full Validation Loop
avgEnergyExtraction = zeros(length(topEpisodes), 1);
stdEnergyExtraction = zeros(length(topEpisodes), 1);
agentPerformanceList = struct('Episode', {}, 'AvgEnergy', {}, 'StdEnergy', {});

disp('--- Evaluating Agents ---');

for i = 1:length(topEpisodes)
    ep = topEpisodes(i);
    agentFile = fullfile(agentFolder, sprintf("Agent%d.mat", ep));
    data = load(agentFile);
    current_agent = data.saved_agent;
    current_agent.UseExplorationPolicy = false;
    
    ep_save_folder = fullfile(resultDir, sprintf("Agent%d", ep));
    if ~exist(ep_save_folder, 'dir'), mkdir(ep_save_folder); end

    totalEnergyForAgent = zeros(numWavesPhase2, 1);
    clear simInArray;
    simInArray(numWavesPhase2) = Simulink.SimulationInput(currentEnv);

    for waveIdx = 1:numWavesPhase2
        waveFile = fullfile(waveFolder, sprintf("Wave_%d.mat", waveIdx));
        w_data = load(waveFile);
        w = w_data.w;

        fex_temp = [timeseries(w.Fex1, w.t); timeseries(w.Fex2, w.t)];
        eta_temp = timeseries(w.eta, w.t);

        simIn = Simulink.SimulationInput(currentEnv);
        simIn = simIn.setModelParameter('StartTime', '0');
        totalTime = num2str(w.t(end));
        simIn = simIn.setModelParameter('StopTime', totalTime);

        simIn = simIn.setVariable('agent', current_agent);
        simIn = simIn.setVariable('Fex', fex_temp);
        simIn = simIn.setVariable('Eta', eta_temp);
        simIn = simIn.setVariable('rm3_ss_0p1', rm3_ss_0p1);
        simIn = simIn.setVariable('initDSS', zeros(1, 10));
        simIn = simIn.setVariable('initDamping', 0);
        simIn = simIn.setVariable('init_state_vec', zeros(307, 1));
        simIn = simIn.setVariable('is_first_part', 1);
        % simIn = simIn.setVariable('init_eta_hist', zeros(1, N_hist));
        % simIn = simIn.setVariable('init_eta_filt_hist', zeros(1, N_hist));
        simIn = simIn.setVariable('duration', double(w.t(end)));
        simIn = simIn.setModelParameter('SimulationMode', 'normal');

        simInArray(waveIdx) = simIn;
    end

    fprintf('\n Running parsim for Agent %d...\n', ep);
    simOutArray = parsim(simInArray);

    for waveIdx = 1:numWavesPhase2
        simOut = simOutArray(waveIdx);

        if ~isempty(simOut.ErrorMessage)
            fprintf("Agent %d - Wave %d Failed: %s\n", ep, waveIdx, simOut.ErrorMessage);
            totalEnergyForAgent(waveIdx) = NaN;
            continue;
        end

        saveData = struct();
        saveData.AgentName = sprintf("Agent%d_Wave%d.mat",ep, waveIdx);
        saveData.WaveIdx = waveIdx;
        saveData.rl_obs = squeeze(simOut.rl_obs.Data);
        saveData.rl_reward = squeeze(simOut.rl_reward.Data);
        saveData.B_pto = squeeze(simOut.B_pto.Data);
        saveData.Fpto = squeeze(simOut.Fpto.Data);        
        saveData.Ppto = squeeze(simOut.Ppto.Data);
        saveData.Epto = squeeze(simOut.Epto.Data);
        
        final_Epto = saveData.Epto(end); 
        totalEnergyForAgent(waveIdx) = squeeze(final_Epto);

        savePath = fullfile(ep_save_folder, sprintf("Result_Wave_%d.mat", waveIdx));
        save(savePath, '-fromstruct', saveData);
    end

    validEnergy = totalEnergyForAgent(~isnan(totalEnergyForAgent));
    avgEnergy = mean(validEnergy);
    stdEnergy = std(validEnergy);

    avgEnergyExtraction(i) = avgEnergy;
    stdEnergyExtraction(i) = stdEnergy;

    agentPerformanceList(i).Episode = ep;
    agentPerformanceList(i).AvgEnergy = avgEnergy;
    agentPerformanceList(i).StdEnergy = stdEnergy;

    fprintf("Phase 2 | Episode %d Agent | Avg Energy: %.2f J | Std Energy: %.2f J\n", ep, avgEnergy, stdEnergy);
end

[maxEnergy, bestIdx] = max(avgEnergyExtraction);
bestEpisode = topEpisodes(bestIdx);
fprintf("\n Best Agent: Episode %d (Avg Energy: %.2f J, Std: %.2f J)\n", ...
    bestEpisode, maxEnergy, stdEnergyExtraction(bestIdx));

bestAgentSummary = struct();
bestAgentSummary.Episode = bestEpisode;
bestAgentSummary.AvgEnergy = maxEnergy;
bestAgentSummary.StdEnergy = stdEnergyExtraction(bestIdx);

finalSavePath = fullfile(resultDir, 'Final_Validation_Summary.mat');
save(finalSavePath, 'agentPerformanceList', 'bestAgentSummary', '-v7.3');
