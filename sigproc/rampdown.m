function outsig=rampdown(L,wintype)
%RAMPDOWN  Falling ramp function
%   Usage: outsig=rampdown(siglen);
%
%   RAMPDOWN(siglen) will return a falling ramp function of length siglen. The
%   ramp is a sinsosoidal starting from one and ending at zero. The ramp
%   is centered such that the first element is always one and the last
%   element is not quite zero, such that the ramp fits with following zeros.
%
%   RAMPDOWN(L,wintype) will use another window for ramping. This may be
%   any of the window types from FIRWIN. Please see the help on FIRWIN
%   for more information. The default is to use a piece of the Hann window.
%  
%   See also: rampup, rampsignal, firwin
   
error(nargchk(1,2,nargin))

if nargin==1
  wintype='hann';
end;
  
win=firwin(wintype,2*L,'inf');
outsig=win(1:L);

  