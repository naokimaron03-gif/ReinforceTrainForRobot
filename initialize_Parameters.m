function initialize_Parameters()
    disp('パラメータを初期化しています...');
    
    %% プラントモデル
    % 下腿部の高さ[m]
    TibiaZ = Simulink.Parameter;
    TibiaZ.Value = 0.4;
    TibiaZ.Unit = 'm';
    TibiaZ.Description = '下腿部の高さ';

    % 下腿部の長さ[m]
    TibiaX = Simulink.Parameter;
    TibiaX.Value = 0.06;
    TibiaX.Unit = 'm';
    TibiaX.Description = '下腿部の長さ';
    
    % 下腿部の密度
    TibiaDencity = Simulink.Parameter;
    TibiaDencity.Value = 4430;
    TibiaDencity.Unit = 'kg/m^3';
    TibiaDencity.Description = '下腿部の密度';

    % 足首の最小角度
    AncleDegLowerLim = Simulink.Parameter;
    AncleDegLowerLim.Value = -45;
    AncleDegLowerLim.Unit = 'deg';
    AncleDegLowerLim.Description = '足首の最小角度';

    % 足首の最大角度
    AncleDegUpperLim = Simulink.Parameter;
    AncleDegUpperLim.Value = 45;
    AncleDegUpperLim.Unit = 'deg';
    AncleDegUpperLim.Description = '足首の最大角度';

    % 足首の初期角度
    AncleDegInit = Simulink.Parameter;
    AncleDegInit.Value = (10 - (-10)) * rand() + (-10);
    AncleDegInit.Unit = 'deg';
    AncleDegInit.Description = '足首の初期角度';

    % 足の幅
    FootX = Simulink.Parameter;
    FootX.Value = 0.5;
    FootX.Unit = 'm';
    FootX.Description = '足の幅';

    % 足の長さ
    FootY = Simulink.Parameter;
    FootY.Value = 0.5;
    FootY.Unit = 'm';
    FootY.Description = '足の長さ';

    % 足の高さ
    FootZ = Simulink.Parameter;
    FootZ.Value = 0.06;
    FootZ.Unit = 'm';
    FootZ.Description = '足の高さ';

    % 足の密度
    FootDencity = Simulink.Parameter;
    FootDencity.Value = 4430;
    FootDencity.Unit = 'kg/m^3';
    FootDencity.Description = '足の密度';
    
    % 足の裏の球体の半径
    BallUnderFootRad = Simulink.Parameter;
    BallUnderFootRad.Value = 1e-3;
    BallUnderFootRad.Unit = 'm';
    BallUnderFootRad.Description = '足の裏の球体の半径';

    %% シミュレーション条件
    % シミュレーション時間
    Tf = Simulink.Parameter;
    Tf.Value = 10;
    Tf.Unit = 'sec';
    Tf.Description = 'シミュレーション時間';
    
    % エージェントのサンプル時間
    Ts = Simulink.Parameter;
    Ts.Value = 1e-2;
    Ts.Unit = 'sec';
    Ts.Description = 'エージェントのサンプル時間';

    % 地面と接触の硬さ
    Stiffness = Simulink.Parameter;
    Stiffness.Value = 1e6;
    Stiffness.Unit = 'N/m';
    Stiffness.Description = '接触の硬さ';
    
    % 接触のばねの強さ
    Damping = Simulink.Parameter;
    Damping.Value = 1e4;
    Damping.Unit = 'N/(m/s)';
    Damping.Description = '接触のばねの強さ';
    
    % 
    TRW = Simulink.Parameter;
    TRW.Value = 1e-4;
    TRW.Unit = 'm';
    TRW.Description = '';

    % 初期条件
    InitialCondition = [];
    InitialCondition.PoleDeg.X_Roll = AncleDegInit.Value * pi/180;

    %% ベースワークスペースへの定義
    assignin('base', 'TibiaZ', TibiaZ);
    assignin('base', 'TibiaX', TibiaX);
    assignin('base', 'TibiaDencity', TibiaDencity);
    assignin('base', 'AncleDegLowerLim', AncleDegLowerLim);
    assignin('base', 'AncleDegUpperLim', AncleDegUpperLim);
    assignin('base', 'AncleDegInit', AncleDegInit);
    assignin('base', 'InitialCondition', InitialCondition);
    assignin('base', 'FootX', FootX);
    assignin('base', 'FootY', FootY);
    assignin('base', 'FootZ', FootZ);
    assignin('base', 'FootDencity', FootDencity);
    assignin('base', 'BallUnderFootRad', BallUnderFootRad);
    assignin('base', 'Tf', Tf);
    assignin('base', 'Ts', Ts);
    assignin('base', 'Stiffness', Stiffness);
    assignin('base', 'Damping', Damping);
    assignin('base', 'TRW', TRW);
    assignin('base', 'InitialCondition', InitialCondition);
end