%% Spectrum plot
%%% Wave time series generation (JOSWAP Spectrum)
gamma = 1; %% Narrowness of spectrum
fp = 1/9; %% Peak Frequency
wbar = 2*pi*fp;
scale=1;
H_s = 2; %% Significant wave height = (m)
[S_f, S_w] = JONSWAP(gamma,fp,H_s);
eta_JONSWAP= psd2eta(S_w,fp,t);
eta = [t eta_JONSWAP];

 figure;
    hold on;
    plot(S_f(:,1), S_f(:,2), 'LineWidth', 2*scale);
    h1 = xline(fp*1.5, 'LineWidth', 2*scale, 'LineStyle', '--', 'Color', 'r');
    h2 = xline(fp*0.5, 'LineWidth', 2*scale, 'LineStyle', '--', 'Color', 'r');
    hold off;
    xlabel('Frequency (Hz)', 'Interpreter', 'latex');
    ylabel('PSD ($\mathrm{m}^2$/Hz)', 'Interpreter', 'latex');
    legend([h1, h2], {'Saturation range'}, 'Interpreter', 'latex', 'FontSize', 24, 'Location', 'northeast');
    ax = gca;
    ax.FontSize = 24*scale;
    ax.XAxis.FontSize = 28*scale;
    ax.YAxis.FontSize = 28*scale;
    set(gca, 'LineWidth', 2*scale);
    grid on;
    wdw = gcf;
    xlim([0, S_f(end,1)]);
    wdw.Position = [0, 661, 1920, 920] * 1/2 * scale;