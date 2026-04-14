% =========================================================================
% Simulation of DPSK Data Modulation on an FMCW Radar Signal
% =========================================================================

clear; clc; close all;

%% 1. Define Parameters (Scaled down for visualization)
fc = 5;          % Carrier frequency (Hz) - The basic "pitch" of the wave
B = 10;          % Bandwidth (Hz) - How much the frequency increases
T = 1;           % Chirp duration (seconds) - Length of our signal
mu = B / T;      % Chirp slope (Hz/s)

Rb = 10;         % Data rate (bits per second) - How fast we send data
Ts = 1 / Rb;     % Symbol duration (seconds per bit)

fs = 1000;       % Sampling frequency (points per second for a smooth plot)
t = 0:1/fs:T-1/fs; % Time vector for the whole chirp

num_bits = T * Rb; % Total number of bits in this chirp (1 sec * 10 bps = 10 bits)

%% 2. Generate Random Information Bits (0s and 1s)
% This represents the message the ego vehicle wants to send.
data_bits = randi([0, 1], 1, num_bits);

%% 3. Differential Phase Encoding (The DPSK Logic)
% Rule: If bit is 0, phase stays the same. If bit is 1, phase flips by pi (180 degrees).
dpsk_phase = zeros(1, num_bits);
for k = 2:num_bits
    if data_bits(k) == 1
        dpsk_phase(k) = mod(dpsk_phase(k-1) + pi, 2*pi); % Flip phase
    else
        dpsk_phase(k) = dpsk_phase(k-1);                 % Keep phase
    end
end

%% 4. Map the Phase to the Time Vector (Piecewise Constant)
% The phase must remain totally flat (constant) during each symbol duration Ts!
phi_d = zeros(size(t));
for k = 1:num_bits
    % Find the time indices that belong to the current symbol
    start_time = (k-1) * Ts;
    end_time = k * Ts;
    idx = (t >= start_time) & (t < end_time);
    
    % Apply the constant phase to that specific time block
    phi_d(idx) = dpsk_phase(k);
end

%% 5. Generate the Optical Signals (Equations from the paper)
A_T = 1; % Amplitude

% A. The Local Oscillator (LO) - The "Clean" Radar Canvas
% s_LO(t) = A_T * exp(j * (2*pi*fc*t + pi*mu*t^2))
s_LO = A_T * exp(1j * (2*pi*fc*t + pi*mu*t.^2));

% B. The Transmitted Signal (TX) - The Radar + The Communication Data
% s_T(t) = A_T * exp(j * (2*pi*fc*t + pi*mu*t^2 + phi_d(t)))
s_T = A_T * exp(1j * (2*pi*fc*t + pi*mu*t.^2 + phi_d));

%% 6. Plotting the Results
figure('Name', 'ISAC Signal Generation', 'Position', [100, 100, 800, 600]);

% Plot 1: The Raw Data Bits
subplot(4,1,1);
stairs(0:Ts:T-Ts, data_bits, 'LineWidth', 2, 'Color', 'k');
title('1. The Information Bits (The Message)');
ylim([-0.2 1.2]); xlim([0 T]);
ylabel('Bit Value'); grid on;

% Plot 2: The Piecewise Constant Phase \phi_d(t)
subplot(4,1,2);
plot(t, phi_d, 'LineWidth', 2, 'Color', 'm');
title('2. DPSK Phase \phi_d(t) (Notice it only changes at boundaries and stays flat)');
ylim([-0.5 3.5]); xlim([0 T]);
yticks([0 pi]); yticklabels({'0', '\pi'});
ylabel('Phase (radians)'); grid on;

% Plot 3: The LO Signal (Clean Radar)
subplot(4,1,3);
plot(t, real(s_LO), 'LineWidth', 1.5, 'Color', 'b');
title('3. Local Oscillator Signal (Clean FMCW - Notice the frequency increasing smoothly)');
xlim([0 T]); ylim([-1.2 1.2]);
ylabel('Amplitude'); grid on;

% Plot 4: The Transmitted Signal (Radar + Data)
subplot(4,1,4);
plot(t, real(s_T), 'LineWidth', 1.5, 'Color', 'r');
title('4. Transmitted Signal (Notice the wave flipping upside down when phase changes!)');
xlim([0 T]); ylim([-1.2 1.2]);
ylabel('Amplitude'); xlabel('Time (seconds)'); grid on;