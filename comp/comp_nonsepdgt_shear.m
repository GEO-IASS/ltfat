function c=comp_nonsepdgt_shear(f,g,a,M,s0,s1,X)
%COMP_NONSEPDGT_SHEAR  Non-sep DGT using the shear algorithm
%   Usage:  c=comp_nonsepdgt_shear(f,g,a,M);
%
%   Input parameters:
%         f      : Factored input data
%         g      : Window.
%         a      : Length of time shift.
%         M      : Number of channels.
%         s0     : s0 from shearfind
%         s1     : s1 from shearfind
%         X      : X from shearfind
%   Output parameters:
%         c      : M x N*W*R array of coefficients, where N=L/a
%
%   Do not call this function directly, use NONSEPDGT instead.
%   This function does not check input parameters!

%   AUTHOR : Nicki Holighaus and Peter L. Soendergaard

L=size(f,1);
W=size(f,2);

b=L/M;
N=L/a;

if s1 ~= 0
    g = pchirp(L,s1).*g;
    f = repmat(pchirp(L,s1),1,W).*f;
end

if s0 ~= 0
    g = ifft(pchirp(L,-s0).*fft(g));
    f = ifft(repmat(pchirp(L,-s0),1,W).*fft(f));
end;

br = X;
ar = a*b/X;
Mr = L/br;
c_rect = comp_dgt(f,g,ar,Mr,L,0);

ind = [ar 0; 0 br]*[kron((0:L/ar-1),ones(1,L/br));kron(ones(1,L/ar), ...
                                                  (0:L/br-1))];
phs = reshape(mod((s1*(ind(1,:)-s0*ind(2,:)).^2+s0*ind(2,:).^2)*...
                  (L+1),2*L),L/br,L/ar);
phs = exp(pi*1i*phs/L);

for w=1:W
    c_rect(:,:,w) = phs.*c_rect(:,:,w);
end;

ind_final = [1 0;-s1 1]*[1 -s0;0 1]*ind;
ind_final = mod(ind_final,L);

c = zeros(M,N,W);

% The code line below this comment executes the commented for-loop
% using Fortran indexing.
%
% for jj = 1:size(ind,2)        
%     c2(floor(ind_final(2,jj)/b)+1, ind_final(1,jj)/a+1) = ...
%         c(ind(2,jj)/br+1, ind(1,jj)/ar+1);
% end
for w=0:W-1
    c(floor(ind_final(2,:)/b)+1+(ind_final(1,:)/a)*M+w*M*N) = ...
        c_rect(ind(2,:)/br+1+(ind(1,:)/ar)*Mr+w*M*N);
end;


