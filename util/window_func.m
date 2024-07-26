function window = window_func(window_type, window_size)
    % Function to generate window function
    switch window_type
        case 'rectwin'
            window = rectwin(window_size)';
        case 'hamming'
            window = hamming(window_size)';
        % Add more window types as needed
        otherwise
            error('Invalid window type');
    end
end