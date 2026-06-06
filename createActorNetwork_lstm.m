function [actor] = createActorNetwork_lstm(obsInfo, actInfo, fcUnits, lstmUnits)
% createActorNetwork: Create Actor Network and its object (LSTM version)

obsMin = obsInfo.LowerLimit;
obsMax = obsInfo.UpperLimit;

actMin = actInfo.LowerLimit(1);
actMax = actInfo.UpperLimit(1);

actionScale = (actMax - actMin) / 2;
actionBias = (actMax + actMin) / 2;

disp('[Function] Create Actor Neural Network...');

% Common Path
commonStatePath = [

    sequenceInputLayer(obsInfo.Dimension(1), 'Name', 'input_1', ...
        'Normalization','rescale-symmetric', ...
        'Min', obsMin, 'Max', obsMax)

    fullyConnectedLayer(fcUnits, 'Name', 'fc_1')
    reluLayer('Name', 'relu_body')

    lstmLayer(lstmUnits, 'Name', 'lstm_1', 'OutputMode', 'sequence')

    fullyConnectedLayer(fcUnits, 'Name', 'fc_body')
    reluLayer('Name', 'body_output')
];

% Mean
meanPath = [
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'fc_mean')
    tanhLayer('Name', 'tanh') % -1 ~ 1
    scalingLayer('Name', 'scale', 'Scale', actionScale, 'Bias', actionBias)
];

% Standard Deviation (Std)
stdPath = [
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'fc_std')
    softplusLayer('Name', 'std') % Always positive (> 0)
];

% Assemble NN
actorNetworkGraph = layerGraph(commonStatePath); 
actorNetworkGraph = addLayers(actorNetworkGraph, meanPath);
actorNetworkGraph = addLayers(actorNetworkGraph, stdPath);

% Connect all
actorNetworkGraph = connectLayers(actorNetworkGraph, 'body_output', 'fc_mean');
actorNetworkGraph = connectLayers(actorNetworkGraph, 'body_output', 'fc_std');

% Actor
actor = rlContinuousGaussianActor(actorNetworkGraph, obsInfo, actInfo, ...
    'ActionMeanOutputNames', {'scale'}, ...
    'ActionStandardDeviationOutputNames', {'std'});

end