function test_failed=test_nonsepdgt_shearola
%TEST_NONSEPDGT  Test non-separable DGT
%
%  This script runs a throrough test of the DGT routine,
%  testing it on a range of input parameters.
%
%  The computational backend is tested this way, but the
%  interface is not.
%
%  The script tests dgt, idgt, gabdual and gabtight.
%
%  Use TEST_WFAC and TEST_DGT_FAC for more specific testing
%  of the DGT backend.

ar =[ 4, 4, 3, 4, 4, 4];
Mr =[ 6, 6, 5, 6, 6, 6];
lt1=[ 0, 1, 1, 1, 2, 1];
lt2=[ 1, 2, 2, 3, 3, 4];
    
test_failed=0;
testmode=0;

disp(' ===============  TEST_NONSEPDGT_SHEAROLA ================');

disp('--- Used subroutines ---');

which comp_nonsepdgt_shear
which comp_nonsepdgt_shearola
which comp_nonsepwin2multi

for ii=1:length(ar);

  M=Mr(ii);
  a=ar(ii);
  lt=[lt1(ii), lt2(ii)];
    
  minL=dgtlength(1,a,M,lt);
  gl=minL;
  
  g=crand(gl,1);

  Lext=minL*10;

  % sanity check
  if Lext~=dgtlength(Lext,a,M,lt)
      error('Incorrect parameters.'); 
  end

  bl=Lext-gl;

  for Lidx=2:3

      L=bl*Lidx;
                                    
      if L~=dgtlength(L,a,M,lt)
          error('Incorrect parameters.'); 
      end

      for W=1:3                              
          
          f=crand(L,W);
          
          % --------- test reference comparison ------------
          

          cc_ref = dgt(f,g,a,M,'lt',lt);
          
          [s0,s1,br]=shearfind(Lext,a,M,lt);
          
          
          
          %cc_ola = comp_dgt_ola(f,g,a,M,bl);
          cc_ola = comp_nonsepdgt_shearola(f,g,a,M,s0,s1,br,bl);
          
          res = norm(cc_ref(:)-cc_ola(:))/norm(cc_ref(:));
          stext=sprintf(['REF   L:%3i W:%2i gl:%3i a:%3i M:%3i lt1:%2i lt2:%2i' ...
                         ' s0:%2i s1:%2i bl:%2i %0.5g'], L,W,gl,a,M,lt(1),lt(2),s0,s1,bl,res);
          test_failed=ltfatchecktest(res,stext,test_failed,testmode);
          
      end;      
      
  end;
  
end;

