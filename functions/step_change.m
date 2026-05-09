function [signal_noisy] = step_change(t,bump_start_time,bump_magnitude,signal)

% Create step bump noise
bump_start_index = find(t >= bump_start_time, 1);
bump_noise = zeros(size(t));
bump_noise(bump_start_index:end) = bump_magnitude;

% Add step bump noise to A
signal_noisy = signal + signal.*bump_noise;
