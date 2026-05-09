function [S_f, S_w,mean_f] = JONSWAP(gamma,fp,H_s, N)

% JONSWAP_N parameter isn't found
if nargin < 4
    N = 1000;
    warning("JONSWAP_N isn't determined. Use default setting (N=1,000)" );
end

f=linspace(0.01,fp*4, N);
w=2*pi*f;
sig = 0.07*(f<=fp)+0.09*(f>fp); % width of spectrum
% g = 9.81; % gravity acceleration

q = exp(-(f-fp).^2./(2*sig.^2*fp^2));
f_gamma = gamma.^q;
I0 = trapz(f/fp,(f/fp).^(-5).*exp(-1.25*(f/fp).^-4).*f_gamma);
% I0 = 0.3050;

psd = (H_s^2/(16*I0)*fp^4)./ f.^5 .* exp(-5/4 * (fp./f).^4) .* f_gamma;
psd_w = 1/(2*pi)*psd;

S_f = [f' psd'];
S_w = [w' psd_w'];

m0=trapz(f,psd);
m1=trapz(f,f.*psd);
mean_f=m1/m0;
% Hs_back = 4*sqrt(m0);
scale=1;

% %%% PSD
% figure
% hold on
% plot(f,psd,'linewidth', 2*scale)
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
% xlim([0,f(end)])
% wdw.Position=[0,661,1920,920]*1/2*scale;
end