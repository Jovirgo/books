%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%    An Introduction to Scientific Computing          %%%%%%%
%%%%%%%    I. Danaila, P. Joly, S. M. Kaber & M. Postel     %%%%%%%
%%%%%%%                 Springer, 2005                      %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function y=APP_condVanderMonde(n)
%compute the condition number of a Vandermonde matrix
%The n+1 points are uniformly choosen between 0 and 1.
x=(0:n)'/n;
A=ones(length(x),1);
for k=1:length(x)-1
    A=[A x.^k];
end;
y=cond(A);