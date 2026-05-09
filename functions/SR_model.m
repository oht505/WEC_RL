function sin_regressed_model = SR_model(t,eta,window_size)
%% 
dt = t(2)-t(1);
  
    % Define the NAR model with multiple superposed sinusoidal functions
    nar_model = @(params, t) params(1) * sin(params(2) .* t + params(3));
    % nar_model = @(params, t) params(1).*t.^4 + params(2).*t.^3 +t + params(3).*t.^2+params(4).*t+params(5);
    % Weight model
    Ramp_model = @(t) t/sqrt(max(t.^2));
    % Objective function for optimization (least squares error)
    obj_func = @(params) sum(Ramp_model(t).*(eta - nar_model(params, t)).^2);
    options = optimset('Display', 'off', 'TolX',1e-6, 'TolFun', 1e-6, 'MaxIter', 1000);
    % Initial guess for the parameters [A1, omega1, phi1, A2, omega2, phi2, ..., An, omegan, phin]
    initial_guess = [1, 2*pi/10, -pi/10];
    % Estimate the parameters using nonlinear least squares optimization
    estimated_params = fminsearch(obj_func, initial_guess, options);
    % Extend the t
    t_ext = t(end-window_size+1):dt:t(end)+round(window_size*dt);
    t_ext = t_ext';
    % Generate the estimated output data
    sin_regressed_model = nar_model(estimated_params, t_ext);

% %Plot the original and estimated output data
% figure;
% plot(t(end-window_size+1:end), eta(end-window_size+1:end), 'b', 'DisplayName', 'Original Data');
% hold on;
% plot(t_ext(1:window_size), sin_regressed_model(1:window_size), 'r--', 'DisplayName', 'Estimated Data');
% title('NAR Model Parameter Estimation with Three Sinusoids');
% xlabel('Time');
% ylabel('Output');
% legend;