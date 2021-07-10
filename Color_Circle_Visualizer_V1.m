%%
% Music Visualizer - Color Circle Code by Nate F.
% GitHub - https://github.com/NateFe/MATLAB-Music-Analysis
%%
clear;clc;close all
addpath(genpath('Functions')) % Add in necessary function paths
FileName  = 'Hope';           % Put your file name here
Extension = '.mp3';           % Music file's extension
[DataRaw,Fs] = audioread([FileName Extension]); % Read audio file


Samples = (1:length(DataRaw));      % Number of music samples
Freq = (1:length(DataRaw))*Fs;      % Frequency ranges dependent on sampling freq
Time = (1:length(DataRaw))/Fs;      % Length of music
DataRaw = DataRaw(:,1);             
len = length(Time);
Data = DataRaw(1:len)';
y = Time(1:len);
%% Circle 
clc;
myVideo = VideoWriter([FileName '_Colors.avi']);    % Opening the avi file for writing
myVideo.Quality = 100;                              % Compression quality
myVideo.FrameRate = 20;                             % Standard FPS
open(myVideo);

FMax = 4500;                                        % Max Frequency range of spectrum
TimeStep = 0.15;
figure(2); hold on; 
[spect,T,Fre] = mtspecgram(Data, Fs, FMax, TimeStep);   % Function to find the spectragram 
Theta = Fre*2*pi/max(Fre);                              % Mapping frequency to angle
set(gcf, 'Position', get(0, 'ScreenSize'));
close all;

%% Setting up a frequency cell array to be used for plotting the theta axis 
Scale = 15;
for NN = 1:length(Fre)
    CellLabel(NN) = cellstr(num2str(round(Fre(NN))));
end
count2 = 1;
for MM = 1:Scale:length(CellLabel)
    CellTime{count2} = CellLabel{MM};
    count2 = count2 + 1;
end
%% Plotting frequency as a function of time 

sound(Data, Fs)     % starts playing msuic
tic                 % Starts Matlab timer
t(1)=toc;           % Gets the time since the timer started
count = 1;
for NN = 1:length(T)
   figure(4);
   cmap = flipud(winter(length(spect(count - 0,:)))); % Mapping frequency to color
   Data = 1./(-log10(spect(count - 0,:)));            % Displaying Frequency 
   for MM = 1
    polarscatter(Theta,MM*Data/sum(Data),10,cmap,'filled'); hold on;    % Displaying plot normilizing each step to the sum of power in the frequencies at the given time step
   end
   hold off;
   set(gca,'rtick',[])                      % remove radial ticks

    rlim([0 0.0035])                        % Limit r axis
    ax= gca;    
    ax.ThetaDir = 'counterclockwise';               % Reverse direction of ticks
    ax.ThetaTick = Theta(1:Scale:end)*360/(2*pi);   % Setting polar ticks to remove extra lines
    ax.ThetaTickLabel = CellTime;                   % Setting polar axis to the cell time

   grid off;                        %[-0.15 0.15] right for norm not DB
   drawnow                          % necessary to get figure updated
   Frame = getframe(gcf);           %   Get current mat figure
   writeVideo(myVideo,Frame);       % Write frame to open AVI file
   count = count + 1;
   t(count)=toc;                    % get the current time for the next update
end
close(myVideo);
close all;