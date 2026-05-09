function customPlot(t, data1, scale, data2, data3)
    % Create figure window
    hold on;
    
    % Define color palette
    colors.osu.orange = [243 115 33]/256;
    colors.osu.darkblue = [93 135 161]/256;
    colors.osu.lightblue = [156 197 202]/256;
    colors.osu.lightgray = [201 193 184]/256;
    colors.osu.darkgray = [171 175 166]/256;
    colors.osu.gold = [238 177 17]/256;
    colors.osu.lightbrown = [176 96 16]/256;
    colors.osu.red = [192 49 26]/256;
    colors.osu.green = [159 166 23]/256;
    colors.osu.purple = [98 27 75]/256;
    colors.osu.black = [0 0 0]/256;
    
    % Plot first dataset
    plot(t, data1, 'LineWidth', 2*scale, 'Color', colors.osu.darkblue);
    
    
    % Plot second dataset if provided
    if exist('data2', 'var') && ~isempty(data2)
  
        plot(t, data2, 'LineWidth', 2*scale, 'Color', colors.osu.orange);

    end
    
    % Plot third dataset if provided
    if exist('data3', 'var') && ~isempty(data3)

        plot(t, data3, 'LineWidth', 2*scale, 'Color', colors.osu.green);

    end

    % Customize axes
    ax = gca;
    ax.FontSize = 24 * scale;
    ax.XAxis.FontSize = 18 * scale;
    ax.YAxis.FontSize = 18 * scale;
    set(gca, 'LineWidth', 2 * scale);
    grid on;
    
    % Labels
    xlabel('Time (s)');
    ylabel('Data');
    
    % Adjust figure size and position
    wdw = gcf;
    wdw.Position = [0, 661, 1920, 920] * scale/2;
    
    hold off;
end
