function [time, shadow_bounds, L] = adb_control(p)
    % Προσομοίωση ADB - Oncoming Vehicle (Fig. 3a) 
    
    % Χρόνος προσομοίωσης: 0 έως 9 δευτερόλεπτα
    time = linspace(0, 9, 100);
    
    % Κινηματική (Ταχύτητες: Ego = 40 km/h, Target = 30 km/h αντίθετα) 
    v_rel = (40 + 30) * (1000 / 3600); % Σχετική ταχύτητα σε m/s (~19.44 m/s)
    d_long = 150 - v_rel * time;       % Διαμήκης απόσταση (αρχική 150m) 
    d_lat = 3.5;                       % Εγκάρσια απόσταση (πλάτος λωρίδας ~3.5m)
    
    % Συνολική ευθύγραμμη απόσταση d
    d = sqrt(d_long.^2 + d_lat.^2);
    
    % Υπολογισμός γωνίας στόχου (theta_target) ως προς τον διαμήκη άξονα
    theta_target = atand(d_lat ./ d_long);
    
    % Παράμετροι εξίσωσης σκίασης (Θ) 
    delta_y = 0.5;   % Lateral offset κάμερας-προβολέα
    delta = 1.5;     % Safety margin (μοίρες)
    
    % Υπολογισμός ορίων σκίασης (Shadow interval: Theta_L και Theta_R) 
    offset_term = atand(delta_y ./ d);
    theta_L = theta_target - offset_term - delta;
    theta_R = theta_target - offset_term + delta;
    
    % Περιορισμός εντός των ορίων θέασης (View angle limits: +/- 15 μοίρες)
    theta_L(theta_L > 15) = 15;
    theta_R(theta_R > 15) = 15;
    
    shadow_bounds = [theta_L; theta_R];
    
    % Υπολογισμός Light Intensity (Raised-cosine function) 
    d_min = 30; d_max = 80;
    L = ones(size(d));
    for i = 1:length(d)
        if d(i) <= d_min
            L(i) = 0; % Πλήρης σκίαση αν είναι πολύ κοντά (για αποφυγή glare)
        elseif d(i) > d_min && d(i) < d_max
            % Raised-cosine εξασθένηση 
            L(i) = (1 - cos(pi * (d(i) - d_min) / (d_max - d_min))) / 2;
        else
            L(i) = 1; % Πλήρης φωτεινότητα μακριά
        end
    end
end