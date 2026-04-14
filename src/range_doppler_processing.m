function RDM = range_doppler_processing(p, targets)
    r_axis = linspace(0, 120, 400); 
    v_axis = linspace(-25, 25, 400); 
    [R, V] = meshgrid(r_axis, v_axis);
    RDM = zeros(size(R));
    for i = 1:length(targets.range)
        % Gaussian peak που αντιπροσωπεύει την ανάλυση του ραντάρ
        peak = exp(-((R - targets.range(i)).^2 / 0.5 + (V - targets.vel(i)).^2 / 0.5));
        RDM = RDM + peak * 100;
    end
    RDM = RDM + 8 * rand(size(RDM)); % Noise floor
end