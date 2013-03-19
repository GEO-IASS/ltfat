function [wfunc,sfunc,xvals] = wavfun(w,varargin)
% WAVFUN  Wavelet Function
%    Usage: [w,s,xvals] = wavfun(g) 
%           [w,s,xvals] = wavfun(g,N) 
%
%   Input parameters:
%         w     : Wavelet filterbank
%         N     : Number of iterations
%   Output parameters:
%         wfunc : Approximation of wavelet function(s)
%         sfunc : Approximation of the scaling function
%         xvals : Correct x-axis values
%
%   Iteratively generate (*N* iterations) a discrete approximation of wavelet
%   and scaling functions using filters obtained from *w*. The possible formats of *w*
%   are the same as for the |fwt| function. The algorithm is equal to the 
%   DWT reconstruction of a single coefficient at level $N$ set to 1. *xvals*
%   contains correct x-axis values. All but alst collumns belong to the
%   *wfunc*, last one to the *sfunc*.
%   
%   The following flag groups are supported (first is default):
%
%   'ana','syn' - Which filters to use for generating the wavelet and scaling functions.
%   
%   'fft','conv' - How to do the computations. What is faster depends on
%   the speed of the conv2 function.
%
%   WARNING! The output array lengths *L* depend on *N* exponentially like:
%   
%   .. L=(m-1)*(a^N-1)/(a-1) + 1
%
%   .. math:: L=\frac{a^N-1}{a-1}(m-1)+1
%
%   where *a* is subsamling factor after the lowpass filter in the wavelet
%   filterbank and *m* is length of the filters. Expect isues for
%   high N e.g. 'db10' (m=20) and N=20 yeld ~150MB array.
%
%   Examples:
%   ---------
%   
%   Approximation of a Daubechies wavelet and scaling functions from the
%   12 tap filters:::
% 
%     [wfn,sfn,xvals] = wavfun('db6');
%     plot(xvals,[wfn,sfn]);
%     legend('wavelet function','scaling function');
%

definput.keyvals.N = 6;
definput.flags.ansy = {'syn','ana'};
definput.flags.howcomp = {'conv','fft'};
[flags,kv,N]=ltfatarghelper({'N'},definput,varargin);
w = fwtinit(w,flags.ansy);
a = w.a(1);
filtNo = length(w.filts);

% Copy impulse responses as columns of a single matrix.
lo = w.filts{1}.h(:);
wtemp = zeros(length(lo),filtNo);
for ff=1:filtNo
    wtemp(:,ff) =  w.filts{ff}.h(:);
end

filtsAreReal = isreal(wtemp);

if(flags.do_conv)
   % Linear convolutions in the time domain.
   for n=2:N
      wtemp = conv2(comp_ups(wtemp,a,1),lo);
   end
elseif(flags.do_fft)
   % Cyclic convolutions and upsampling in freqency domain.
   m = length(lo);
   L = (m-1)*(a^N-1)/(a-1) + 1;
   % Initial padding with zeros to avoid time aliasing.
   wtmpFFT = fft(wtemp,nextfastfft(2*m-1));
   for n=2:N
      loFFT = fft(lo,a*size(wtmpFFT,1));
      wtmpFFT = bsxfun(@times,repmat(wtmpFFT,a,1),loFFT);
   end

   wtemp = ifft(wtmpFFT);
   wtemp = wtemp(1:L,:);
else
   error('%s: Unexpected flag.',upper(mfilename));
end

% Final fomating
if filtsAreReal
   sfunc = real(wtemp(:,1));
   wfunc = real(wtemp(:,2:end));
else
   sfunc = wtemp(:,1);
   wfunc = wtemp(:,2:end);
end


if(nargout>2)
    % Calculate xvals
    xvals = zeros(length(sfunc),filtNo);
    zeroPos = findFuncZeroPos(w.filts{1}.d,a,N);
    sxvals = -zeroPos + (1:length(sfunc));
    xvals(:,end)= (length(lo)-1)*sxvals/length(sfunc);%linspace(0,length(lo)-1,length(s));

    for ii=1:filtNo-1 
       zeroPos = findFuncZeroPos(w.filts{ii+1}.d,a,N);
       sxvals = -zeroPos + (1:length(sfunc));
       xvals(:,ii)= (length(lo)-1)*sxvals/length(sfunc);%linspace(0,length(lo)-1,length(s));
    end
end
%END WAVFUN


function zeroPos = findFuncZeroPos(baseZeroPos,a1,N)
%FINDFUNCZEROPOS Finds zero index position in the *N* iteration approfimation of 
%                the wavelet or scaling functions.

zeroPos = baseZeroPos;
for n=2:N
   zeroPos = zeroPos*a1-(a1-1) + baseZeroPos-1;
end






