%BANDPOWER   Computes the averge power in a band for time series data using a multitaper estimate
%
%   Usage:
%   power = bandpower(Fs, data, band)
%   power = bandpower(Fs, data, band, tapers)
%
%   Input:
%   Fs: sampling rate in Hz
%   eegdata: 1x<samples> vector of data
%   band: 1x2 vector [fmin fmax] of the frequency band limits
%   tapers: 1x2 vector [NW K] of taper parameters (default: [2 2])
%
%   Output:
%   power: The average power in dB of the signal in the given band
%   
%   Example:
% 
%   See also butterworth_filter_a_signal, cheby_bandpass, equi_lowpass
%
%   Copyright 2011 Michael J. Prerau, Ph.D.
%   
%   Last modified 01/07/2011
%********************************************************************
function power = bandpower(Fs, data, band, tapers)

%Assign default tapers
if nargin<4
    tapers=[2 2];
end

%Set up parameter structure
params.tapers=tapers;
params.pad=0;
params.Fs=Fs;
params.fpass=band;
params.err=0;
params.trialave=0;

%Compute multitaper powerspectrum on detrended data
[S,f]=mtspectrumc(detrend(data),params);

%Get the spectrum frequency resolution
df=f(2)-f(1);

%Compute power
power=mean(S)*df;