%MTSPECGRAM  Computes spectrogram of EEG data using multitaper method
%
%   Usage:
%   [spect,stimes,sfreqs]=mtspecgram(data,fs)
%   [spect,stimes,sfreqs]=mtspecgram(data,fs, ploton)
%   [spect,stimes,sfreqs]=mtspecgram(data, params, movingwin)
%   [spect,stimes,sfreqs]=mtspecgram(data, params, movingwin, ploton)
%
%   Input:
%   data: in form <samples> x <channels> -- required
%   fs:  sampling frequency
%   params: structure with fields tapers, pad, Fs, fpass, err, trialave
%   ploton:
%
%   Output:
%   spect:
%   stimes:
%   sfreqs:
%   serr:
%
%   Example:
%
%         and example of the code's usage
%
%   See also mtspecgramc_detrend
%
%   Copyright 2011 Michael J. Prerau, Ph.D.
%
%   Last modified 7/6/2011
%********************************************************************

function [spect,stimes,sfreqs]=mtspecgram(varargin)

%Get time series data
data=varargin{1};

%Handle variable inputs

    %params=varargin{2};
    %if nargin==4
    %    ploton=varargin{4};
    %else
    %    ploton=1;
    %end
    params.pad=0;
    params.Fs=varargin{2};
    params.fpass=[0 varargin{3}];
    params.err=0;
    params.trialave=0;
    params.tapers=[3 2];
    movingwin=[varargin{4} varargin{4}/4];
    
    %Plots by default
    if length(varargin)==2
        ploton=1;
    else
        ploton=varargin{4};
    end

%Check if the parallel toolbox is installed
% if ~isempty(ver('distcomp'));
%     %Run parallel spectrogram
%     if params.err>0 && nargout==4
%         [spect,stimes,sfreqs,serr]=parspect(data,movingwin,params);
%     else
%         [spect,stimes,sfreqs]=parspect(data,movingwin,params);
%     end
% else
    %Run non-parallel spectrogram
    
        [spect,stimes,sfreqs]=nonparspect(data,movingwin,params);
   
%end

%Added spectrogram plot (MJP 8/2010)
if ploton
    %figure
    imagesc(stimes,sfreqs,pow2db(spect'));
    % axis image
    axis xy
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    climscale(gca);
    c = colorbar;
    %figure; mesh(pow2db(spect));
    ylabel(c,'Power (dB)');
    %sec2hms;
    axis tight
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NON PARALLEL MTSPECTRUM DETRENDED FROM CHRONUX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [S,t,f,Serr]=nonparspect(data,movingwin,params)


pbar=1;

[tapers,pad,Fs,fpass,err,trialave,params]=getparams(params);

data=change_row_to_column(data);
[N,Ch]=size(data);
Nwin=round(Fs*movingwin(1)); % number of samples in window
Nstep=round(movingwin(2)*Fs); % number of samples to step through
nfft=max(2^(nextpow2(Nwin)+pad),Nwin);
%nfft=400;
%f=getfgrid(Fs,512,fpass);
f=getfgrid(Fs,nfft,fpass);
Nf=length(f);
params.tapers=dpsschk(tapers,Nwin,Fs); % check tapers

winstart=1:Nstep:N-Nwin+1;
nw=length(winstart);

if trialave
    S = zeros(nw,Nf);
    %Serr=zeros(2,nw,Nf);
else
    S = zeros(nw,Nf,Ch);
    %Serr=zeros(2,nw,Nf,Ch);
end

%[taperobj ~]=gettapers(data,params);

for n=1:nw;
    indx=winstart(n):winstart(n)+Nwin-1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %the following line has been changed to include detrending of the window
    % -vsw, 8/2008
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    datawin=detrend(data(indx,:));
    
        [s,f]=mtspectrumc(datawin,params);
        %Serr(1,n,:,:)=squeeze(serr(1,:,:));
        %Serr(2,n,:,:)=squeeze(serr(2,:,:));
    
    S(n,:,:)=s;
    
end;

S=squeeze(S);
%Serr=squeeze(Serr);
winmid=winstart+round(Nwin/2);
t=winmid/Fs;

