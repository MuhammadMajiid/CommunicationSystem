clc; close all;
%                    1st Stage: Transmitter
mytrack = uigetfile('*.mp3;*.wav');
[signal,fs]=audioread(mytrack);
signal = signal(12*fs :25*fs,1); % taking 13 seconds sample
% sound(signal, fs);
%               Plot sound file in time domain
t=linspace(0,length(signal)/fs,length(signal));
figure; subplot(2,1,1); plot (t,signal); 
title('Transmitted signal in time domain');
xlabel('Time'); ylabel('Amplitude');
%               Plot  sound file in the frequency domain
nfft=length(signal);
f = linspace(-(fs/2),(fs/2),nfft);
fsignal=abs(fftshift(fft(signal,nfft)));
subplot(2,1,2); plot(f(1:nfft),fsignal(1:nfft));
title('Transmitted signal in frequency domain');
xlabel('Frequency'); ylabel('Amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       2nd Stage: Channel
pause(14);
chantype= menu('Types', 'Delta function', 'Exp(-2pi*5000t)',...
    'Exp(-2pi*1000t)', 'Other');
switch (chantype)
    case 1 %Delta function
        chan = dirac(t);
%         in case [dirac] didn't work,
%         the reason would it needs symbolic math toolbox
        channelSig= conv(chan, signal);
    case 2 %Exp(-2pi*5000t)
        chan = exp(-2*pi*5000*t);
        channelSig= conv(chan, signal);
        
    case 3 %Exp(-2pi*1000t)
        chan = exp(-2*pi*1000*t);
        channelSig= conv(chan, signal);
    case 4 %Other 
        chan = zeros(length(signal),1);
        chan(1)=2;
        chan(fs)=0.5;
        channelSig = conv(chan, signal); 
        %               plotting the 4th channel
        figure; stem(t, chan); 
        title('The impulse response for the 4th channel');
        xlabel('Time in seconds'); ylabel('h(t)'); xlim([0 1]);   
    otherwise
end
% sound(channelSig, fs);
%                    plotting the channel in time domain
TforChan = linspace(0, length(channelSig)/fs, length(channelSig));
figure; subplot(2,1,1) ;plot(TforChan,channelSig);
title('The channel in time domain');
xlabel('Time'); ylabel('Amplitude'); xlim([0 20]);
%                    plotting the channel in frequency domain
FchanSig = fftshift(fft(channelSig));
Ffornoise = linspace(-fs/2, fs/2, length(channelSig));
magChSig = abs(FchanSig);
subplot(2,1,2) ;plot(Ffornoise,magChSig);
title('The channel in frequency domain');
xlabel('frequency'); ylabel('Amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       3rd Stage: Noise
pause(14); clear sound;
sigma = inputdlg('Enter the value of sigma: ', 'Sigma');
z = str2double(sigma)*randn(length(channelSig),1);
NoisySig = channelSig + z;
% sound(NoisySig, fs);
%               plotting the noisy signal in time domain
TforNoise = linspace(0, length(NoisySig)/fs, length(NoisySig));
figure; subplot(2,1,1) ;plot(TforNoise,NoisySig);
title('The noisy signal in time domain');
xlabel('Time'); ylabel('Amplitude');
%               plotting the noisy signal in frequency domain
FsigNoise = fftshift(fft(NoisySig));
Ffornoise = linspace(-fs/2, fs/2, length(NoisySig));
magChNSig = abs(FsigNoise);
subplot(2,1,2) ;plot(Ffornoise,magChNSig);
title('The noisy signal in frequency domain');
xlabel('frequency'); ylabel('Amplitude');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       4th Stage: Receiver
pause(14); clear sound;
cont = menu('Press to play received sound','Play');
LPF = ones( length(channelSig), 1 );

SPHZ = length(NoisySig) / fs; % sample per hz
zeroleft = fix( SPHZ * ( (fs/2) - (3400) ) ); % zero sample edge left
Zeroright = fix( SPHZ * ( (fs/2) + (3400) ) ); % zero sample edge right
LPF( [1:zeroleft Zeroright:end] ) = 0;
signal_f = FsigNoise .* LPF;
signal_t = real( ifft ( ifftshift(signal_f) ) );
% sound(signal_t,fs);
 %                        Plotting Receiver
 %                          Plotting LPF
figure; plot (Ffornoise, LPF);
title('Frequency response of ideal LPF');
xlim([-5000 5000]); ylim([0 2]);
 %                          Signal in time domain
figure; subplot(2,1,1); plot(TforNoise, signal_t);
title('Received Signal in time domain');
xlabel('Time'); ylabel('Amplitude');
 %                          Signal in freq domain
subplot(2,1,2); plot( Ffornoise, abs(signal_f) );
title('Received Signal in frequency domain');
xlabel('Frequency'); ylabel('Amplitude');
pause(8); clear sound;