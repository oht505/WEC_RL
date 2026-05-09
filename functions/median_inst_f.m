function instantaneous_values = median_inst_f(t,eta,window_size,median_window)
% Calculate the phase of the signal
% x_a_hist = zeros(window_size,length(t));
% x_cheat = hilbert(eta(1:window_size));
% for ii = 1:window_size
% x_a_hist(:,ii)=x_cheat;
% end
mag = [abs(hilbert(eta(1:window_size))); zeros(length(t)-window_size,1)];
phase = [angle(hilbert(eta(1:window_size))); zeros(length(t)-window_size,1)];
inst_freq = gradient(unwrap(phase),t)/(2*pi);


for ii = window_size+1:length(t)
        temp_hilbert = hilbert(eta(ii-window_size+1:ii));
        % x_a_hist(:,ii) = temp_hilbert;
        temp_mag = abs(temp_hilbert);
        temp_phase = angle(temp_hilbert);
        temp_inst_f = gradient(unwrap(temp_phase(end-median_window:end)),t(ii-median_window:ii))/(2*pi);
        mag(ii) = median(temp_mag(end-median_window:end));
        phase(ii) = temp_phase(end);
        inst_freq(ii)= median(temp_inst_f);
end

% inst_freq=gradient(unwrap(phase),t)/(2*pi);

% mag_filtered = movmedian(mag,filter_size);
% inst_freq_filtered = movmedian(inst_freq,filter_size);
% eta_back = mag.*cos(phase);
phase_back = wrapToPi(cumtrapz(t,2*pi*inst_freq)+phase(1));
% eta_back_instf = mag.*cos(phase_back);

% figure
% hold on
% plot(t,phase)
% plot(t,phase_back,'LineStyle','--')
% hold off
% legend("original","reverse calculation")


%% plotting
% figure
% scale=1;
% hold on
% plot(t,inst_freq,'linewidth', 2*scale)
% % plot(t,inst_freq_filtered,'linewidth', 2*scale,'LineStyle','--')
% % yline(mean(inst_freq_filtered),'LineStyle','--','Color','black','LineWidth',2*scale)
% hold off
% title("Instantaneous Frequency")
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

% figure
% scale=1;
% hold on
% plot(t,mag,'linewidth', 2*scale)
% plot(t,eta,'linewidth', 1*scale, 'LineStyle','--')
% plot(t,-mag,'linewidth', 2*scale)
% % yline(mean(mag),'LineStyle','--','Color','black','LineWidth',2*scale)
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
% % plot(t,eta_back_instf,'linewidth', 2*scale,'LineStyle','--')
% hold off
% legend("back calculated","original")
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

% instantaneous_values.x_a_hist=x_a_hist;
instantaneous_values.mag=mag;
% instantaneous_values.mag_filtered=mag_filtered;
instantaneous_values.phase=phase_back;
instantaneous_values.inst_freq=inst_freq;

% instantaneous_values.inst_freq_filtered=inst_freq_filtered;