%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%    An Introduction to Scientific Computing          %%%%%%%
%%%%%%%    I. Danaila, P. Joly, S. M. Kaber & M. Postel     %%%%%%%
%%%%%%%                 Springer, 2005                      %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   Matlab Solution of exercise 1 - project 9
%%   CAGD: geometrical design
%%   Construction of a B�zier curve
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   Example of a convex control polygon 
%%
clear all; close all;
% control points definition
np=5;
XP=zeros(np,1);YP=zeros(np,1);
XP=[ 3.5 , 1. , 2. , 3. , 0.   ] ;
YP=[ 0. , 2.5 , 3. , 1.5 , 0.   ] ;
% sampling the B�zier curve
T=[0:0.05:1.];
[X,Y]=CAGD_cbezier(T,XP,YP);
%
% graphics
%
% a) window definition 
nf=1; figure(nf) ; hold on ; fs=18;
xmin=min(XP)-0.5;xmax=max(XP)+0.5;
ymin=min(YP)-0.5;ymax=max(YP)+0.5;
axis([xmin,xmax,ymin,ymax]);
% b) curve display 
color='r';pchar='P';pcolor='b';ptrait='--';
CAGD_tbezier(X,Y,color,XP,YP,pchar,pcolor,ptrait)
title('B�zier curve','FontSize',fs); hold off ;