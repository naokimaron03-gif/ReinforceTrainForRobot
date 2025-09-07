function in = walkerResetFcn(in, varargin)
    % この関数は、各エピソードの開始時に呼ばれます。

    % ここに、ロボットの初期位置や初期角度を
    % 設定する処理を記述します。

    %% 各部品のサイズとWorldFrameに対する相対位置の設定
    
    % 骨盤関節の上限・下限
    HipDegMax = 5;
    HipDegMin = -5;
    
    % 股関節角度
    % HipAngleMin ~ HipAngleMax [°]
    HipDegInit = (HipDegMax - HipDegMin) * rand() + HipDegMin;
    HipRadInit = HipDegInit * pi / 180;
    
    % 大腿部の寸法[m]
    FemurHeight = 0.25;
    
    % 膝関節の上限・下限(非負値であることに注意する)
    KneeDegMax = 5;
    KneeDegMin = 0;
    
    % 膝の初期角度
    % KneeAngleMin ~ KneeAngleMax [°]
    KneeDegInit = (KneeDegMax - KneeDegMin) * rand() + KneeDegMin;
    KneeRadInit = KneeDegInit * pi / 180;
    
    % 下腿部の寸法[m]
    TibiaHeight = 0.25;
    
    % 足の寸法[m]
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
    
    % 骨盤関節角度の初期化
    in = setVariable(in, 'HipRadInit', HipDegInit);

    % 膝関節角度の初期化
    in = setVariable(in, 'KneeDegInit', KneeDegInit);

    % 足首角度の初期化(常に地面と平行となるように骨盤と膝の角度を打ち消す)
    in = setVariable(in, 'AncleDegInit', -(HipDegInit + KneeDegInit));

    in = setVariable(in, 'InitialCondition.SensorOut.PelvisHeight', PelvisVerticalPositionInit);

    in = setVariable(in, 'InitialCondition.SensorOut.LateralDistance', PelvisHorizontalPositionInit);
end