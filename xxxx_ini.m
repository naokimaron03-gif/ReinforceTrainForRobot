clear;
clc;

%% 各部品のサイズとWorldFrameに対する相対位置の設定
% 骨盤の寸法[m]
PelvisRadius = 0.15;
PelvisHeight = 0.05;

% 骨盤関節の上限・下限
HipDegMax = 30;
HipDegMin = -30;

% 股関節角度
% HipAngleMin ~ HipAngleMax [°]
HipDegInit = (HipDegMax - HipDegMin) * rand() + HipDegMin;
HipRadInit = HipDegInit * pi / 180;

% 大腿部の寸法[m]
FemurHeight = 0.25;
FemurRadius = 0.05;

% 膝関節の上限・下限(非負値であることに注意する)

KneeDegMax = 30;
KneeDegMin = 0;

% 膝の初期角度
% KneeAngleMin ~ KneeAngleMax [°]
KneeDegInit = (KneeDegMax - KneeDegMin) * rand() + KneeDegMin;
KneeRadInit = KneeDegInit * pi / 180;

% 下腿部の寸法[m]
TibiaHeight = 0.25;
TibiaRadius = 0.05;

% 足首の初期角度
AncleDegInit = -(HipDegInit + KneeDegInit);

% 足の寸法[m]
FootWidth = 0.1;
FootDepth = 0.25;
FootHeight = 0.05;

% 足の裏の接触用の球体の寸法[m]
FootRadius = 1e-5;

% 腰の垂直方向の位置[m]
PelvisVerticalPositionInit = FemurHeight * cos(HipRadInit) ...
                           + TibiaHeight * cos(HipRadInit + KneeRadInit) ...
                           + FootHeight ...
                           + FootRadius;

% 腰の初期の水平方向の位置[m]
PelvisHorizontalPositionInit = FemurHeight * sin(HipRadInit) ...
                             + TibiaHeight * sin(HipRadInit + KneeRadInit);

%% UnitDelayの初期条件
% 初期条件が非ゼロのもののみを定義
% 要素名はUnitDelayの直前のBusCreatorから取得
InitialCondition = [];

% 腰の高さの初期条件
InitialCondition.SensorOut.PelvisHeight = PelvisVerticalPositionInit;

% 腰の前後の位置の初期条件
InitialCondition.SensorOut.LateralDistance = PelvisHorizontalPositionInit;

%% 剛体のパラメータ
% 剛体の密度
Dencity = 4430;

%% 地面
stiffness = 1e6;
Damping = 1e4;