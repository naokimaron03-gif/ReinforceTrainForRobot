function in = walkerResetFcn(in, varargin)
    % この関数は、各エピソードの開始時に呼ばれます。

    % ここに、ロボットの初期位置や初期角度を
    % 設定する処理を記述します。

    Randomize_Angle = randn([6 1]);
        
    in = setVariable(in, 'HipRadInit_R', Randomize_Angle(1));
    in = setVariable(in, 'HipRadInit_L', Randomize_Angle(2));
    in = setVariable(in, 'KneeDegInit_R', Randomize_Angle(3));
    in = setVariable(in, 'KneeDegInit_L', Randomize_Angle(4));
    in = setVariable(in, 'AnkleDegInit_R', Randomize_Angle(5));
    in = setVariable(in, 'AnkleDegInit_L', Randomize_Angle(6));
end