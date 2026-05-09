function predicted_wave = eta_prd(t_window,eta_window,window_size,predicting_options)

    switch predicting_options
        case 'mirror'
            eta_Dup=flip(eta_window); % flip the wave history
            predicted_wave = [eta_window ; -eta_Dup(2:end)]; % true_data(window_size)+est_data(window_size)
        case 'regression'
            eta_AR=SR_model(t_window,eta_window,window_size); % Sinusoidal Auto Regressive model
            predicted_wave=eta_AR;
        otherwise
            error('Not valid option')
    end
