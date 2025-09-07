function in = walkerResetFcn(in, varargin)
    % この関数は、各エピソードの開始時に呼ばれます。

    % ここに、ロボットの初期位置や初期角度を
    % 設定する処理を記述します。

    %% 各部品のサイズとWorldFrameに対する相対位置の設定

    AncleDegLowerLim = -5;
    AncleDegUpperLim = 5;
    AncleDegInit = (AncleDegUpperLim - AncleDegLowerLim) * rand() + AncleDegLowerLim;
    % AncleTorqueInit = (AncleDegUpperLim - AncleDegLowerLim) * rand() + AncleDegLowerLim;

    in = setVariable(in, 'AncleDegInit', AncleDegInit);
    % in = setVariable(in, 'AncleTorqueInit', AncleTorqueInit);

end