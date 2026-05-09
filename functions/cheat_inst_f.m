function instantaneous_values = cheat_inst_f(t,eta,filter_window_size)
% Calculate the phase of the signal

dt=t(2)-t(1);

eta_a = hilbert(eta);
phase = angle(eta_a);
mag = abs(eta_a);

inst_freq=gradient(unwrap(phase),t)/(2*pi);
mag_filtered = movmedian(mag,filter_window_size);
inst_freq_filtered = movmedian(inst_freq,filter_window_size/20);

eta_back = mag.*cos(phase);
phase_back = wrapToPi(cumtrapz(t,2*pi*inst_freq_filtered)+phase(1));
eta_back_instf = mag.*cos(phase_back);

% figure
% hold on
% plot(t,phase)
% plot(t,phase_back,'LineStyle','--')
% hold off
% legend("original","reverse calculation")
% %% plotting
% figure
% scale=1;
% hold on
% plot(t,inst_freq,'linewidth', 2*scale)
% plot(t,inst_freq_filtered,'linewidth', 2*scale,'LineStyle','--')
% yline(mean(inst_freq_filtered),'LineStyle','--','Color','black','LineWidth',2*scale)
% hold off
% title("Instantaneous Frequency")
% legend("Before the filtering","Filtered Instantaneous frequency", "Mean frequency")
% xlabel("time (t)")
% ylabel("Frequency (Hz)")
% ax = gca;
% ax.FontSize = 24*scale;
% ax.XAxis.FontSize = 18*scale;
% ax.YAxis.FontSize = 18*scale;
% set(gca, 'LineWidth', 2*scale);
% grid on;
% wdw=gcf;
% wdw.Position=[0,661,1920,920]*1/2*scale;
% 
% figure
% scale=1;
% hold on
% plot(t,mag,'linewidth', 2*scale)
% plot(t,eta,'linewidth', 1*scale, 'LineStyle','--')
% plot(t,-mag,'linewidth', 2*scale)
% yline(mean(mag),'LineStyle','--','Color','black','LineWidth',2*scale)
% hold off
% title("Instantaneous Amplitude")
% xlabel("time (t)")
% ylabel("Amplitude (m)")
% ax = gca;
% ax.FontSize = 24*scale;
% ax.XAxis.FontSize = 18*scale;
% ax.YAxis.FontSize = 18*scale;
% set(gca, 'LineWidth', 2*scale);
% grid on;
% wdw=gcf;
% wdw.Position=[0,661,1920,920]*1/2*scale;
% 
% figure
% scale=1;
% hold on
% plot(t,eta_back,'linewidth', 2*scale)
% plot(t,eta,'linewidth', 1*scale, 'LineStyle','--')
% plot(t,eta_back_instf,'linewidth', 2*scale,'LineStyle','--')
% hold off
% legend("back calculated","original","back inst f")
% xlabel("time (t)")
% ylabel("eta (m)")
% ax = gca;
% ax.FontSize = 24*scale;
% ax.XAxis.FontSize = 18*scale;
% ax.YAxis.FontSize = 18*scale;
% set(gca, 'LineWidth', 2*scale);
% grid on;
% wdw=gcf;
% wdw.Position=[0,661,1920,920]*1/2*scale;


instantaneous_values.mag=mag;
instantaneous_values.mag_filtered=mag_filtered;
instantaneous_values.phase=phase;
instantaneous_values.inst_freq=inst_freq;
instantaneous_values.inst_freq_filtered=inst_freq_filtered;
