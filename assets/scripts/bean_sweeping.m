%% Script de Simulación de Massive MIMO: Beam Sweeping y SNR vs. Nt
% Este script demuestra los conceptos básicos del mini-caso.

clc;
clear;
close all;

%% 1. Configuración de Parámetros de Simulación
% --- Parámetros del Enlace ---
Pt_dBm = 20;           % Potencia de transmisión total (dBm)
Pt_lin = 10^(Pt_dBm / 10) * 1e-3; % Potencia en W

path_loss_dB = 100;    % Pérdidas de propagación (simplificado)
path_loss_lin = 10^(-path_loss_dB / 10);

noise_density_dBm_Hz = -174; % Densidad espectral de ruido (dBm/Hz)
BW_Hz = 10e6;          % Ancho de banda (ej. 10 MHz)
noise_power_dBm = noise_density_dBm_Hz + 10*log10(BW_Hz);
noise_power_lin = 10^(noise_power_dBm / 10) * 1e-3; % Potencia de ruido en W

% --- Parámetros del Usuario y Antenas ---
% Para un usuario peatonal, su ángulo cambia lentamente. 
% Lo fijamos para esta simulación.
ue_angle_deg = 30;     % Ángulo real del usuario (grados)
ue_angle_rad = deg2rad(ue_angle_deg);

% Rango de antenas en la Estación Base (BS) para analizar
Nt_array = [4, 8, 16, 32, 64, 128, 256]; 

% Rango de ángulos para el barrido de haces (beam sweeping)
beam_sweep_angles_deg = -90:5:90; % Barrido de -90 a +90 grados en pasos de 5
beam_sweep_angles_rad = deg2rad(beam_sweep_angles_deg);

% Variables para almacenar resultados
snr_results_dB = zeros(size(Nt_array));
se_results_bps_hz = zeros(size(Nt_array));

%% 2. Bucle Principal: Simulación para cada valor de Nt

fprintf('Iniciando simulación...\n');

for i = 1:length(Nt_array)
    Nt = Nt_array(i); % Número actual de antenas
    
    % --- a. Definir el Canal del Usuario (Modelo LoS) ---
    % Usamos un modelo de antena Uniform Linear Array (ULA)
    % Asumimos separación de antenas d = lambda/2
    n = (0:Nt-1)'; % Vector de índices de antena
    
    % Vector de respuesta de la antena (steering vector) para el ángulo del UE
    steering_vec_ue = exp(-1j * pi * n * sin(ue_angle_rad));
    
    % El canal 'h' es el vector de respuesta con la atenuación
    % h es un vector de tamaño [Nt x 1]
    h = sqrt(path_loss_lin) * steering_vec_ue;

    % --- b. Simulación de Beam Sweeping ---
    % La BS prueba diferentes haces (vectores de precodificación 'w')
    % y el UE mide la potencia recibida.
    
    received_power_sweep = zeros(size(beam_sweep_angles_rad));
    
    for j = 1:length(beam_sweep_angles_rad)
        current_beam_angle = beam_sweep_angles_rad(j);
        
        % Vector de precodificación ('w') para el ángulo de barrido actual
        % (Usamos precodificación MRT - Maximum Ratio Transmission, normalizada)
        steering_vec_beam = exp(-1j * pi * n * sin(current_beam_angle));
        
        % w debe ser conjugado (MRT) y normalizado para potencia total Pt
        w = conj(steering_vec_beam) / norm(steering_vec_beam); 
        
        % --- c. Cálculo de la Potencia Recibida ---
        % Señal recibida (sin ruido) = h_transpuesto * w * señal_transmitida
        % Ganancia efectiva del canal + beamforming:
        effective_channel_gain = abs(h.' * w)^2; % h.' es transpuesta
        
        % Potencia recibida para este haz
        received_power_sweep(j) = Pt_lin * effective_channel_gain;
    end
    
    % --- d. Encontrar el Mejor Haz ---
    % El UE reportaría el haz con la máxima potencia
    [best_received_power, best_beam_index] = max(received_power_sweep);
    
    % --- e. Calcular KPIs (SNR y SE) para el mejor haz ---
    snr_lin = best_received_power / noise_power_lin;
    snr_results_dB(i) = 10 * log10(snr_lin);
    
    % Eficiencia Espectral (SE) usando la fórmula de Shannon
    se_results_bps_hz(i) = log2(1 + snr_lin);
    
    % --- f. [Opcional] Graficar el primer barrido de haces ---
    if Nt == 64 % Mostramos el gráfico solo para Nt=64
        figure;
        plot(beam_sweep_angles_deg, 10*log10(received_power_sweep / noise_power_lin));
        hold on;
        xline(ue_angle_deg, 'r--', 'Ángulo Real del Usuario', 'LineWidth', 2);
        plot(beam_sweep_angles_deg(best_beam_index), 10*log10(snr_lin), 'kx', 'MarkerSize', 12, 'LineWidth', 2);
        legend('Potencia de Haces (SNR)', 'Ángulo Real', 'Mejor Haz Encontrado');
        title(['Simulación de Beam Sweeping (Nt = ' num2str(Nt) ')']);
        xlabel('Ángulo del Haz (grados)');
        ylabel('SNR Recibida (dB)');
        grid on;
    end
end

fprintf('Simulación completada.\n');

%% 3. Visualización de Resultados: SNR y SE vs. Nt

figure;
% Gráfico de SNR vs Nt
subplot(1, 2, 1);
plot(Nt_array, snr_results_dB, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
title('SNR vs. Número de Antenas (Nt)');
xlabel('Número de Antenas (Nt)');
ylabel('SNR (dB)');
grid on;
set(gca, 'XScale', 'log'); % Escala logarítmica para Nt es común

% Gráfico de SE vs Nt
subplot(1, 2, 2);
plot(Nt_array, se_results_bps_hz, 'rs-', 'LineWidth', 2, 'MarkerSize', 8);
title('Eficiencia Espectral (SE) vs. Nt');
xlabel('Número de Antenas (Nt)');
ylabel('Eficiencia Espectral (b/s/Hz)');
grid on;
set(gca, 'XScale', 'log');