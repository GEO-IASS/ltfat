function h=ref_pfilt(f,g,a)
%REF_PFILT  Reference PFILT implementation by FFT
  
[L W]=size(f);

g=fir2long(g,L);

% Force FFT along dimension 1, since we have permuted the dimensions
% manually
if isreal(f) && isreal(g)
  h=ifftreal(fftreal(f,L,1).*repmat(fftreal(g,L,1),1,W),L,1);
else
  h=ifft(fft(f,L,1).*repmat(fft(g,L,1),1,W),L,1);
end;

h=h(1:a:end,:);


