%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function: PLL.m
%Programmed by: Qian Wang
%Date: September 20, 2006
%Version: 1.0
%Description: This simulation program is to realize Phase-Looked Loops.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [vco_out,pd_out,lf_out,phi_vco,f_vco] = PLL(sig_in,t,w_bar,K_pd,K_vco,K_CP,tyofpd)
%-----------------------------------------------------------
%                      Input parameters
% sig_in:   Input siganl (vector)
% fs:       Sampling rate
% num:      Numerators of Loop filter transfer function in Laplace form (vector)
% den:      Denominators of Loop filter transfer function in Laplace form (vector)
% K_vco:    VCO gain (rad/(V*s))
% K_pd:     Phase detector gain (V/rad)
% tyofpd:   Type of phase detector (1 = Multiplier; 2 = XOR)
% f_vco:    VCO center frequency
% M:        Frequency divider
% N:        Frequency divider
%                      Output parameters
% voc_out:  Output signal of VCO
% pd_out:   Output signal of phase detector
% lf_out:   Output signal of loop filter
% phi_vco:  VCO phase vector
%-----------------------------------------------------------

%********************** Preparation part ***************************
dt=t(2)-t(1);
npts = length(sig_in);                 %Number of simulation points
phi_vcoinitial = 0;          %Initialize the total phase before the PLL algorithm is started
f_bar=w_bar/(2*pi);
f_s = 1/dt;
[b,a]=butter(2,(f_bar/(f_s/2)),"low");
f_vco_initial = f_bar;
%Initialize the VCO output before the PLL algorithm is started
vco_outinitial = sin(phi_vcoinitial);

%  vco_outinitial = square(phi_vcoinitial);

%Preallocating arrays
phi_vco = zeros(1,npts);             %Initialize VCO phase
vco_out = zeros(1,npts);             %Initialize VCO output
pd_out  = zeros(1,npts);             %Initialize phase detector output
lf_out  = zeros(1,npts);             %Initialize loop filter output
f_vco = zeros(1,npts);
CP_out = zeros(1,npts);
up_ff = 0;
down_ff = 0;
% [numd,dend] = bilinear(num,den,fs);    %Transforms analog filters into their discrete equivalents
% [Numd,Dend] = eqtflength(numd,dend);   %Equalize lengths of transfer function's numerator and denominator
% [a,b,c,d]   = tf2ss(Numd,Dend);        %Convert transfer function loop filter parameters to state-space form


% mn = size(a);
% x  = zeros(mn(2),npts+1);              %Initialize state variable

%************************** Main loop part **************************

h = waitbar(0,'Please wait...');
         phi_vco(1) = phi_vcoinitial;
        vco_out(1) = vco_outinitial;
        f_vco(1) = f_vco_initial;

for i = 2:npts
    waitbar(i/npts,h);

    %***************** Phase detector ********************

        %Choose the type of phase detector
switch tyofpd
    case 1
            pd_out(i) = K_pd*sig_in(i)*vco_out(i);
    case 2
            pd_out(i) = -sign(sig_in(i)*vco_out(i));
    case 3
        % Detect rising edges (current is high, previous is low)
        ref_rising_edge = sig_in(i) > 0 && sig_in(i-1) <= 0;  % Rising edge in reference
        fb_rising_edge = vco_out(i) > 0 && vco_out(i-1) <= 0;    % Rising edge in feedback

        % D-Flip-Flop logic:
        % If reference has a rising edge and feedback doesn't, set UP
        if ref_rising_edge && ~fb_rising_edge
            up_ff = 1;   % UP is set
        end
        
        % If feedback has a rising edge and reference doesn't, set DOWN
        if fb_rising_edge && ~ref_rising_edge
            down_ff = 1;  % DOWN is set
        end

        % Reset both flip-flops if both signals had edges
        if up_ff > 0 && down_ff > 0
            up_ff = 0;
            down_ff = 0;
        end
            pd_out(i) = up_ff-down_ff;
            pd_count = pdf_count + pd_out(i);
end

    %***************** Charge Pump ********************
    CP_out(i) = K_CP_P*pd_out(i)+pd_count*K_CP_I;


    %******************** Loop filter *********************

    %Using state-space method to calculate loop filter output
    % x(:,i+1)  = a*x(:,i) + b*pd_out(i);
    % lf_out(i) = c*x(:,i) + d*pd_out(i);

    %pre-built butterworth-lowpass-filter
    filtered_pd = filter(b,a,CP_out(1:i));
    lf_out(i) = filtered_pd(end);
    % lf_out(i) = pd_out(i);


    %******************** VCO *********************
    %Deciding Frequency lock or Phase lock mode
    mode = (abs(pd_count) > mode_thresh_hold);

    switch mode
        case 1 
            f_vco(i+1) = f_bar + K_vco*lf_out(i); % frequency update
            vco_out(i+1) = sin(2*pi*f_vco(i+1)*t(i)); % updated VCO
        case 2
            phi_vco(i+1) = phi_vco(i)+2*pi*f_vco(i)*dt; % Phase update
            f_vco(i+1) = f_vco(i);
            vco_out(i+1) = sin(phi_vco(i+1)); % updated VCO
    end
end

phi_vco=phi_vco(1:length(sig_in));
f_vco=f_vco(1:length(sig_in));
vco_out=vco_out(1:length(sig_in));
close(h);

%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%