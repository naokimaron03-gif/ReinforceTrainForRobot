%% PPOエージェントの設計スクリプト

% モデル開く
mdl = 'PoleCart';
open_system(mdl);

% エージェントブロックのパス
agentBlk = [mdl, '/RL Agent'];

%% 1. 環境の観測と行動の仕様を定義
% 観測空間: 6次元の連続値ベクトル
obsInfo = rlNumericSpec([12 1]);
obsInfo.Name = 'observations';

% 行動空間: 1次元の連続値（範囲: -1 ～ 1）
actInfo = rlNumericSpec([1 1]);
actInfo.Name = 'action';

% Simulink環境の作成
env = rlSimulinkEnv(mdl, agentBlk, obsInfo, actInfo);

%% 2. クリティック（価値関数）の作成
% ニューラルネットワークの構造を定義します。
% 観測を入力とし、状態の価値（スカラー）を出力します。

% ネットワーク層の定義
criticLayers = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'observation')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(128, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(1, 'Name', 'value')];

% ネットワークをlayerGraphに変換
criticNetwork = layerGraph(criticLayers);

% クリティック オブジェクトの作成
% https://jp.mathworks.com/help/reinforcement-learning/ref/rl.function.rlvaluefunction.html を参照
critic = rlValueFunction(criticNetwork, obsInfo);

%% 3. アクター（ポリシー）の作成
% ニューラルネットワークの構造を定義します。
% 観測を入力とし、行動の確率分布（この場合はガウス分布の平均と標準偏差）を出力します。
% https://jp.mathworks.com/help/reinforcement-learning/ug/create-policy-and-value-functions.html を参照
% 共通の入力層と中間層
commonLayers = [
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'observation')
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(128, 'Name', 'fc2')
    reluLayer('Name', 'relu2')];

% 平均値を出力するパス
meanPath = [
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'mean_fc')
    ];

% 標準偏差を出力するパス
stdPath = [
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'std_fc')
    softplusLayer('Name', 'softplus_std')
    ]; % 出力が常に正になるように

% ネットワークをlayerGraphに追加して接続
actorNetwork = layerGraph(commonLayers);
actorNetwork = addLayers(actorNetwork, meanPath);
actorNetwork = addLayers(actorNetwork, stdPath);

actorNetwork = connectLayers(actorNetwork, 'relu2', 'mean_fc');
actorNetwork = connectLayers(actorNetwork, 'relu2', 'std_fc');

% アクター オブジェクトの作成
% https://jp.mathworks.com/help/reinforcement-learning/ref/rl.function.rlcontinuousgaussianactor.html を参照
% 出力層の名前をそれぞれ指定します。
actor = rlContinuousGaussianActor(actorNetwork, obsInfo, actInfo, ...
    'ActionMeanOutputNames', 'mean_fc', ...
    'ActionStandardDeviationOutputNames', 'softplus_std');


%% 4. PPOエージェントの作成
% アクターとクリティックを組み合わせてPPOエージェントを作成します。
% エージェントの学習に関する詳細な設定は、rlPPOAgentOptionsで行うことができます。
agentOptions = rlPPOAgentOptions(...
    'SampleTime', Ts.Value, ...
    'ExperienceHorizon', 2048, ...
    'ClipFactor', 0.2, ...
    'EntropyLossWeight', 0.01, ...
    'MiniBatchSize', 64, ...
    'NumEpoch', 3, ...
    'AdvantageEstimateMethod', 'gae', ...
    'GAEFactor', 0.95, ...
    'ActorOptimizerOptions', rlOptimizerOptions('LearnRate', 3e-4), ...
    'CriticOptimizerOptions', rlOptimizerOptions('LearnRate', 3e-4));

agentObj = rlPPOAgent(actor, critic, agentOptions);

%% スクリプトの完了
% これで、指定された仕様に基づくPPOエージェント'agent'が作成されました。
% この後、作成したエージェントを環境で学習させるには train 関数を使用します。
% 例: trainingStats = train(agent, env);
disp("PPOエージェントの設計が完了しました。");
disp("作成されたエージェント:");
disp(agentObj);