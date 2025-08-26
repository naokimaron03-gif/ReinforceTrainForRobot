% 学習オプションの設定
maxEpisodes = 5000;
maxSteps = floor(Tf/Ts);
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',maxEpisodes,...
    'MaxStepsPerEpisode',maxSteps,...
    'ScoreAveragingWindowLength',100,...
    'Verbose',false,...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',200,...
    'UseParallel', true);

% 学習の実行
trainingStats = train(agentObj,env,trainOpts);

% 1. 日時を指定したフォーマットの文字列に変換
%    'yyyy' -> 年 (4桁)
%    'mm'   -> 月 (2桁)
%    'dd'   -> 日 (2桁)
%    'HH'   -> 時 (24時間表記, 2桁)
%    'MM'   -> 分 (2桁)
%    'SS'   -> 秒 (2桁)
currentTimeStr = string(datetime('now'), 'yyyyMMdd_HHmmss');
% 例: '2025_08_23_235015' のような文字列が生成されます

% 2. ファイル名を組み立てる
filename = 'bipedAgent_'+ currentTimeStr + '.mat';
% 例: 'bipedAgent_2025_08_23_235015.mat'

% 3. 組み立てたファイル名でエージェントを保存する
save(filename, 'agentObj');

% 4. 保存したファイル名を確認のために表示する（任意）
fprintf('Agent has been saved to: %s\n', filename);