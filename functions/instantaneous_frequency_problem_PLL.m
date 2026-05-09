%% Instantaneous frequency experiments

% * v(t) = A(t)*sin(chi(t))
% * dchi(t) = wbar + deps(t)    [instantaneous frequency, rad/s]
% * chi(t) = wbar t + eps(t)    [total phase, rad]
% * eps(t) is the (relative) phase

clear
close all
duration=400; % simulation time
scale=1; % figure scaling factor

t = linspace(0,duration,duration*50)';
dt=t(2)-t(1); % timestep
%%

A = 1 + 0.1*sin(2*pi/40*t); % eta envelope modulation
epsilon = 0.9*sin(2*pi/25*t);     % phase modulation;
wbar = 2*pi/10;             % base frequency
chi = wbar*t + epsilon;         % total angle
w = gradient(chi,t);        % instantaneous frequency
eta = [t A.*sin(chi)];

% customPlot(t,eta(:,2),1.5)
% legend('Case1')
% ylabel('Water Elevation (m)')


mdl='PLL_vs_Hilbert';
open(mdl);

IO_LF(1)=linio('PLL_vs_Hilbert/Subsystem1/PLL/Product2',1,'openoutput');
IO_LF(2)=linio('PLL_vs_Hilbert/Subsystem1/PLL/PI',1,'input');
IO_PD(1)=linio('PLL_vs_Hilbert/Subsystem1/PLL/Product',1,'input');
IO_PD(2)=linio('PLL_vs_Hilbert/Subsystem1/PLL/Phase Detector Integrator',1,'openoutput');

linsys_LF = linearize(mdl,IO_LF);
linsys_PD = linearize(mdl,IO_PD);

pidTuner

ki_PD=0.001;
kp_LF=0.476;
ki_LF=0.004;

out=sim(mdl);
customPlot(t,w/(2*pi),1.5)
hold on
plot(out.simout.f_est_PLL,'--', 'LineWidth', 2*1.5)
hold off
ylabel('Instantaneous Frequency (Hz)');
legend('True','Estimate Value');
xlim([100,400])
ylim([-0.1,0.3])
%%
%%% adding noise to A
A_noisy = 1*(t<200) + 0.7*(t>=200);
eta_A_noisy = [t A_noisy.*sin(chi)];

customPlot(t,eta_A_noisy(:,2),1.5)
legend('Case2')
ylabel('Water Elevation (m)')

ki_PD=0.25;
kp_LF=4;
ki_LF=0.28;

out=sim(mdl);
customPlot(t,w/(2*pi),1.5)
hold on
plot(out.simout.f_est_PLL,'--', 'LineWidth', 2*1.5)
hold off
ylabel('Instantaneous Frequency (Hz)');
legend('True','Estimate Value');
xlim([100,400])
ylim([-0.1,0.3])
%%
%%% adding noise to frequency
eta_no_eps = A.*sin(chi-epsilon);
wbar_noisy = wbar*(t<200)+1.5*wbar*(t>=200);
chi_noisy = cumtrapz(t,wbar_noisy);
eta_f_noisy = [t A.*sin(chi_noisy)];
w_f_noisy = gradient(chi_noisy,t);

customPlot(t,eta_f_noisy(:,2),1.5)
legend('Case3')
ylabel('Water Elevation (m)')

ki_PD=2;
kp_LF=4;
ki_LF=0.9;

out=sim(mdl);
customPlot(t,w_f_noisy/(2*pi),1.5)
hold on
plot(out.simout.f_est_PLL,'--', 'LineWidth', 2*1.5)
hold off
ylabel('Instantaneous Frequency (Hz)');
legend('True','Estimate Value');
xlim([100,400])


% %% PLL parameters
% K_vco=1; %VCO update gain for phase (1) and frequency (2)
% K_pd=1;
% K_CP=1;
% tyofpd=3;
% %% original eta
% [vco_out,pd_out,lf_out,phi_vco,f_vco] = PLL(eta,t,wbar,1,1,1,tyofpd);
% 
% customPlot(t,vco_out,1,eta)
% title("vco out vs input")
% legend('vco','input')
% customPlot(t,unwrap(phi_vco),1,chi)
% customPlot(t,w/(2*pi),1.5,f_vco)
% legend("True Value","Estimated Value")
% ylabel("Instantaneous Frequency (Hz)")
% %% A eta
% 
% [vco_out_A,pd_out_A,lf_out_A,phi_vco_A,f_vco_A] = PLL(eta_A_noisy,dt,wbar,K_vco,K_pd,tyofpd);
% 
% customPlot(t,vco_out_A,1,eta_A_noisy)
% title("vco out vs input")
% legend('vco','input')
% 
% customPlot(t,unwrap(phi_vco_A),1,chi)
% 
% customPlot(t,w/(2*pi),1.5,f_vco_A)
% ylabel("Instantaneous Frequency (Hz)")
% legend("True Value","Estimated Value")
% 
% %% f eta
% 
% [vco_out_f,pd_out_f,lf_out_f,phi_vco_f,f_vco_f] = PLL(eta_f_noisy,t,wbar,K_pd,K_vco,K_CP,tyofpd);
% 
% customPlot(t,vco_out_f,1,eta_f_noisy)
% title("vco out vs input")
% legend('vco','input')
% 
% customPlot(t,unwrap(phi_vco_f),1,chi_noisy)
% 
% 
% customPlot(t,wbar_noisy/2/pi,1.5,f_vco_f)
% ylabel("Instantaneous Frequency (Hz)")
% legend("True Value","Estimated Value")
% 
% %% filter testing
% f_bar=wbar/(2*pi);
% f_s = 1/dt;
% [b,a]=butter(1,(f_bar/(f_s/2)),"low");
% f_vco_initial = f_bar;
% filtered_eta = filter(b,a,eta);
% 
% customPlot(t,filtered_eta,1,eta)
% inst_phase_filtered = unwrap(angle(hilbert(filtered_eta)));
% inst_w_filtered=gradient(inst_phase_filtered,t);
% 
% customPlot(t,inst_w_filtered,1,w)