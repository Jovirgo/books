function [p,e,q] = bsp008
% Quadrat mit Loch, 4. Quadrant, grobes Gitter
% Schwarz: beisp66.dat
% Geometriedaten: fuer Viereckelemente

% Knoten
p = [...
 0 0  ;  1   0       ;  0  1 ;  1       1  ;
 2 0  ;  0   2       ;  1  2 ;  2.17157 1.0;
 1.8 2;  0   3       ;  1  3 ;  2.6     1.8;
 0 4  ;  2.3   2.8       ;

  1  4 ;  0       5  ;
 1 5  ;  3.2 2.4     ;  2  4 ;  2       5  ;

 3.2, 3.2;  4.0 2.82843 ;  3  4 ;  3       5  ;
 5 3  ;  4   4       ;  4  5 ;  5       4  ;  5 5 ;
 1.5, 0; 1.5, 1];
p = p';

% Viereckelemente
q = [ ...
1, 2, 4, 3;
2, 30,31,4;
30, 5, 8,31;
3, 4, 7, 6;
4, 31, 9, 7;
31, 8, 12, 9;
6, 7, 11, 10;
7, 9, 14, 11; 
9, 12,18,14;
10, 11, 15,13;
11, 14, 19,15;
14, 21, 23, 19;
14, 18, 22, 21;
21, 22, 26,23;
22, 25, 28, 26;
13, 15, 17, 16;
15, 19, 20, 17;
19, 23, 24, 20;
23, 26, 27, 24;
26, 28, 29,27];
q = q';
%
e1 = [1 2 30; 2 30 5];                L1 = size(e1,2);
e2 = [5 8 12 18 22; 8 12 18 22 25];   L2 = size(e2,2);
e3 = [25 28; 28 29];                  L3 = size(e3,2);
e4 = [29 27 24 20 17; 27 24 20 17 16];L4 = size(e4,2);
e5 = [16 13 10 6 3; 13 10 6 3 1];     L5 = size(e5,2);

AUX1 = [0,1/2,3/4]; AUX2 = [1/2,3/4,1];
e1 = [e1;AUX1;AUX2;ones(1,L1)];
AUX1 = [0,[1:L2-1]]/L2; AUX2 = [1:L2]/L2;
e2 = [e2;AUX1;AUX2;2*ones(1,L2)];
AUX1 = [0,[1:L3-1]]/L3; AUX2 = [1:L3]/L3;
e3 = [e3;AUX1;AUX2;3*ones(1,L3)];
AUX1 = [0,[1:L4-1]]/L4; AUX2 = [1:L4]/L4;
e4 = [e4;AUX1;AUX2;4*ones(1,L4)];
AUX1 = [0,[1:L5-1]]/L5; AUX2 = [1:L5]/L5;
e5 = [e5;AUX1;AUX2;5*ones(1,L5)];
e = [e1,e2,e3,e4,e5];