%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation of Schmid and Escaig facotrs and plotting of Stress 
% Orientation Maps. The derivation and further details of these maps can be
% found in:

    % F.D. León-Cázares and C.M.F. Rae. A stress orientation analysis
    % framework for dislocation glide in face-centred cubic metals. 
    % Crystals, 10 (2020) 445.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
% mode          Loading mode:
%               mode = 1 -> Tension; mode = -1 -> compression;
%               mode = 2 -> Pure shear of a (111) plane; mode = -2 -> Same (opposite direction)
%               size(mode)=[3,3] -> mode = Scrystal normalised
% Fdirection    Direction of the force or shear appplied
% m             Display format (12 or 24 slip systems)
% dispT         Print options (1 -> Tr,  2 -> Tr sorted by mS)
% dispP         Plot options (select as many as needed)
%               (1->mS vs mE, 2->|mS| vs mE, 3->tau vs phi [-30,30] deg, 4->3D complete)
%
% Outputs:
% Tr            Table with the results
%  - id         Slip system identifier
%  - n          Slip normal
%  - b          Slip direction (perfect a/2<110>{111} dislocations)
%  - mS         Schmid factor
%  - mE         Escaig factor
%  - mN         Normal factor
%  - bp1        Slip direction of leading partials (a/6<112>{111} dislocations)
%  - bp2        Slip direction of trailing partials (a/6<112>{111} dislocations)
%  - mSp1       Schmid factor of bp1 leading partial
%  - mSp2       Schmid factor of bp2 trailing partial
%
% taup          Shear stresses on each (111) plane
% phi           Angle [-30deg,30deg] of the shear stress
%               phi = -30 -> pointing towards a leading partial
%               phi = 0   -> pointing towards a perfect dislocation
%               phi = 30  -> pointing towards a trailing partial
% mN            Normal factor for each (111) plane
% Scrystal      Stress tensor given in crystal reference system
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
close all

%% Input parameters
dispT = 1;                          % 1 -> Tr,  2 -> Tr sorted by mS
dispP = [1,2,3,4];                  % 1 -> mS vs mE, 2 -> |mS| vs mE, 3 -> tau vs phi [-30,30] degrees, 4 -> 3D complete

% Loading parameters - uncomment a section and 
    % Option 1 - Uniaxial tension along a given crystallographic axis
    m = 12;                         % Number of slip planes to show: 12 or 24
    mode = 1;                       % Loading mode: 1 -> Tension, -1 -> compression          
    F = [-0.14,0.42,0.89];          % Direccion of the uniaxial force applied 

    % Option 2 - Pure shear on a (111) plane
%     m = 12;                          % Number of slip planes to show: 12 or 24
%     mode = -2;                       % Loading mode: 2 -> One direction, -2 -> the other direction          
%     F = [-1,-1,2];                   % Direccion of the shear applied

    % Option 3 - For a given stress state
%     m = 12;
%     s11 = 1.5;                       % Stress components (s = normal, t = shear)
%     s22 = -0.1;
%     s33 = -0.3;
%     t12 = 0.4;
%     t13 = 0.2;
%     t23 = -0.5;
%     mode = [s11,t12,t13;...          % Scrystal - Do not change
%             t12,s22,t23;...
%             t13,t23,s33];
%     F = '';                          % Do not change

    
%% Run code
[Tr,taup,phi,mN,Scrystal] = m24(mode,F,m,dispT);               % Table with the results 


%% Plots
if sum(dispP==1)>0              % Full mS vs mE
    figure; 
    scatter(Tr.mS(1:m),Tr.mE(1:m),70,'filled')
    hold on;
    theta = 0:2*pi/1000:2*pi;
    r = sqrt(Tr.mS([1,4,7,10]).^2+Tr.mE([1,4,7,10]).^2);
    plot((r.*cos(theta))',(r.*sin(theta))','k','LineWidth',0.01)
    axis equal
    xlabel('Schmid factor')
    ylabel('Escaig factor')
    xlim([-0.55,0.55])
    ylim([-0.55,0.55])
    xticks([-0.55,0,0.55])
    yticks([-0.55,0,0.55])
    grid on
    box on
end
if sum(dispP==2)>0              % |mS| vs mE
    figure; 
    scatter(abs(Tr.mS(1:m)),Tr.mE(1:m),70,'filled')
    hold on;
    theta = 0:2*pi/1000:2*pi;
    r = sqrt(Tr.mS([1,4,7,10]).^2+Tr.mE([1,4,7,10]).^2);
    plot((r.*cos(theta))',(r.*sin(theta))','k','LineWidth',0.01)
    axis equal
    xlabel('Schmid factor')
    ylabel('Escaig factor')
    xlim([0,0.55])
    ylim([-0.55,0.55])
    xticks([0,0.5])
    yticks([-0.5,0,0.5])
    grid on
    box on
end
if sum(dispP==3)>0              % tau vs phi [-30 deg, 30 deg]
    figure
    polarscatter(phi*pi/180,taup,70,'filled')
    thetalim([-30,30])
    thetaticks([-30,0,30])
    thetaticklabels({'-30\circ','0\circ','30\circ'})
    set(gca,'FontSize',18)
    rlim([0,0.5])
    rticks(0:0.1:0.5)
%     rticklabels({'\tau'})
end
if sum(dispP==4)>0              % 3D - |mS| vs mE vs mN
    figure; 
    scatter3(abs(Tr.mS(1:m)),Tr.mE(1:m),Tr.mN(1:m),70,'filled')
    hold on;
    theta = 0:2*pi/1000:2*pi;
    r = sqrt(Tr.mS([1,4,7,10]).^2+Tr.mE([1,4,7,10]).^2);
    plot3((r.*cos(theta))',(r.*sin(theta))',Tr.mN([1,4,7,10])'.*ones(size(theta))','k','LineWidth',0.01)          
    E = sort(eig(Scrystal));
    P = 1/3*trace(Scrystal);
    [X,Y,Z] = sphere(100);                  % Sphere
    Ef = (E(3)-E(1))/2;
    Es = (E(3)+E(1))/2;
    X = X*1.01*Ef; Y = Y*1.01*Ef; Z = Z*1.01*Ef;
    NX = (X<0);
    NN = (X.^2 + Y.^2 + Z.^2) > 1.0000001;
    X(NX)=NaN; Y(NX)=NaN; Z(NX)=NaN;
    X(NN)=NaN; Y(NN)=NaN; Z(NN)=NaN;
    surf(X,Y,Z+Es,zeros([size(X),3]),'FaceAlpha',0.2)
    shading interp
    [X,Y,Z] = sphere(100);                  % Sphere
    Ef = (E(3)-E(2))/2;
    Es = (E(3)+E(2))/2;
    X = X*Ef; Y = Y*Ef; Z = Z*Ef;
    NX = (X<0);
    NN = (X.^2 + Y.^2 + Z.^2) > 1.0000001;
    X(NX)=NaN; Y(NX)=NaN; Z(NX)=NaN;
    X(NN)=NaN; Y(NN)=NaN; Z(NN)=NaN;
    surf(X,Y,Z+Es,zeros([size(X),3]),'FaceAlpha',0.2)
    shading interp
    [X,Y,Z] = sphere(100);                  % Sphere
    Ef = (E(2)-E(1))/2;
    Es = (E(2)+E(1))/2;
    X = X*Ef; Y = Y*Ef; Z = Z*Ef;
    NX = (X<0);
    NN = (X.^2 + Y.^2 + Z.^2) > 1.0000001;
    X(NX)=NaN; Y(NX)=NaN; Z(NX)=NaN;
    X(NN)=NaN; Y(NN)=NaN; Z(NN)=NaN;
    surf(X,Y,Z+Es,zeros([size(X),3]),'FaceAlpha',0.2)
    shading interp

    axis equal
    xlabel('Schmid factor')
    ylabel('Escaig factor')
    zlabel('Normal factor')
    xlim([0,0.55])
    ylim([-0.55,0.55])
    zlim([-1.05,1.05])
    xticks([0,0.5])
    yticks([-0.5,0,0.5])
    zticks([-1,0,1])
    grid on
    box on
    view(42,15)
end
