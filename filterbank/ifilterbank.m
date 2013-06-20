function f=ifilterbank(c,g,a,varargin);  
%IFILTERBANK  Filter bank inversion
%   Usage:  f=ifilterbank(c,g,a);
%
%   `ifilterbank(c,g,a)` synthesizes a signal *f* from the coefficients *c*
%   using the filters stored in *g* for a channel subsampling rate of *a* (the
%   hop-size). The coefficients has to be in the format returned by
%   either |filterbank| or |ufilterbank|.
%
%   The filter format for *g* is the same as for |filterbank|.
%
%   If perfect reconstruction is desired, the filters must be the duals
%   of the filters used to generate the coefficients. See the help on
%   |filterbankdual|.
%
%   See also: filterbank, ufilterbank, filterbankdual
%
%   References: bohlfe02

if nargin<3
  error('%s: Too few input parameters.',upper(mfilename));
end;

definput.keyvals.Ls=[];
[flags,kv,Ls]=ltfatarghelper({'Ls'},definput,varargin);

L=filterbanklengthcoef(c,a);

[g,info]=filterbankwin(g,a,L,'normal');
M=info.M;

if iscell(c)
  Mcoef=numel(c);
  W=size(c{1},2);
else
  Mcoef=size(c,2);
  W=size(c,3);    
end;

if ~(M==Mcoef)
  error(['Mismatch between the size of the input coefficients and the ' ...
         'number of filters.']);
end;

if iscell(c)
    f=zeros(L,W,assert_classname(c{1}));
else
    a=a(1);
    f=zeros(L,W,assert_classname(c));
end;

l=(0:L-1).'/L;
for m=1:M
    conjG=conj(comp_transferfunction(g{m},L));
    
    if iscell(c)
        N=size(c{m},1);
        Llarge=ceil(L/N)*N;
        amod=Llarge/N;
        
        for w=1:W                        
            % This repmat cannot be replaced by bsxfun
            f(:,w)=f(:,w)+ifft(bsxfun(@times,postpad(repmat(fft(c{m}(:,w)),amod,1),L),conjG));
        end;                
    else
        for w=1:W
            % This repmat cannot be replaced by bsxfun
            f(:,w)=f(:,w)+ifft(repmat(fft(c(:,m,w)),a,1).*conjG);
        end;        
    end;
end;
  
% Cut or extend f to the correct length, if desired.
if ~isempty(Ls)
  f=postpad(f,Ls);
else
  Ls=L;
end;
