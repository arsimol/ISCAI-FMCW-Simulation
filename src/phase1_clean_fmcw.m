function [s_T, phi_d, t] = pcfmcw_signal_gen(p)
    % t: χρονικό διάνυσμα
    t = 0:1/p.fs:p.T-1/p.fs;
    mu = p.B / p.T; % Chirp slope [cite: 61]
    
    % Δημιουργία DPSK Phase Coding (Πηγή: [cite: 62, 63])
    num_bits = p.T * p.Rb;
    bits = randi([0 1], 1, num_bits);
    % Μετατροπή σε φάσεις {0, pi}
    dpsk_phases = cumsum(bits * pi);
    
    % Interpolation της φάσης στο χρόνο του chirp
    t_bits = linspace(0, p.T, num_bits);
    phi_d = interp1(t_bits, dpsk_phases, t, 'previous', 'extrap');
    
    % Παραγωγή PC-FMCW σήματος [cite: 62]
    s_T = exp(1j * (2*pi*p.fc*t + pi*mu*t.^2 + phi_d));
end