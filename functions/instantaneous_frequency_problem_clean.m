%% Instantaneous frequency experiments

% * v(t) = A(t)*sin(chi(t))
% * dchi(t) = wbar + deps(t)    [instantaneous frequency, rad/s]
% * chi(t) = wbar t + eps(t)    [total phase, rad]
% * eps(t) is the (relative) phase

clear
close all

duration=400; % simulation time
scale=1; % figure scaling factor
t = linspace(0,duration,duration*100)';
dt=t(2)-t(1); % timestep

%%% Wave time series generation (JOSWAP Spectrum)
gamma = 5; %% Narrowness of spectrum
fp = 1/10; %% Peak Frequency
H_s = 2; %% Significant wave height = (m)
[S_f, S_w] = JONSWAP(gamma,fp,H_s);
eta_real= psd2eta(S_w,fp,t);

A = 1 + 0.1*sin(2*pi/40*t); % eta envelope modulation
epsilon = 0.9*sin(2*pi/25*t);     % phase modulation;
wbar = 2*pi/fp;             % base frequency
chi = wbar*t + epsilon;         % total angle
w = gradient(chi,t);        % instantaneous frequency
eta = [t A.*sin(chi)];

% customPlot(t,eta(:,2),1.5)
% legend('Case1')
% ylabel('Water Elevation (m)')
% 
% %%% adding noise to A
% A_noisy = 1*(t<200) + 0.7*(t>=200);
% eta_A_noisy = [t A_noisy.*sin(chi)];
% 
% customPlot(t,eta_A_noisy(:,2),1.5)
% legend('Case2')
% ylabel('Water Elevation (m)')
% 
% %%% adding noise to frequency
% eta_no_eps = A.*sin(chi-epsilon);
% wbar_noisy = wbar*(t<200)+1.5*wbar*(t>=200);
% chi_noisy = cumtrapz(t,wbar_noisy);
% eta_f_noisy = [t A.*sin(chi_noisy)];
% w_f_noisy = gradient(chi_noisy,t);
% 
% customPlot(t,eta_f_noisy(:,2),1.5)
% legend('Case3')
% ylabel('Water Elevation (m)')


%%% Instantaneous value calculation parameters
window_size = round(10*2*pi/wbar/dt); % real time calulation window
% delay_time = 0.1; % seconds
% df = 1 - (delay_time/dt/window_size); % determine the delay factor from delay time.
% filter_size = round(2*pi/wbar*0.5/dt); % moving filter size
median_window_seconds=round(0.04*window_size*dt);

%% Original eta
median_window=0.04*window_size;
instantaneous_values_original=median_inst_f(t,eta(:,2),window_size,median_window);

% fixing spike at the boundary.
instantaneous_values_original.inst_freq(5000)=instantaneous_values_original.inst_freq(4999);

% customPlot(t,w/2/pi,1.5,instantaneous_values_original.inst_freq)
% ylabel('Instantaneous Frequency (Hz)');
% legend('True Value','Estimate Value');
% xlim([100,400])

%% Modified Amplitude case
median_window=0.04*window_size;
instantaneous_values_A_case=median_inst_f(t,eta_A_noisy(:,2),window_size,median_window);
% fixing spike at the boundary.
instantaneous_values_A_case.inst_freq(5000)=instantaneous_values_A_case.inst_freq(4999);

% customPlot(t,w/2/pi,1.5,instantaneous_values_A_case.inst_freq)
% ylabel('Instantaneous Frequency (Hz)');
% legend('True Value','Estimate Value');
% xlim([100,400])

% customPlot(t,eta_A_noisy,1.5,instantaneous_values_A_case.mag)
% hold on
% plot(t,-instantaneous_values_A_case.mag,'LineWidth',2,'LineStyle','--')
% hold off
% ylabel('Amplitude (m)');
% legend('True Value','Estimate Value');
% xlim([100,400])

%% Modified frequency case
median_window=0.08*window_size;
instantaneous_values_f_case=median_inst_f(t,eta_f_noisy(:,2),window_size,median_window);
% fixing spike at the boundary.
instantaneous_values_f_case.inst_freq(5000)=instantaneous_values_f_case.inst_freq(4999);

% customPlot(t,w_f_noisy/2/pi,1.5,instantaneous_values_f_case.inst_freq)
% ylabel('Instantaneous Frequency (Hz)');
% legend('True Value','Estimate Value');
% xlim([100,400])

%% real_eta Case
median_window=0.04*window_size;

instantaneous_values_real=median_inst_f(t,eta_real.eta',window_size,median_window);
% fixing spike at the boundary.
% instantaneous_values_A_case.inst_freq(5000)=instantaneous_values_A_case.inst_freq(4999);
cheat_f=cheat_inst_f(t,eta_real',window_size);
customPlot(t,instantaneous_values_real.inst_freq,1.5)
ylabel('Instantaneous Frequency (Hz)');
% legend('True Value','Estimate Value');
xlim([0,400])
plot(t,cheat_f.inst_freq)
