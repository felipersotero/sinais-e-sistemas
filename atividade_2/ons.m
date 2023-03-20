%{
Retire uma sequência de dados do site da ONS, com duração mínima de 1 ano
e verifique se há algum padrão de periodicidade por meio da transformada de fourier,
utilize a notação matricial.
Também utilize a transformada de fourier do tempo curto
para verificar a existência de algum padrão além do que já foi constatado.
%}

clc; clear all; close all;

pkg load io;

%Carregando dados da tabela
filename = 'carga_energia_2022.xlsx';
x = xlsread(filename);

%Criando vetor de tempo
n = length(x);
t = linspace(1, n, n);

%Plotando gráfico com dados da tabela
subplot(3,1,1);
plot(t, x);
xlabel("Tempo (dias)");
xlim([1 n]);
ylabel("Carga de Energia (GWh)");
title("Carga de Energia GWh (2022)");

%Calculando a Transformada de Fourier
X = fft(x);
N = length(X);

fs = 1; %Frequência de amostragem

%Ajustando as frequências e pegando seu módulo
X_adj = fftshift(abs(X));

%Criando o vetor de frequências
f = linspace(-fs/2, fs/2, N);

%Tomando apenas as frequências positivas
X_adj_pos = X_adj((N/2)+1:N);
f_pos = f((N/2)+1:end);

%Plotando as frequências positivas do sinal
subplot(3,1,2);
plot(f_pos, X_adj_pos);
xlabel("Frequência (Hz)");
ylabel("Amplitude");
%xlim([0 2000]);
title("TF do sinal");

%Calculando a Transformada de Fourier de Tempo Curto

%Parâmetros da STFT (win, overlap, nfft)

win = 256;     %Janela 256
overlap = 128; %Sobreposição das janelas 128
nfft = 1024;   %1024

S = stft(x, win, overlap, nfft);

%Plotando o espectrograma resultante

subplot(3,1,3);
%figure
imagesc(t, f_pos, (abs(S))); %t, f_pos, 
set(gca,'YDir','normal');
xlabel('Tempo (dias)');
xlim([0 n]);
ylabel('Frequência (Hz)');
ylim([0 max(f_pos)]);
title("Espectrograma");
%colorbar;