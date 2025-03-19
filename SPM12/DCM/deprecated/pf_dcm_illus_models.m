function pf_dcm_illus_models(name,DCMa,DCMc,DCMb,ROIs,DCMinh,inp,savedir)
%
% FP_illus_models(name,DCMa,DCMc,savedir) visualizes your defined 
% DCM model. It's very hard to program a visualization tool that works 
% properly for every model, so play with the  conf.coor.Xplace/Yplace 
% configurations to make it nice. The input for this function should be:
%       - name: string containing your model name
%       - DCMa: the fixed connections (as defined in DCM.a)
%       - DCMc: the DCMc to your VOI's (as defined in DCM.c)
%       - DCMb: the connections which are modulated by your input (as
%                     defined in DCM.b)
%       - ROIs: Names of your Regions of Interest
%       - DCMinh:  Only if you defined a two state model and inhibitory
%                  connections (see Kahan et al, Brain 2014)
%       - Cond: Names of your conditions
%       - savedir: if you define this, your figure will be saved there. If
%                  not, nothing will be saved

% Created by Michiel Dirkx, 2014
% contact: michieldirkx@gmail.com
% $ParkFunC

%% Warming Up

if nargin < 1
    name    =   'no name specified';
end

if nargin < 2   % The fixed connections of your model (DCM.a)
    DCMa = [1 1 0 0;              
            1 1 1 0;              
            0 1 1 1;              
            0 1 0 1];
end

if nargin < 3   % the input to your VOI's (DCM.c)
    DCMc = [1 0; 0 0; 0 0; 0 0];
end

if nargin < 4   % The modulated connections by your input (DCM.b)
    DCMb(:,:,1) = [0 0 0 0;
                   0 0 0 0;
                   0 0 0 0;
                   0 0 0 0];
    DCMb(:,:,2) = [1 1 0 0;
                   1 0 1 0;
                   0 1 1 0;
                   0 0 0 0];               
end

if nargin < 5
    ROIs =  {'GPi';                            
             'MC';
             'VLT';
             'CBLM';};
end

if nargin < 6
    DCMinh  =   {''};
end

if nargin < 7
    inp    =   {'EMGRegr';                             
                'COCO'   ;};  
end

if nargin < 8
    savedir    =   '';
end


%% Configuration

% --- Directories --- %

conf.dir.save   = savedir;

% --- Volumes of Interest --- %

conf.VOI.name       = ROIs;

% --- VOI coordinates in figure --- %

conf.coor.Xplace    = [
%                       1 4; %GPe
%                       8 12; %STN
%                       16 20; %GPi
                      27 33; %MC
                      15 20; %VLpv
                      35 40; %CBLM
%                       16 20; %COCO
%                       40 46; %OP4/CBLM2
%                       40 46 ; %Muscle
%                         1   4; %MUSCLE
%                         1   4; %OP4/CBLM2   
                      ];
conf.coor.Yplace    = [
%                         8 10; %GPe
%                         8 10; %STN
%                         5 7 ; %GPi
                       18 20; %MC
                       6 9; %VLpv
                       11 13; %CBLM
%                        5 7  ; %COCO
%                        19 21; %Muscle
%                        15 17; %OP4/CBLM2
%                         7    9; %MUSCLE    
%                         15  17; %OP4/CBLM2
                       ];

% --- Model Information --- %

conf.model.name     = name;
conf.model.space    = DCMa;
conf.model.input    = DCMc;
conf.model.mod      = DCMb;

%% Make figures

% ---Setting Loop lengths--- %

nVOI	 = length(conf.VOI.name);
nInput   = length(conf.model.input(1,:));
if ~isempty(DCMb)
    nMod     = size(DCMb);
    if length(nMod)>2
        nMod     = nMod(3);
    else
        nMod     = 1;
    end
else
    nMod     = 0;
end

% --- Warnings  ----%

if length(conf.model.space(:,1)) ~= nVOI
    warning('mkModel:nModelmismatch','The number of names of the models do not match the model space you defined');
end

% --- Illustrate VOI's ---%

figure
axis([0 max(max(conf.coor.Xplace))*1.2 0 max(max(conf.coor.Yplace)) + 5.25])
for i = 1:nVOI          
    text(conf.coor.Xplace(i,1),conf.coor.Yplace(i,1),conf.VOI.name{i},'fontsize',12)
    hp = patch([conf.coor.Xplace(i,1)-0.5 conf.coor.Xplace(i,2)+1 conf.coor.Xplace(i,2)+1 conf.coor.Xplace(i,1)-0.5],[conf.coor.Yplace(i,1)-1 conf.coor.Yplace(i,1)-1 conf.coor.Yplace(i,2)-0.5 conf.coor.Yplace(i,2)-0.5],'k');
    set(hp,'EdgeColor','k','FaceColor','none') 
end

% --- Illustrate connections corresponding to model ---%

for h = 1:nVOI                      % To get all target regions  
    
    CurTarget = conf.VOI.name{h};   % The target region
    
    % ---- Draw connections  ---- %
    
    for j = 1:nVOI                  % Determine connection for every other region
        
        CurVOI      =   conf.VOI.name{j};
        CurConnect  =   conf.model.space(h,j);
        
        clear CurMod
        for a = 1:nMod
            CurMod(a)   =   conf.model.mod(h,j,a);
            CurCond     =   inp{a};
        end
        col         =   'k';    % Standard color
        
        % --- Determine if inhibitory connection --- %
        
        if ~isempty(DCMinh{:})
        for a = 1:length(DCMinh)
            if DCMinh{a} == [h j];
                col = 'b';      % inhibitory color
            end
        end
        end
        
        % ---- Get start/stop coordinates for arrow ---- %
        
        start   =   [mean(conf.coor.Xplace(j,:)) mean(conf.coor.Yplace(j,:))];
        stop    =   [mean(conf.coor.Xplace(h,:)) mean(conf.coor.Yplace(h,:))];            
       
        % -- Draw fixed connection -- %
        
        if h == j && CurConnect == 0    
            warning('mkModel:selfconnect',['The VOI ' CurTarget ' does not have a connection with itself'])
        elseif h == j && CurConnect == 1
            % Don't draw self connection
        elseif h ~= j && CurConnect == 1
            arrow(start,stop,'Length',10,'FaceColor',col)
        end
        
        % -- Draw modulated connection -- %
        
        if any(CurMod)
            
            for b = 1:sum(CurMod(:)==1)
            
            id    = find(CurMod);
            
            addstart = 3;   % Position tweakers
            addstop  = 0.5;

            if ( strcmp(CurTarget,'VIM') == 1 && strcmp(CurVOI,'CBLM') == 1 ) || ( strcmp(CurTarget,'CBLM') == 1 && strcmp(CurVOI,'VIM') == 1 )
                Start   =   [(abs(start(1)-stop(1))/2 + min([start(1) stop(1)]) )  (abs(start(2)-stop(2))/2 + min([start(2) stop(2)]) )-addstart];
                Stop    =   [(abs(start(1)-stop(1))/2 + min([start(1) stop(1)]) )    (abs(start(2)-stop(2))/2 + min([start(2) stop(2)])-addstop )];
            else 
                Start   =   [(abs(start(1)-stop(1))/2 + min([start(1) stop(1)]) )+addstart  (abs(start(2)-stop(2))/2 + min([start(2) stop(2)]) )];
                Stop    =   [(abs(start(1)-stop(1))/2 + min([start(1) stop(1)]) )+addstop    (abs(start(2)-stop(2))/2 + min([start(2) stop(2)]) )]; 
            end
            arrow(Start,Stop,'Length',10);
            
            if conf.model.mod(j,h,id(b)) == 0 || (conf.model.mod(j,h,id(b)) == 1 && j==h)
               text(min([Start(1) Stop(1)]),Stop(2)-1,[ CurVOI '>' CurTarget])
            elseif conf.model.mod(j,h,id(b)) == 1 && h > j
               text(min([Start(1) Stop(1)]),Stop(2)-1,[ CurVOI '<>' CurTarget])
            end
            
            text(min([Start(1) Stop(1)]),Start(2)-1.5,CurCond)
            
            end
        end
        
    end
    
    % ---- Draw the input to the Target Region ---%
    
    for k = 1:nInput
        
        CurCond = inp{k};
        
        if conf.model.input(h,k) == 1 && strcmp(CurTarget,'MC')
            start   =   [mean(conf.coor.Xplace(h,:)) conf.coor.Yplace(h,2)+5];
            stop    =   [mean(conf.coor.Xplace(h,:)) conf.coor.Yplace(h,2)];
            text(mean(conf.coor.Xplace(h,:))+1,mean([start(2) stop(2)]),CurCond)
            arrow(start,stop,'Length',10)
        elseif conf.model.input(h,k) == 1
            start   =   [mean(conf.coor.Xplace(h,:)) conf.coor.Yplace(h,1)-6.5];
            stop    =   [mean(conf.coor.Xplace(h,:)) conf.coor.Yplace(h,1)-1.5];
            text(mean(conf.coor.Xplace(h,:))+1,mean([start(2) stop(2)]),CurCond)
            arrow(start,stop,'Length',10)
        end
    end
    
end
title(conf.model.name,'Interpreter','none','fontweight','b','fontsize',10)
 
if isempty(savedir) == 0
    saveas(gcf,fullfile(conf.dir.save,conf.model.name),'jpg')
end
        
    
    
    
    
    



    
    




