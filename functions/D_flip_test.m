% Test script to verify d_flip_flop_pfd function

% Parameters
fs = 1000;          % Sampling frequency (Hz)
t = 0:1/fs:1;       % Time vector (1 second of simulation)
f_ref = 5;          % Reference signal frequency (Hz)
f_vco = 5.5;        % VCO signal frequency (Hz) - initially out of phase

% Generate reference and feedback (VCO) signals
reference_signal = square(2 * pi * f_ref * t); % Square wave for reference signal
feedback_signal = square(2 * pi * f_vco * t);  % Square wave for VCO (feedback signal)

% Time step (assuming fixed sampling rate)
dt = 1/fs;

% Call the D-Flip-Flop Phase Frequency Detector function
[up_signal, down_signal] = D_flip(reference_signal, feedback_signal);


% Plot the signals for visualization
figure;
subplot(3,1,1);
plot(t, reference_signal, 'b', 'LineWidth', 1.5);
title('Reference Signal (5 Hz)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(3,1,2);
plot(t, feedback_signal, 'r', 'LineWidth', 1.5);
title('Feedback Signal (VCO Output) (5.5 Hz)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(3,1,3);
hold on
stem(t,up_signal,'Color','b')
stem(t,down_signal,'Color','r')
hold off
title('D-Flip-Flop PFD Output');
xlabel('Time Step');
ylabel('Data');
legend('Up Signal', 'Down Signal');
grid on;
