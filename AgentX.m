clc;

% モデル開く
mdl = 'xxxx';
open_system(mdl);

% エージェントブロックのパス
agentBlk = [mdl, '/CalcAction/RL Agent'];

% 観測情報の使用定義
numObs = 30;
obsInfo = rlNumericSpec([numObs 1]);
obsInfo.Name = 'observations';

% 行動仕様の定義
numAct = 6;
actInfo = rlNumericSpec ([numAct 1], 'LowerLimit',-1, 'UpperLimit', 1);
actInfo.Name = 'Torques';

% Simulink環境の作成
env = rlSimulinkEnv(mdl, agentBlk, obsInfo, actInfo);

% ■ 環境のリセット関数の設定
% env.ResetFcn: 環境がリセットされる際（各エピソード開始時）に呼び出される関数を指定するプロパティ。
% @(in):       強化学習フレームワークからの入力(in)を受け取るための無名関数ハンドル。
% walkerResetFcn: ユーザーが定義した、実際のリセット処理（初期位置や角度の設定など）を行う関数。
% 'gaitType', 'random': walkerResetFcnに渡す引数。エピソードごとに初期状態をランダム化し、学習のロバスト性を高めるための設定。 
env.ResetFcn = @(in)walkerResetFcn(in, 'gaitType', 'random');

% DDPGエージェントのオプションを作成
PPOParams.Ts = 0.02;
PPOParams.ExperienceHorizon = 2048;
PPOParams.ClipFactor = 0.2;
PPOParams.EntropyLossWeight = 0.01;
PPOParams.MiniBatchSize = 64;
PPOParams.NumEpoch = 4;
PPOParams.ActorLearnRate = 1e-4;
PPOParams.CriticLearnRate = 1e-4;

Ts = PPOParams.Ts;

% アクターネットワークの作成
agentObj = createPPOAgent(obsInfo, actInfo, PPOParams);

% % アクターオブジェクトの作成
% % actorNetwork: アクターとして機能する深層学習ネットワーク (dlnetworkオブジェクト)
% % obsInfo:      環境の観測情報の仕様 (入力データの形式を定義)
% % actInfo:      環境の行動情報の仕様 (出力データの形式を定義)
% actor = rlContinuousDeterministicActor(actorNetwork, obsInfo, actInfo);
% 
% % クリティックネットワークの作成
% criticNetwork = createCriticNetwork(obsInfo, actInfo); % ネットワークを作成するヘルパー関数
% criticNetwork = dlnetwork(criticNetwork);
% 
% % ■ クリティックオブジェクトの作成 (Q値関数)
% % criticNetwork: 状態と行動を入力とし、Q値を出力する深層学習ネットワーク (dlnetworkオブジェクト)
% % obsInfo:       環境の観測情報の仕様 (入力の一部を定義)
% % actInfo:       環境の行動情報の仕様 (入力のもう一部を定義)
% critic = rlQValueFunction(criticNetwork, obsInfo,actInfo);
% 
% % エージェント作成
% agentObj = rlPPOAgent (actor, critic, agentOptions);

% 最大トルク
Max_Trq = 5;