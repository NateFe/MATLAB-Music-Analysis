function [taperobj freqs]=gettapers(data,params)
% Precompute tapers for fast computation
%
% Usage:
%
% [taperobj freqs]=gettapers(datawindow,params)
% Input:
% Note units have to be consistent. See chronux.m for more information.
%       datawindow 1xT vector of data for one window length
%       params: structure with fields tapers, pad, Fs, fpass, err, trialave
%       -optional
%           tapers : precalculated tapers from dpss or in the one of the following
%                    forms:
%                    (1) A numeric vector [TW K] where TW is the
%                        time-bandwidth product and K is the number of
%                        tapers to be used (less than or equal to
%                        2TW-1).
%                    (2) A numeric vector [W T p] where W is the
%                        bandwidth, T is the duration of the data and p
%                        is an integer such that 2TW-p tapers are used. In
%                        this form there is no default i.e. to specify
%                        the bandwidth, you have to specify T and p as
%                        well. Note that the units of W and T have to be
%                        consistent: if W is in Hz, T must be in seconds
%                        and vice versa. Note that these units must also
%                        be consistent with the units of params.Fs: W can
%                        be in Hz if and only if params.Fs is in Hz.
%                        The default is to use form 1 with TW=3 and K=5
%
%	        pad		    (padding factor for the FFT) - optional (can take values -1,0,1,2...).
%                    -1 corresponds to no padding, 0 corresponds to padding
%                    to the next highest power of 2 etc.
%			      	 e.g. For N = 500, if PAD = -1, we do not pad; if PAD = 0, we pad the FFT
%			      	 to 512 points, if pad=1, we pad to 1024 points etc.
%			      	 Defaults to 0.
%           Fs   (sampling frequency) - optional. Default 1.
%           fpass    (frequency band to be used in the calculation in the form
%                                   [fmin fmax])- optional.
%                                   Default all frequencies between 0 and Fs/2
%           err  (error calculation [1 p] - Theoretical error bars; [2 p] - Jackknife error bars
%                                   [0 p] or 0 - no error bars) - optional. Default 0.
%           trialave (average over trials/channels when 1, don't average when 0) - optional. Default 0
% Output:
%       taperobj       An object to be stored for the fast computation of
%                      spectra
%       freqs          Corresponding spectral frequencies
%
% Example:
%     %Create sample data
%     Fs=200;
%     t=linspace(0,2*pi*10,10*Fs);
%     f=10*sin(.5*t)+20;
% 
%     data=zeros(length(t));
% 
%     for i=1:length(t)
%          data(:,i)=sin(f(i)*t);
%     end
% 
%     %Set spectral parameters
%     params.pad=0;
%     params.Fs=Fs;
%     params.fpass=[0 55];
%     params.err=0;
%     params.trialave=0;
%     params.tapers=[3 5];
% 
%     %Precompute tapers
%     [taperobj freqs]=gettapers(data,params);
% 
%     %Create spectrogram
%     spectrum=zeros(length(freqs),length(t));
%     
%     %Quickly compute multitaper spectrum at each time point
%     for i=1:length(t)
%     spectrum(:,i)=mtprecomp(data(:,i),taperobj);
%     end
%    
%     %Plot figure
%     figure
%     imagesc(t,freqs,pow2db(spectrum));
%     axis xy;
%     ylabel('Frequency (Hz)');
%     xlabel('Time (seconds)');

[tapers,pad,Fs,fpass]=getparams(params);

data=change_row_to_column(data);
N=size(data,1);
nfft=max(2^(nextpow2(N)+pad),N);
[freqs,findx]=getfgrid(Fs,nfft,fpass);
tapers=dpsschk(tapers,N,Fs); % check tapers

taperobj.tapers=tapers;
taperobj.nfft=nfft;
taperobj.findx=findx;
taperobj.Fs=Fs;
taperobj.N=N;



