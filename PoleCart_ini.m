
%% 下腿部
% 下腿部の寸法[m]
TibiaZ = 0.4;
TibiaX = 0.06;

% 下腿部の密度[kg/m^3]
TibiaDencity = 4430;

% 下腿部の体積[m^3]
MassTibia = TibiaX^2 *pi * TibiaZ;

% 下腿部の重さ[kg]
WeightTibia = TibiaDencity * MassTibia;

%% 足首
% 足首の可動域
AncleDegLowerLim = -45;
AncleDegUpperLim = 45;

% 足首の初期角度のクリッピング用定数
epsilon = 5;

% 足首の初期角度と初期トルク
AncleDegInit = 10;
% ((AncleDegUpperLim - epsilon) - (AncleDegLowerLim + epsilon)) * rand() + AncleDegLowerLim + epsilon;
AncleTorqueInit = 0;
% (AncleDegUpperLim - AncleDegLowerLim) * rand() + AncleDegLowerLim;

disp(AncleDegInit);
%% 足
% 足の寸法[m]
FootX = 0.1;
FootY = 0.25;
FootZ = 0.06;

% 足の密度[kg/m^3]
FootDencity = 4430;

% 足の体積[m^3]
MassFoot = FootX * FootY * FootZ;

% 足の重さ
WeightFoot = FootDencity * MassFoot;

%% 足裏球体
BallUnderFootRad = 1e-2;


Tf = 10;
Ts = 0.01;

InitCondition = [];
InitCondition.PoleDeg.X_Roll = AncleDegInit * pi/180;

AncleDegGoal = 0;

Max_Trq = 3;