function split_wave_dataset(src_folder, target_folder, split_duration)
    % src_folder: includes original wave data
    % target_folder: saves split data
    % split_duration: is the episode length (s) e.g., 200 seconds

    if ~exist(target_folder, 'dir'), mkdir(target_folder); end

    files = dir(fullfile(src_folder, 'Wave_*.mat'));
    fprintf("Total %d files found. Starting split... \n", length(files));

    for i = 1:length(files)
        load_data = load(fullfile(src_folder, files(i).name), 'w');
        w_orig = load_data.w;

        if isfield(w_orig, 't')
            time_vec = w_orig.t; 
        else
            time_vec = w_orig.time;
        end

        dt = time_vec(2) - time_vec(1);
        steps_per_split = round(split_duration / dt);
        total_steps = length(time_vec);
        num_splits = floor(total_steps / steps_per_split);

        % fileparts: path + file_name + format
        [~, base_name, ~] = fileparts(files(i).name);

        for j = 1:num_splits
            start_index = (j - 1) * steps_per_split + 1;
            end_index = min(start_index + steps_per_split, total_steps);

            w = struct();

            w.t = time_vec(start_index:end_index) - time_vec(start_index);
            w.eta = w_orig.eta(start_index:end_index);
            w.Fex1 = w_orig.Fex1(start_index:end_index);
            w.Fex2 = w_orig.Fex2(start_index:end_index);

            w.H_s = w_orig.H_s;
            w.Tp = w_orig.Tp;

            w.original_file = base_name;
            w.part_index = j;
            w.is_first_part = (j == 1);
            w.is_last_part = (j == num_splits);
            w.total_parts = num_splits;

            save_name = sprintf("%s_part_%d.mat", base_name, j);
            save(fullfile(target_folder, save_name), 'w');
        end
        fprintf("   - %s: %d splits created. \n", base_name, num_splits);
    end
    fprintf("Done! All datasets are ready in: %s\n", target_folder);
end