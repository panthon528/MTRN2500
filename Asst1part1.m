% ---------------------------------------
% Example program, useful for solving Asst1, MTRN2500 T3 2019
% Original version by Jose Guivant

% ---------------------------------------
% e.g. run it this way: 
%      Asst1Example('.\data\HomeC002\');

function Asst1part1(folder)
clc();
if ~exist('folder','var')
    disp('YOU must specify the folder, where the files are located!');
    disp('We assume some default folder:');
    % We assume the follwoing default value, in case the caller does not 
    % specify its value.
    folder = '.\data\HomeC002\';
end
disp('Using data from folder:');
disp(folder);
 
% load Depth and RGB images.
A = load([folder,'\PSLR_C01_120x160.mat']); CC=A.CC ; A=[];
A = load([folder,'\PSLR_D01_120x160.mat']); CR=A.CR ; A=[];

% length
L  = CR.N;

% Some global variable, for being shared (you may use nested functions, 
% in place of using globals).
global SliderPitchHandle SliderRollHandle;%creating global handle for reseting slider
global GUIinput;%all input from UI
GUIinput=[]; 
GUIinput.flagPause=0; 
GUIinput.alignment=1;%angle correction
GUIinput.Filter=1;%useful point detection
GUIinput.SliderPitch=0;
GUIinput.SliderRoll=0;
GUIinput.Ri=0.5;%inner radius
GUIinput.Ro=1.5;%outer radius
%------------------
% We create the necessary plots/images/figures/etc.

% Create figure, where we will show Depth and RGB images.
Figure2Hand = figure(2); clf();
Figure2Hand.Position = [722 234 560 420];
% subfigure, for Depth 
subplot(211) ; 
RR=CR.R(:,:,1);
hd = imagesc(RR);
ax=axis();
title('Depth');
colormap gray;
set(gca(),'xdir','reverse');

% In another subfigure, we show the associated RGB image.
subplot(212) ; hc = image(CC.C(:,:,:,1));
title('RGB');
set(gca(),'xdir','reverse');

% .. another figure, for showing 3D points.
Figure4Hand = figure(4) ; clf() ;
Figure4Hand.Position = [50 150 672 504];
ha=axes('position',[0.22,0.10,0.75,0.85]);

hold on
hblue = plot3(ha,0,0,0,'.','markersize',2) ;%normal point graph
hred = plot3(ha,0,0,0,'.','markersize',2) ;%point of interest graph
hold off

axis([0,3,-1.5,1.5,-0.4,0.9]);
title('3D');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
grid on;
rotate3d on ;

% Some control buttons (you may define extra buttons, for other purposes)
% (you may apply some cosmetics, for improving how they look.)
%push button
uicontrol('Style','pushbutton','String','Pause/Cont.','Position',[10,1,80,20],'Callback',{@MyCallBackA,1});%pause button
uicontrol('Style','pushbutton','String','Reset Alignment','Position',[10,95,90,20],'Callback',{@MyCallBackA,2});%reset alignment button

% Slider for pitch and roll
SliderPitchHandle = uicontrol('Style','slider','Position',[10,290,40,150],'Callback',{@MyCallBackB,1},'Value',0.5);%pitch
SliderRollHandle = uicontrol('Style','slider','Position',[10,120,40,150],'Callback',{@MyCallBackB,2},'Value',0.5);%roll
%slider for inner radius and outer radious
uicontrol('Style','slider','Position',[5,60,150,20],'Callback',{@MyCallBackC,1},'Value',0.1666);%inner radius slider 
uicontrol('Style','slider','Position',[5,25,150,20],'Callback',{@MyCallBackC,2},'Value',0.5);%outer radius slider 

%check box
uicontrol('Style','checkbox','Position',[10,480,20,20],'Callback',{@MyCallBackUsefulPointsCheckBox},'Value',1);%useful point checkbox
uicontrol('Style','checkbox','Position',[10,460,20,20],'Callback',{@MyCallBackForAngleCorrectionCheckBox},'Value',1);%alignment checkbox

%text box
uicontrol('Style','text','Position',[25,480,85,15],'String',['Useful Points'],'foregroundcolor','b');
uicontrol('Style','text','Position',[34,460,85,15],'String',['Angle Correction'],'foregroundcolor','b');
%text box with number feedback
PitchHand = uicontrol('Style','text','Position',[0,440,90,15],'String',['pitch: ',num2str(GUIinput.SliderPitch,'%.1f'),'Degree'],'foregroundcolor','b');%pitch slider text
RollHand = uicontrol('Style','text','Position',[0,270,90,15],'String',['roll',num2str(GUIinput.SliderRoll,'%.1f'),'Degree'],'foregroundcolor','b');%roll slider text
in=uicontrol('Style','text','Position',[5,80,100,15],'String',['InnerRadius ',num2str(GUIinput.Ri,'%.2f'),' m'],'foregroundcolor','b');%inner radius slider text
ou=uicontrol('Style','text','Position',[5,45,100,15],'String',['OuterRadius ',num2str(GUIinput.Ro,'%.2f'),' m'],'foregroundcolor','b');%outer radius slider text
% We use HANDLES to functions, for specifying CALLBACK functions, associated to these
% control objects.

%--------------------------------------------
% Using "Helper API", just for this demo. (You need to implement those
% functions, for Asst1.)
A3D = API_Help3d() ;
% this function, here, returns a variable, which is an instance of
% a structure, which offers certain functions, via function handles.

i=0;
% Periodic loop!
while 1
    %tic;
    while (GUIinput.flagPause), pause(0.3)  ; end       %stay here, if stopped.
    i=i+1;
    if i>L, break ; end
    % Refresh RGB image, updating property 'cdata' of handle hc.
    set(hc,'cdata',CC.C(:,:,:,i));  % show RGB image
    
    RR=CR.R(:,:,i);                 % Depth image
    set(hd,'cdata',RR);             % show it.

   
    % "Processing"
    % obtain 3D points, for those pixels which are not faulty.
    iinz = find(RR>0);    %iinz=[]; <---- if empy, the function assumes ALL.
    
    % Here, we use a "LIBRARY"(an API), which was provided by the Lecturer, for
    % this test/example.
    
    
    [xx,yy,zz]=DepthTo3DPointConversion(single(RR)*0.001,iinz);%creating 3d points using depth data
    
    % (you should implement a function for this purpose, because it is part
    % of the project.)
    % The provided library is not a M file; it is a P-file, i.e. a M-file
    % after "compilation"; you can not see it source code; but you can use
    % it.
    % (Compiling M files is easy. We will see it, later.)
    
    %For angle correction toggle
    if (GUIinput.alignment == 1) 
        SliderY = GUIinput.SliderPitch-10;%defult pitch down 10 degrees
    else
        SliderY = GUIinput.SliderPitch;
    end
    
    [xx,yy,zz] = Rotate3DPoints(xx,yy,zz,GUIinput.SliderRoll,SliderY,0);%rotating 3d point
    zz = zz+0.2;%shift point cloud up by 20cm
    [xx,yy,zz] = RemovingPointOfNoInterest(xx,yy,zz);%removing point higer than 1m and lower than -5cm
    
    [xRed,yRed,zRed,xx,yy,zz] = FilteringUsefulPoint(xx,yy,zz,GUIinput.Ri ,GUIinput.Ro );%filtering useful point
    % also this functionality is needed (altough you have to do it in 3D). 
    
    
    % 
    % "A3D.ConvertSelectedDepthsTo3DPoints" is a function handle. I can use
    % it, for executing the function which is "pointed" by the handle.
    % Similarly, "A3D.Rotate2D" is another function handle.
    
    % You should not use this "helper API", in your project. You are
    % expected to implement these functions, as part of the assignment.
    
    % ......................................
    % Show the 3D points (update it associated plot, using its handle (in "hp") )
    
    %first graph(blue)
    hblue.XData = xx;
    hblue.YData = yy;
    hblue.ZData = zz;
    %second graph(red)
    hred.XData = xRed;
    hred.YData = yRed;
    hred.ZData = zRed;
    if (GUIinput.Filter)%truning on and off point of interest
        hred.Color = 'R';
    else 
        hred.Color = hblue.Color;
    end
    %Update UI numbers
    PitchHand.String = ['pitch: ',num2str(GUIinput.SliderPitch,'%.1f'),' Degree'];
    RollHand.String = ['roll: ',num2str(GUIinput.SliderRoll,'%.1f'),' Degree'];
    in.String=['InnerRadius ',num2str(GUIinput.Ri,'%.2f'),' m'];
    ou.String=['OuterRadius ',num2str(GUIinput.Ro,'%.2f'),' m'];
    
    pause(0.1);     % freeze for about 0.1 second; approximtely.
    %toc;
end

end

% ---------------------------------------
% Callback function. I defined it, and associated it to certain GUI button,
function MyCallBackA(~,~,x)   
    global GUIinput;
    global SliderPitchHandle SliderRollHandle;
    if (x==1)
       GUIinput.flagPause = ~GUIinput.flagPause; %Switch ON->OFF->ON -> and so on.
       disp(x);disp(GUIinput.flagPause);
       return;
    end
    if (x==2)%reset manual alignment
        SliderPitchHandle.Value=0.5;
        SliderRollHandle.Value=0.5;
        GUIinput.SliderPitch = 0;
        GUIinput.SliderRoll = 0;
        return;
    end
    return;    
end

% ...............................................
% I associated the following function, as a callback function for one slider control.
% Each time a new value is set, in the slider, our function is called
function MyCallBackB(a,~,x)   
    global GUIinput;
    %  When the system calls our callback function,
    %  it offers us the handle of the slider object itself, through the argument
    %  "a"
    if (x==2)%roll slider
    GUIinput.SliderRoll = get(a,'value')*90-45;
        return;
    end  
    if (x==1)%pitch slider
    GUIinput.SliderPitch = get(a,'value')*90-45;
        return;
    end
    % value of the slider (position of the selector)
    
                            % You may use it to set the value of certain relevant variable,
    % in your program.
    % Here, I just print its value, for testing purposes.
    % BTW: the object ("a"), has many other properties; you may inspect them.  
    return;    
end
function MyCallBackC(a,~,x)   
    global GUIinput;
    %  When the system calls our callback function,
    %  it offers us the handle of the slider object itself, through the argument
    %  "a"
    if (x==1)
    GUIinput.Ri = get(a,'value')*3;     % the property "value" is the current
        return;
    end  
    if (x==2)
    GUIinput.Ro = get(a,'value')*3;
        return;
    end
    % value of the slider (position of the selector)
    
                            % You may use it to set the value of certain relevant variable,
    % in your program.
    % Here, I just print its value, for testing purposes.
    % BTW: the object ("a"), has many other properties; you may inspect them.  
    return;    
end
% ---------------------------------------
% I associated this function, as a callback function for one CheckBox.
% Each time the state of the checkbx is modified, our function is called
function MyCallBackUsefulPointsCheckBox(a,~,~)
%function for useful points CheckBox
    global GUIinput;
    GUIinput.Filter = get(a,'value');
    return;    
end

function MyCallBackForAngleCorrectionCheckBox(a,~,~)
%function for Angle Correction CheckBox
    global GUIinput;
    GUIinput.alignment = get(a,'value');
    return;    
end
% --------------------------------------
function [x,y,z]=DepthTo3DPointConversion(Depths,Indices)
%Converting Depth to 3d point
    %get row and column subscript of indices
    Size = size(Depths);
    [row,column]= ind2sub(Size,Indices);
    %calculation of 3d point
    x = transpose(Depths(Indices));
    y = transpose(Depths(Indices).*(column - 80).*(4/594));
    z = transpose(-Depths(Indices).*(row - 60).*(4/592));
end

%Rotate 3d point by inputting roll pitch and yaw
function [NewX,NewY,NewZ]=Rotate3DPoints(x,y,z,ThetaX,ThetaY,ThetaZ)
    %convert degree to radian
    ThetaX = ThetaX * pi / 180;
    ThetaY = -ThetaY * pi / 180;
    ThetaZ = -ThetaZ * pi / 180;
    %creating rotation matrix
    RotatationMatrix = [cos(ThetaY)*cos(ThetaZ), -cos(ThetaX)*sin(ThetaZ)+sin(ThetaX)*sin(ThetaY)*cos(ThetaZ), sin(ThetaX)*sin(ThetaZ)+cos(ThetaX)*sin(ThetaY)*cos(ThetaZ)
                        cos(ThetaY)*sin(ThetaZ), cos(ThetaX)*cos(ThetaZ)+sin(ThetaX)*sin(ThetaY)*sin(ThetaZ), -sin(ThetaX)*cos(ThetaZ)+cos(ThetaX)*sin(ThetaY)*sin(ThetaZ)
                        -sin(ThetaY),sin(ThetaX)*cos(ThetaY),cos(ThetaX)*cos(ThetaY)];
    %creating matrix of input 3d points
    Input3DPointMatrix = [x;y;z];
    
    %Outputting and multiplying xyz
    NewX = x.*RotatationMatrix(1,1)+y.*RotatationMatrix(1,2)+z.*RotatationMatrix(1,3);
    NewY = x.*RotatationMatrix(2,1)+y.*RotatationMatrix(2,2)+z.*RotatationMatrix(2,3);
    NewZ = x.*RotatationMatrix(3,1)+y.*RotatationMatrix(3,2)+z.*RotatationMatrix(3,3);
end

function [x,y,z]=RemovingPointOfNoInterest(x,y,z)
%filter out no interest point 
    Index = z<1 & z>-0.05;% z value more than -5cm and lower that 1m
    x = x(Index);
    y = y(Index);
    z = z(Index);
end

function [xRed,yRed,zRed,xBlue,yBlue,zBlue]=FilteringUsefulPoint(x,y,z,RadiusInner,RadiusOuter)
    InputPointRadius = sqrt(x.^2 + y.^2);
    Index = InputPointRadius>RadiusInner & InputPointRadius<RadiusOuter & z >0.15;% index of point between outer and inner circle and higher than 15cm
    xRed = x(Index);
    yRed = y(Index);
    zRed = z(Index);
    xBlue = x(~Index);
    yBlue = y(~Index);
    zBlue = z(~Index);
end
% ---------------------------------------