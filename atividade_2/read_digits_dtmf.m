%Escreva um código em Octave/Matlab para, a partir de um arquivo de áudio,
%identificar as teclas apertadas em um telefone.

clc; clear all; close all;

%Importando áudio
%filename = 'digits_123.wav';
%filename = 'audio_digitos_682.wav';
%filename = 'digits_111.wav';

filename = 'my_digits.wav';

[x, fs] = audioread(filename);
n = length(x);

%Criando vetor de tempo do tamanho do áudio
t = linspace(0, n/fs, n);

%Plotando áudio ao longo do tempo
subplot(3,1,1);
plot(t, x);
xlabel("Tempo (s)");
ylabel("Amplitude");
title("Áudio");

%Calculando a tranformada de Fourier do sinal de áudio
X = fft(x);
N = length(X);

%Ajustando as frequências e pegando seu módulo
X_adj = fftshift(abs(X));

%Criando o vetor de frequências
f = linspace(-fs/2, fs/2, N);

%Tomando apenas as frequências positivas
X_adj_pos = X_adj((N/2)+1:N);
f_pos = f((N/2)+1:end);

%Plotando frequências reconhcedidas no áudio
subplot(3,1,2);
plot(f_pos, X_adj_pos);
xlabel("Frequência (Hz)");
ylabel("Amplitude");
xlim([0 2000]);
title("TF do áudio");

%Calculando a Transformada de Fourier de Tempo Curto

%Parâmetros da STFT (win, overlap, nfft)

win = 512;     %Janela 512
overlap = 128; %Sobreposição das janelas 256
nfft = 2048;   %1024

S = stft(x, win, overlap, nfft); %1024(freq) x 843(temp)

%Plotando o espectrograma resultante
subplot(3,1,3);
%figure
imagesc(t, f_pos, (abs(S))); %t, f_pos, 
set(gca,'YDir','normal');
xlabel('Tempo (s)');
ylabel('Frequência (Hz)');
ylim([0 2000]);
title("Espectrograma");
%colorbar;

%Encontrando dígitos

%Definindo as frequências DTMF
f_low = [697, 770, 852, 941];
f_high = [1209, 1336, 1477, 1633];

%Matriz de dígitos DTMF
table_dtmf = ['1' '2' '3' 'A';'4' '5' '6' 'B'; '7' '8' '9' 'C'; '*' '0' '#' 'D'];

%Vetores de tempo e frequência ajustadas à STFT
T = linspace(min(t), max(t), size(S,2));
F = linspace(min(f_pos), max(f_pos), size(S,1));

%Definindo uma divisão para frequências em <=1000Hz e >1000Hz
F_limit = length(find(F <= 1000));

%Vetor de dígitos encontrados
digits = [];

%Variável de detecção de silêncio

%Percorrendo os valores ao longo do tempo
for i = 1:length(T)

  f_found = false;

  %Procurando frequência baixa
  [val_low idx_low] = max(S(1:F_limit, i));
  f_low_found = F(idx_low);
  
  %Procurando frequência alta    
  [val_high idx_high] = max(S(F_limit:end, i));
  f_high_found = F(idx_high+F_limit); %O SEGREDO ESTAVA AQUIII nesse + F_limit
  
  %Verificando se está dentro da faixa DTMF
  
  %Frequência baixa
  for j = 1:length(f_low)
    if(abs(f_low_found - f_low(j)) < 20)
      %Frequência alta
      for k = 1:length(f_high)
        if(abs(f_high_found - f_high(k)) < 30)
          digits = [digits, table_dtmf(j,k)];
          f_found = true;        
        endif
      endfor
    endif   
  endfor
  
  if ~f_found
    digits = [digits, '-'];
  endif
  
endfor

relevantDigits = [];

for l = 1:length(digits)
  if digits(l) ~= '-'
    if l == 1
      relevantDigits = [relevantDigits, digits(l)];
    else
      if digits(l-1) == '-'
        relevantDigits = [relevantDigits, digits(l)];
      endif
    endif
  endif
endfor

disp(relevantDigits);