%               File:    truss_problem_2_data.m
%
% The following variables are declared as global in order
% to be used by all the functions (M-files) constituting 
% the program
%
global nnd nel nne nodof eldof n
global geom connec prop nf load
%
format short e
%
%%%%%%%%%%%%%% Beginning of data input %%%%%%%%%%%%%%%%
%
nnd = 6; % Number of nodes:
nel = 9; % Number of elements:
nne = 2 ; % Number of nodes per element:
nodof =2 ; % Number of degrees of freedom per node
eldof = nne*nodof; % Number of degrees of freedom 
                   % per element
%
% Nodes coordinates X and Y
geom=zeros(nnd,2);
geom = [   0.      0.; ...   % X and Y coord. node 1
        2400.   1800.; ...   % X and Y coord. node 2
        2400.   5400.; ...   % X and Y coord. node 3
        4800.   3600.; ...   % X and Y coord. node 4
        4800.   5400.; ...   % X and Y coord. node 5
        7200.   5400.];      % X and Y coord. node 6
%
% Element connectivity
%
connec=zeros(nel,2);
connec = [1    2 ; ...    % 1st and 2nd node of element 1
          1    3 ; ...    % 1st and 2nd node of element 2
          2    3 ; ...    % 1st and 2nd node of element 3
          2    4 ; ...    % 1st and 2nd node of element 4
          3    4 ; ...    % 1st and 2nd node of element 5
          3    5 ; ...    % 1st and 2nd node of element 6
          4    5 ; ...    % 1st and 2nd node of element 7
          5    6 ; ...    % 1st and 2nd node of element 8
          4    6 ]  ;     % 1st and 2nd node of element 9
%
% Geometrical properties
%
% prop(1,1) = E; prop(1,2)= A
%
prop=zeros(nel,2);
prop  = [30000.      20000.; ...   % E and A of element 1
         30000.      20000.; ...   % E and A of element 2
         30000.      20000.; ...   % E and A of element 3
         30000.      20000.; ...   % E and A of element 4
         30000.      20000.; ...   % E and A of element 5
         30000.      20000.; ...   % E and A of element 6
         30000.      20000.; ...   % E and A of element 7
         30000.      20000.; ...   % E and A of element 8
         30000.      20000.];      % E and A of element 9
%
% Boundary conditions
%
nf = ones(nnd, nodof); % Initialise the matrix nf to 1
nf(1,2) =0 ;               % Prescribed nodal freedom of node 1
nf(6,1)= 0 ; nf(6,2)= 0 ;  % Prescribed nodal freedom of node 6
%
% Counting of the free degrees of freedom
%
n=0;
for i=1:nnd
    for j=1:nodof
        if nf(i,j) ~= 0
        n=n+1;
        nf(i,j)=n;
        end
    end
end
%
% loading
%
load = zeros(nnd, 2);
load(2,:)=[0.     -10000.];  %forces in X and Y directions at node 2
load(3,:)=[-7500       0.];  %forces in X and Y directions at node 3
load(4,:)=[0.     -10000.];  %forces in X and Y directions at node 4

%
%%%%%%%%%%%%%%%%%%%%%%% End of input %%%%%%%%%%%%%%%%%%%%%%