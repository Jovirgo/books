%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%    An Introduction to Scientific Computing          %%%%%%%
%%%%%%%    I. Danaila, P. Joly, S. M. Kaber & M. Postel     %%%%%%%
%%%%%%%                 Springer, 2005                      %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%===============================================
% Superposition of individual temperature fields
%   linear problem
%===============================================

if(exist('Ram')==1);clear Ram;end; % amplification factor of the resistances cleared
Ram(1:NbR)=1;     % default amplification factors
Ramin=1;Ramax=10;

sfg3=whos('fg3');if(size(sfg3,1)~=0);close(fg3);end
%---------Construction of sliders
%=======================================

frm1Pos=get(a,'Position');
frm2Pos=get(fg2,'Position');
frm3Pos=[frm2Pos(1) frm1Pos(2) frm2Pos(3) frm1Pos(4)-frm2Pos(4)-3*betwM-topM];

fg3 = figure('Units','pixels',...
   'NumberTitle','off',...
   'Name','Command panel',...
   'Position',frm3Pos);


slW=(frm3Pos(3)-2)/(4*NbR-1);
slH=butH*0.75;

sly=frm3Pos(4);
slx=2;

for k=1:NbR
   
b = uicontrol('Units','pixels',...
   'Parent',fg3,...
   'Style','text',...
   'Position',[slx sly-slH 3*slW slH],...
   'FontUnits','pixels',...
   'FontSize',txtH,...
   'String',['R' num2str(k)]);


slid(k) = uicontrol('Parent',fg3, ...
	'Units','pixels', ...
	'BackgroundColor',[0 1 1], ...
   'Callback','for k=1:NbR;Ram(k)=get(slid(k),''Val'');set(slidv(k),''String'',num2str(Ram(k)));end;', ...   
   'Position',[slx sly-2*slH 3*slW slH], ...
	'String','Min', ...
	'Style','slider', ...
        'Min',Ramin,'Max',Ramax,'Value',Ramin,...
	'Tag','Slider1');

slidv(k) = uicontrol('Parent',fg3, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[slx sly-3*slH 3*slW slH],...
   'FontUnits','pixels',...  
	'FontSize',slH, ...
	'BackgroundColor',[1 0.75 1], ...
	'String',num2str((get(slid(k),'Val'))));

slx=slx+3*slW+slW;
end

ssup = uicontrol('Parent',fg3, ...
	'Units','pixels', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
   'Callback',['updatej(''***********************'');'...
               'updatej(''Amplification factors for each resistance (Res/Value)'');'...
               'for k=1:NbR;Ram(k)=get(slid(k),''Val'');updatej([''R'' num2str(k) ''    '' num2str(Ram(k))]);end;'...
               'updatej(''The final temperature field is now displayed...'');'...
               'updatej(''***********************'');'...
               'updatej(''==> You can go back to the choice of physical parameters '');'...
               'updatej(''... and continue by a click on "Run case" '');'...
               'updatej(''==> or you can modify the values of resistances for the same case'');'...
               'updatej(''... and click on  "Validate" '');'...
               'updatej(''***********************'');'...
               'Tf=T0+(Ram*Tr'')'';'...
               ' figure(fg2);trisurf(I123,XYs(:,1),XYs(:,2),zeros(Ns,1),Tf);title(''Final temp field  '',''FontSize'',txtH);'...
               ' view(2);shading interp;hold on;Show_border(xb,yb,fg2);hold off;'...
               ' set(bisos,''Callback'', ''updatej(''''***********************'''');updatej([''''Computes'''' num2str(nisol) '''' iso-lines'''']);Interp_mouse(Tf,nisol,fg2);hold on;Show_border(xb,yb,fg2);hold off;title(''''Final field'''',''''FontSize'''',txtH);'');' ...
               ''], ...
	'FontSize',txtH, ...
	'ForegroundColor',[0.75 0 0], ...
	'Position',[5 5 butW slH], ...
	'String','Validate', ...
	'Tag','Pushbuttonc');


