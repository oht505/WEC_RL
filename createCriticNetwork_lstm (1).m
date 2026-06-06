function [critic] = createCriticNetwork_lstm(obsInfo, fcUnits, lstmUnits)
% createCriticNetwork: Create Critic Network and its Object (LSTM version)

disp('[Function] Create Critic Neural Network (LSTM)... ');

obsMin = obsInfo.LowerLimit;
obsMax = obsInfo.UpperLimit;

% Input Layer & Body
criticStatePath = [

    sequenceInputLayer(obsInfo.Dimension(1), 'Name', 'input_1', ...
        'Normalization', 'rescale-symmetric', ...
        'Min', obsMin, 'Max', obsMax)

    fullyConnectedLayer(fcUnits, 'Name', 'fc_1')
    reluLayer('Name', 'relu_body')

    lstmLayer(lstmUnits, 'Name', 'lstm_1', 'OutputMode', 'sequence')

    fullyConnectedLayer(fcUnits, 'Name', 'fc_body')
    reluLayer('Name', 'body_output')

    fullyConnectedLayer(1, 'Name', 'output')
];

% Assemble NN
criticNetwork = layerGraph(criticStatePath);

% Generate critic object by using 'rlValueRepresentation'
critic = rlValueRepresentation(criticNetwork, obsInfo, 'Observation', {'input_1'});

end