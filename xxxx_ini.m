TibiaHeight = 0.25;
TibiaRadius = 0.05;

% 膝角度
% 0 ~ 90 [°]
KneeDegInit = 15; % 5 * rand();
KneeRadInit = KneeDegInit * pi / 180;

FemurHeight = 0.25;
FemurRadius = 0.05;

% 股関節角度
% -90 ~ 90 [°]
HipDegInit = 15; % randi([-5 5]);
HipRadInit = HipDegInit * pi / 180;

PelvisRadius = 0.15;
PelvisHeight = 0.05;

AncleDegInit = -(HipDegInit + KneeDegInit);

FootWidth = 0.1;
FootDepth = 0.25;
FootHeight = 0.05;

FootRadius = 1e-5;

PelvisVerticalPositionInit = FemurHeight * cos(HipRadInit) ...
                           + TibiaHeight * cos(HipRadInit + KneeRadInit) ...
                           + FootHeight ...
                           + FootRadius;

PelvisHorizontalPositionInit = FemurHeight * sin(HipRadInit) ...
                             + TibiaHeight * sin(HipRadInit + KneeRadInit);

% PelvisPositionInit1 = FemurHeight * cos(HipRadInit) ...
%                    + TibiaHeight * cos(HipRadInit + KneeRadInit) ...
%                    + FootHeight ...
%                    + FootRadius;
Dencity = 4430;

%% 地面
stiffness = 1e6;
Damping = 1e4;