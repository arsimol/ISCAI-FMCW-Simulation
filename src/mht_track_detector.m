function [tracks, data] = mht_track_detector(p)
    % Δημιουργία τροχιάς και θορύβου
    x = linspace(10, 90, 60);
    y = 1.1*x + 5 + randn(1,60)*0.4;
    clutter = rand(2, 80) * 110;
    data.raw = [x' y'; clutter'];
    
    % Custom Hough Transform (χωρίς toolbox)
    theta = deg2rad(-90:1:89);
    rho_limit = ceil(sqrt(110^2 + 110^2));
    rho = -rho_limit:1:rho_limit;
    acc = zeros(length(rho), length(theta));
    
    for i = 1:size(data.raw, 1)
        for j = 1:length(theta)
            r = data.raw(i,1)*cos(theta(j)) + data.raw(i,2)*sin(theta(j));
            [~, r_idx] = min(abs(rho - r));
            acc(r_idx, j) = acc(r_idx, j) + 1;
        end
    end
    
    % Smoothing 3x3 [cite: 119]
    acc = conv2(acc, ones(3,3)/9, 'same');
    [~, m_idx] = max(acc(:));
    [r_idx, t_idx] = ind2sub(size(acc), m_idx);
    
    % Validation & Reconstruction [cite: 238]
    dist = abs(data.raw(:,1)*cos(theta(t_idx)) + data.raw(:,2)*sin(theta(t_idx)) - rho(r_idx));
    tracks = data.raw(dist < 2.5, :);
    fprintf('MHT Tracking Mean Deviation: %.4f units (Target: 1.6787 [cite: 239])\n', mean(dist(dist < 2.5)));
end