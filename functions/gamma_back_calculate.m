addpath("functions/")
% Load your eta data and time vector
% Assuming eta is your data vector and t is your time vector
Fex_ts=load("rm3excitationforces_H2p4T9p0_0p1_seed1.mat");
Fex = Fex_ts.Fex_RM3_H2p4T9p0_0p1_seed1;
t=Fex_ts.eta_RM3_H2p4T9p0_0p1_seed1.Time;
dt = round(t(2)-t(1),1);
% Fex_ts.Fex_2 = Fex_ts.Fex_RM3_H2p4T9p0_0p1_seed1.data;
eta= Fex_ts.eta_RM3_H2p4T9p0_0p1_seed1.data;

% Assuming 'eta' is your surface elevation data and 't' is the corresponding time vector

% Detrend the data to remove any linear trend
eta_detrended = detrend(eta);

% Find zero-crossings
zero_crossings = find(eta_detrended(1:end-1) .* eta_detrended(2:end) < 0);

% Initialize wave heights array
wave_heights = [];

% Loop through zero-crossings to calculate wave heights
for i = 1:length(zero_crossings)-1
    segment = eta_detrended(zero_crossings(i):zero_crossings(i+1));
    wave_height = max(segment) - min(segment);
    wave_heights = [wave_heights; wave_height];
end

% Sort wave heights in descending order
wave_heights_sorted = sort(wave_heights, 'descend');

% Calculate the number of waves to consider (top one-third)
num_top_waves = round(length(wave_heights_sorted) / 3);

% Compute significant wave height (Hs)
Hs = mean(wave_heights_sorted(1:num_top_waves));

% Display the result
fprintf('Significant Wave Height (Hs): %.2f meters\n', Hs);

