function [Kp_LF, Ki_LF] = PLL_tune(model_name, cutoff_frequency, phase_margin)
    % Open the Simulink model
    load_system(model_name);

    % Find the PLL block within the model
    % Assuming the PLL block is a Subsystem named 'PLL'
    pll_blocks = find_system(model_name, 'BlockType', 'SubSystem', 'Name', 'PLL');

    if isempty(pll_blocks)
        error('No PLL block named "PLL" found in the model.');
    elseif length(pll_blocks) > 1
        error('Multiple PLL blocks named "PLL" found in the model. Please ensure there is only one.');
    end

    % Get the full path of the PLL block
    pll_path = pll_blocks{1};

    % Define linearization I/O points for the loop filter
    % Adjust these points based on the structure of your PLL subsystem
    IO_LF(1) = linio([pll_path '/Product2'], 1, 'openoutput');
    IO_LF(2) = linio([pll_path '/PI'], 1, 'input');

    % Linearize the plant for the loop filter
    linsys_LF = linearize(model_name, IO_LF);

    % Specify the desired controller type (e.g., PI controller)
    Ctype = 'PI';

    % Create a pidtuneOptions object with the specified phase margin
    opts = pidtuneOptions('PhaseMargin', phase_margin, 'DesignFocus', 'reference-tracking');

    % Tune the PID controller with the specified crossover frequency
    [C, ~] = pidtune(linsys_LF, Ctype, cutoff_frequency, opts);

    % Extract the tuned gains
    Kp_LF = -C.Kp;
    Ki_LF = -C.Ki;
end
