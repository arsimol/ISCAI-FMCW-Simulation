function [s_T, phi_d] = pcfmcw_signal_gen(p)
    t = 0:1/p.fs:p.T-1/p.fs;
    mu = p.B / p.T;
    num_bits = p.T * p.Rb;
    bits = randi([0 1], 1, num_bits);
    dpsk_phases = cumsum(bits * pi);
    t_bits = linspace(0, p.T, num_bits);
    phi_d = interp1(t_bits, dpsk_phases, t, 'previous', 'extrap');
    s_T = exp(1j * (2*pi*p.fc*t + pi*mu*t.^2 + phi_d));
end