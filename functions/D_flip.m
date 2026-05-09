function [up_ff, down_ff] = D_flip(reference_signal, feedback_signal)
    % D-Flip-Flop Phase Frequency Detector (PFD)
    npts=length(reference_signal);
    % Initialize flip-flop states
    up = zeros(1,npts);
    down = zeros(1,npts);
    up_ff=0;
    down_ff=0;
   
    % Loop through each time step to detect edges
    for n = 2:npts

    
    end
end
