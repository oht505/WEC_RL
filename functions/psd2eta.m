function eta_filtered = psd2eta(S_w,fp,t,varargin)
%% Generating water elevation timeseries
% theta=linspace(-pi,pi,1000);
% phase=zeros(size(f));
% for ii =1:1000
% phase(ii) = 2*pi./1000;
% end
    % Optional RNG seed for reproducible phases
    if ~isempty(varargin)
        for k = 1:2:numel(varargin)
            if strcmpi(varargin{k}, "Seed")
                rng(varargin{k+1});
            end
        end
    end

    epsilon = unifrnd(-pi,pi,size(S_w)); %% uniformly distributed phase information
    time_step=t(2)-t(1);
    eta = zeros(size(t));
    
    psd_w = S_w(:,2);
    w=S_w(:,1);

    delta_w = mean(diff(w));
        for ii = 1:length(w)-1
            eta = eta + (sqrt(2*delta_w*psd_w(ii)))*cos(w(ii)*t+epsilon(ii));
        end

        %%processing eta
% Define cutoff frequency based on dominant wave period
f_cutoff = 2.5*fp;  % Cutoff frequency in Hz
Wn = 2 * f_cutoff * time_step;     % Normalize frequency (Nyquist frequency)

% Design Butterworth low-pass filter (2nd-order)
[b, a] = butter(2, Wn, 'low');

% Apply the filter to the wave elevation data
eta_filtered = filtfilt(b, a, eta);

eta_filtered = movmean(eta_filtered,round(1/6/fp/time_step));

% %%% Ramp function
% ramp = zeros(size(t));
% 
% t_ramp = 1/fp*10;
% 
% for ii=1:length(t)
%     if time_step*ii<t_ramp
%         ramp(ii) = 1/2*(1+cos(pi+pi*t(ii)/t_ramp));
%     else
%         ramp(ii) = 1;
%     end
% end
% 
% eta = eta.*ramp; 

% %% Excitation Force calculation by superposition
% 
% Fex_f_intp.real=interp1(lupadata.w,lupadata.float.F_ex_re,w,"linear","extrap");
% Fex_s_intp.real=interp1(lupadata.w,lupadata.spar.F_ex_re,w,"linear","extrap");
% Fex_f_intp.img=interp1(lupadata.w,lupadata.float.F_ex_im,w,"linear","extrap");
% Fex_s_intp.img=interp1(lupadata.w,lupadata.spar.F_ex_im,w,"linear","extrap");
% 
% Fex_float_w = Fex_f_intp.real + 1i*Fex_f_intp.img;
% Fex_spar_w = Fex_s_intp.real + 1i*Fex_s_intp.img;
% 
% Fex.float=zeros(size(t));
% Fex.spar=zeros(size(t));
% 
% for ii = 2:length(w)-1
%     Fex.float= Fex.float + real(ramp.*Fex_float_w(ii).*exp(1i*(w(ii)*t+epsilon(ii)))*sqrt(psd_w(ii)*2/1000));
%     Fex.spar= Fex.spar + real(ramp.*Fex_spar_w(ii).*exp(1i*(w(ii)*t+epsilon(ii)))*sqrt(psd_w(ii)*2/1000));
% end

%% Plotting

% %%% epsilon
% 
% figure
% scatter(theta,phase,100,'d')
% ylim([0,0.01])
% xlabel("phase (rad)")
% ylabel("probability density fucntion")
% ax = gca;
% ax.FontSize = 24*scale;
% ax.XAxis.FontSize = 18*scale;
% ax.YAxis.FontSize = 18*scale;
% set(gca, 'LineWidth', 2*scale);
% grid on;
% wdw=gcf;
% wdw.Position=[0,661,1920,920]*1/2*scale;

% %%% PSD
% figure
% hold on
% plot(f,psd,'linewidth', 2*scale)
% plot(f,S_f)
% xline(mean_f,'linewidth', 2*scale,'LineStyle','--')
% hold off
% xlabel("f (Hz)")
% ylabel("PSD (m^2/Hz)")
% legend("Power Spectrum Density", "Energy mean frequency")
% ax = gca;
% ax.FontSize = 24*scale;
% ax.XAxis.FontSize = 18*scale;
% ax.YAxis.FontSize = 18*scale;
% set(gca, 'LineWidth', 2*scale);
% grid on;
% wdw=gcf;
% xlim([0,1/lupadata.T(end)])
% wdw.Position=[0,661,1920,920]*1/2*scale;

% %%% eta 
% scale=1;
% figure
% plot(t,eta_filtered, 'linewidth', 0.5*scale)
% title("Water Elevation")
% xlabel("Time (s)")
% ylabel("Water elevation (m)")
% ax = gca;
% ax.FontSize = 24*scale;
% ax.XAxis.FontSize = 18*scale;
% ax.YAxis.FontSize = 18*scale;
% set(gca, 'LineWidth', 2*scale);
% grid on;
% wdw=gcf;
% wdw.Position=[0,661,1920,920]*1/2*scale;
