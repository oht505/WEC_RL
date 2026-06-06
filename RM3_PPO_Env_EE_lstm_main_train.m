%% Clean data
clear localResetFcn;
clear; 
clc;
close all;

% Seed Setup
if exist('exp_seed', 'var')
    rng(exp_seed);
else
    exp_seed = 123;
    rng(exp_seed);
end

%% ParPool safety
myCluster = parcluster('Processes');
delete(myCluster.Jobs);
delete(gcp('nocreate'));

%% Run Init file
run("RM3_PPO_init_EE_lstm.m");

%% Create Reinforcement Learning Environment
mdl = 'RM3_PPO_Env_EE_lstm_main';
agentBlk = [mdl, '/RL Agent'];

if ~bdIsLoaded(mdl)
    load_system(mdl);
end

set_param(mdl, 'SimulationMode', 'normal');
set_param(mdl, 'ReturnWorkspaceOutputs', 'off');
set_param(mdl, 'LoggingToFile', 'off')
set_param(mdl, 'SaveFinalState', 'on');
set_param(mdl, 'FinalStateName', 'FinalSimState');
set_param(mdl, 'SaveOperatingPoint', 'on');

% Observation   [x, x_dot, Fex1, Fex2, damp_prev, eta_hist]
N_hist = 1;
obsSize = 5 + (N_hist * 2);
obsDims = [obsSize 1];
obsInfo = rlNumericSpec(obsDims);

eta_hist_UpperLimit = ones(N_hist, 1) * 3.0;
eta_hist_LowerLimit = ones(N_hist, 1) * -3.0;

eta_filtered_hist_UpperLimit = ones(N_hist, 1) * 3.0;
eta_filtered_hist_LowerLimit = ones(N_hist, 1) * -3.0;

obsInfo.UpperLimit = [ 2.0;  2.0;  5e6;  5e6; 4.0;  eta_hist_UpperLimit; eta_filtered_hist_UpperLimit];    
obsInfo.LowerLimit = [-2.0; -2.0; -5e6; -5e6; 0.0;  eta_hist_LowerLimit; eta_filtered_hist_LowerLimit];  

obsInfo.Name = "observations";
obsInfo.Description = "x12, v12, Fex1, Fex2, damp_prev, curr_eta, curr_filtered_eta";

% Action: [damp]
actDims = [1 1];
actInfo = rlNumericSpec(actDims);
actInfo.UpperLimit = 4.0;
actInfo.LowerLimit = 0.0;

initDamping = 0;
assignin('base', 'initDamping', initDamping);

initDSS = zeros(1, 10);
assignin('base', 'initDSS', initDSS);

init_state_vec = zeros(307, 1);
assignin('base', 'init_state_vec', init_state_vec);

% Dataset Setting
datasetFolder = 'Train_split20s_waveDataset_Hs3p66_Tp9p7_NW800_JN1000';

fullDatasetPath = fullfile(pwd, datasetFolder);
if ~exist(datasetFolder, 'dir')
    error("No folder: %s", datasetFolder);
end
addpath(fullDatasetPath);

files_all = dir(fullfile(datasetFolder, "Wave_*.mat"));
total_episodes = length(files_all);

files_base = dir(fullfile(datasetFolder, "Wave_*_part_1.mat"));
Num_waves = length(files_base);
 
num_parts_per_wave = total_episodes / Num_waves;

% Load or Save the order of Wave data for training
orderFileName = sprintf('WaveOrder_Seed%d.mat', exp_seed);
orderFilePath = fullfile(datasetFolder, orderFileName);
if exist(orderFilePath, 'file')
    load(orderFilePath, 'waveOrder');
else
    waveOrder = randperm(Num_waves);
    save(orderFilePath, 'waveOrder');
end

%% Parallelization Options
slurms_cpus = getenv('SLURM_CPUS_PER_TASK');
if isempty(slurms_cpus)
    numWorkers = 5;
else
    numWorkers = str2double(slurms_cpus);
end

if isempty(gcp('nocreate'))
    pool = parpool('Processes', numWorkers);
end 
addAttachedFiles(pool, {'RM3_PPO_init_EE_lstm.m'});
pctRunOnAll(['addpath(''', fullDatasetPath,''')']);
pctRunOnAll('run("RM3_PPO_init_EE_lstm.m")');
pctRunOnAll('clear localResetFcn'); % Empty all workers' memory remained
pctRunOnAll('initDamping = 0;');
pctRunOnAll('initDSS = zeros(1, 10);');
pctRunOnAll('init_state_vec = zeros(307, 1);');
pctRunOnAll('FinalSimState = [];');

% Setup to use Logging Data while training
tag = sprintf("_Seed%d", exp_seed);
basePath = fileparts(mfilename('fullpath'));
folderName = "Training_Episode_EE_lstm_split20_Filter0p25_Best" + tag;
logDir = fullfile(basePath, folderName);

% Create Simulink model as RL Environment
env = rlSimulinkEnv(mdl, agentBlk, obsInfo, actInfo,'UseFastRestart','off');
env.ResetFcn = @(in) localResetFcn(in, datasetFolder, Num_waves, waveOrder, numWorkers, logDir);

%% Create the PPO Agent
fcUnits = 128;
lstmUnits = 256;
critic = createCriticNetwork_lstm(obsInfo, fcUnits, lstmUnits);
actor = createActorNetwork_lstm(obsInfo, actInfo, fcUnits, lstmUnits);
agent = rlPPOAgent(actor, critic);

agent.AgentOptions.ExperienceHorizon = 400;
agent.AgentOptions.LearningFrequency = 400;
agent.AgentOptions.MiniBatchSize = 100;
agent.AgentOptions.DiscountFactor = 0.99;
agent.AgentOptions.NumEpoch = 5;

if exist('entropyLossWeight', 'var')
    agent.AgentOptions.EntropyLossWeight = entropyLossWeight;
else
    agent.AgentOptions.EntropyLossWeight = 0.001;
end

agent.AgentOptions.ActorOptimizerOptions.LearnRate  = 1e-3;
agent.AgentOptions.ActorOptimizerOptions.GradientThreshold = 5;
agent.AgentOptions.CriticOptimizerOptions.LearnRate = 1e-3;
agent.AgentOptions.CriticOptimizerOptions.GradientThreshold = 5;
agent.AgentOptions.SampleTime = 0.1;

%% Configure Training Options
saveDir = "TrainedAgents_EE_lstm_split20_Filter0p25_Best" + tag;

trainOpts = rlTrainingOptions;

% Training Parameters
if exist('total_episodes', 'var')
    trainOpts.MaxEpisodes = total_episodes;
else
    trainOpts.MaxEpisodes = 200;
end
trainOpts.MaxStepsPerEpisode = duration / dt;
trainOpts.StopTrainingCriteria = "AverageReward";
trainOpts.StopTrainingValue = inf;  
trainOpts.ScoreAveragingWindowLength = 100;
trainOpts.SaveAgentDirectory = saveDir;
trainOpts.SaveAgentCriteria = "EpisodeFrequency";
trainOpts.SaveAgentValue = 100;
% trainOpts.Plots = "training-progress";
trainOpts.Plots = "none";
trainOpts.Verbose = true;
trainOpts.UseParallel = true;
trainOpts.ParallelizationOptions.Mode = 'sync';


% Check Train Options
%disp(trainOpts);

%% Data Logger Setting
logger = rlDataLogger();
logger.LoggingOptions.LoggingDirectory = logDir;
logger.LoggingOptions.FileNameRule = "Episode_<id>";
logger.EpisodeFinishedFcn = @myEpisodeFinishedFcn;

%% Save Change
if bdIsLoaded(mdl)
    save_system(mdl);
end

%% Run Training
fprintf("Start Training... \n");
trainStats = train(agent, env, trainOpts, Logger=logger);
fprintf("End Training... \n");

%% Local Reset Function
function in = localResetFcn(in, waveFolder, numWaves, waveOrder, numWorkers, trainingDataFolder)
    
    t = getCurrentTask();
    workerID = 1;
    if ~isempty(t)
        workerID = t.ID;
    end
    
    persistent currentPtr currentPart globalPartCount;
    
    if isempty(currentPtr)
        currentPtr = workerID;
        currentPart = 1;
        globalPartCount = 0;
    end
    
    actualIdx = mod(currentPtr - 1, numWaves) + 1;
    realFileIdx = waveOrder(actualIdx);
    waveFileName = fullfile(waveFolder, sprintf('Wave_%d_part_%d.mat', realFileIdx, currentPart));
    
    data = load(waveFileName);
    w = data.w;
    maxSplit = w.total_parts;
     
    Fex_ts = [timeseries(w.Fex1(:), w.t(:)), timeseries(w.Fex2(:), w.t(:))];
    Fex_ts(1).Name = 'Body 1 Excitation Force';
    Fex_ts(2).Name = 'Body 2 Excitation Force';
    
    eta_ts = [timeseries(w.eta(:), w.t(:))];
    eta_ts.Name = 'Wave Elevation';
    
    in = setVariable(in, 'Fex', Fex_ts);
    in = setVariable(in, 'Eta', eta_ts);
    in = setVariable(in, 'Tp', w.Tp);

    fs = 10;
    N_cycle = 1;
    buffer_size_eta = round(round(w.Tp) * fs);
    buffer_size_pto = round(20 * N_cycle * fs);
    num_scalars = 7;

    total_vec_size = buffer_size_eta + buffer_size_pto + num_scalars;
    vec_size = 307;
    
    % Handling parts of Wave Base  
    if currentPart == 1
        in = setVariable(in, 'initDamping', 0);
        in = setVariable(in, 'initDSS', zeros(1, 10));
        in = setVariable(in, 'x12', 0);
        in = setVariable(in, 'v12', 0);

        is_first_part = 1;
        in = setVariable(in, 'is_first_part', is_first_part);
        in = setVariable(in, 'init_state_vec', zeros(vec_size, 1));
    else
        is_first_part = 0;
        foundMyData = false;
        estimatedIdx = (globalPartCount * numWorkers) + 100;
        searchLimit = 1000;

        for idx = estimatedIdx : -1 : max(1, estimatedIdx - searchLimit)

            targetFilePath = '';
            targetFileName = '';

            for pad = length(num2str(numWaves)) : 6
                formatSpec = sprintf("Episode_%%0%dd.mat", pad);
                tempFileName = sprintf(formatSpec, idx);
                tempFilePath = fullfile(trainingDataFolder, tempFileName);

                if exist(tempFilePath, 'file')
                    targetFilePath = tempFilePath;
                    targetFileName = tempFileName;
                    break;
                end
            end

            if ~isempty(targetFilePath)
                try
                    m = matfile(targetFilePath);
                    savedID = m.episodeData;
                    savedID = savedID.logged_worker_id;
                    if iscell(savedID), savedID = savedID{1}; end
    
                    if savedID == workerID
                        loadedData = load(targetFilePath);
                        epData = loadedData.episodeData;

                        obs_data = epData.rl_obs{1,1}.Data;
                        last_x = obs_data(end, 1);
                        last_v = obs_data(end, 2);
                        last_damp = obs_data(end, 5);
    
                        in = setVariable(in, 'x12', last_x);
                        in = setVariable(in, 'v12', last_v);
                        in = setVariable(in, 'initDamping', last_damp);
                        in = setVariable(in, 'is_first_part', is_first_part);
                       
                        raw_state = epData.out_state_vec;
                        if iscell(raw_state) && ~isempty(raw_state)
                            raw_state = raw_state{1};
                        end

                        if isstruct(raw_state) && isfield(raw_state, 'Data')
                            raw_state = raw_state.Data;
                        elseif isa(raw_state, 'timeseries')
                            raw_state = raw_state.Data;
                        end

                        last_state_vec = double(raw_state(:));
                        in = setVariable(in, 'init_state_vec', last_state_vec);
    
                        dstate_obj = epData.FinalSimState{1,1}.loggedStates{1};
                        dss_value = dstate_obj.Values.Data;
                        in = setVariable(in, 'initDSS', dss_value);

                        foundMyData = true;
                        break; 
                    end
                catch ME
                    error("[Worker %d] Failed to read file (%s): %s", workerID, targetFileName, ME.message);
                    continue;
                end
            end
        end
    
        if ~foundMyData
            % warning("[Worker %d] FATAL: Could not find matching state in files!", workerID);
            error("Failed to find file");
        end
    end
    
    globalPartCount = globalPartCount + 1;

    % Update for the next part
    if currentPart < maxSplit
        currentPart = currentPart + 1;
    else
        currentPart = 1;
        currentPtr = currentPtr + numWorkers;
        if currentPtr > numWaves
            currentPtr = mod(currentPtr - 1, numWaves) + 1;
        end
    end
end


%% My Logger Function
function dataToLog = myEpisodeFinishedFcn(data)
    if ~isempty(data.SimulationInfo)
        if iscell(data.SimulationInfo)
            simOut = data.SimulationInfo{1};
        else
            simOut = data.SimulationInfo;
        end
    
        dataToLog =struct();
        varNames = simOut.who;
    
        for i = 1:length(varNames)
            varName = varNames{i};
            varValue = simOut.get(varName);

            % Unwrap cell 
            if iscell(varValue) && ~isempty(varValue)
                varValue = varValue{1};
            end
    
            if isa(varValue, 'timeseries')
                dataToLog.(varName).Data = squeeze(varValue.Data); % Store the timeseries data in the log
    
            elseif isstruct(varValue) && isfield(varValue, 'Data')
                dataToLog.(varName).Data = squeeze(varValue.Data); % Store the data directly if it's not a timeseries
    
            elseif isnumeric(varValue)
                dataToLog.(varName).Data = squeeze(varValue); % Store the variable directly if it's numeric
            
            else
                dataToLog.(varName) = varValue;
            end
        end

        if ismember('WorkerID_Log', varNames)
            id_data = simOut.get('WorkerID_Log');

            if isa(id_data, 'timeseries')
                dataToLog.logged_worker_id = id_data.Data(end);
            elseif isstruct(id_data) && isfield(id_data, 'Data')
                dataToLog.logged_worker_id = id_data.Data(end);
            end
        else
            dataToLog.logged_worker_id = 1;
        end
    else
        warning('No data');
        dataToLog = struct();
    end

end


%% GraveYard

% Create Critic Network
% critic = createCriticNetwork(obsInfo);
% fprintf("Critic Neural Network is created...\n");
% 
% % Create Actor Network 
% actor = createActorNetwork(obsInfo, actInfo);
% fprintf("Actor Neural Network is created...\n");
% 
% % Create PPO Agent
% agentOptions = rlPPOAgentOptions;
% agentOptions.ClipFactor = 0.2;
% %agentOptions.EntropyLossWeight = 0.03;
% agentOptions.EntropyLossWeight = 0.07;
% agentOptions.ActorOptimizerOptions.LearnRate = 1e-5;
% agentOptions.CriticOptimizerOptions.LearnRate = 1e-5;
% agentOptions.ActorOptimizerOptions.GradientThreshold = 1;
% agentOptions.CriticOptimizerOptions.GradientThreshold = 1;
% agentOptions.ExperienceHorizon = 256;
% agentOptions.LearningFrequency = 256;
% 
% disp(agentOptions.ActorOptimizerOptions);
% 
% agent = rlPPOAgent(actor, critic, agentOptions);

%fprintf("PPO Agent is ready! \n");

%% Save model (for standalone)
% folderName = "Saved_Agents";
% if ~exist(folderName, 'dir')
%     mkdir(folderName);
% end
% 
% if exist('entropyLossWeight', 'var') && exist('exp_seed', 'var')
%     fileTag = sprintf('_ELW%.4f_Seed%d', entropyLossWeight, exp_seed);
% else
%     fileTag = "_Standalone_" + string(datetime("now", 'Format', 'yyyy_MM_dd_HH_mm_ss'));
% end
% 
% fullPath = fullfile(folderName, "Trained_PPO_Agent" + fileTag + ".mat");
% save(fullPath, 'trainStats', "env", "agent", '-v7.3');
% fprintf("Save Successfully! Folder Name: %s\n", folderName);
