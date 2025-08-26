function agent = createPPOAgent(obsInfo, actInfo, ppoParams)
%==========================================================================
% [ファイル名] createPPOAgent.m
% -------------------------------------------------------------------------
% [処理の目的]
%   この関数は、MATLAB Reinforcement Learning Toolbox™ を使用して、
%   Proximal Policy Optimization (PPO) アルゴリズムに基づく強化学習エージェントを
%   体系的に作成することを目的とします。
%   
%   GUIアプリや他のスクリプトから呼び出されることを想定しており、
%   エージェント作成に関する複雑なロジックをカプセル化（一つにまとめる）することで、
%   コードの再利用性と保守性を高めます。
%
% -------------------------------------------------------------------------
% [構文]
%   agent = createPPOAgent(obsInfo, actInfo, ppoParams)
%
% -------------------------------------------------------------------------
% [入力引数]
%   1. obsInfo (ObservationInfoオブジェクト)
%      - 目的: 学習環境の「観測空間」の仕様を定義します。
%      - 内容: 観測信号の次元数、データ型、範囲などの情報を含みます。
%      - 取得方法: `getObservationInfo(env)` を用いて環境オブジェクトから取得します。
%
%   2. actInfo (ActionInfoオブジェクト)
%      - 目的: 学習環境の「行動空間」の仕様を定義します。
%      - 内容: エージェントが出力する行動信号の次元数、データ型、上限・下限値などの情報を含みます。
%      - 取得方法: `getActionInfo(env)` を用いて環境オブジェクトから取得します。
%
%   3. ppoParams (構造体)
%      - 目的: PPOアルゴリズムの挙動を制御するハイパーパラメータを格納します。
%      - 内容: 以下のフィールドを持つことが期待されます。
%          - SampleTime: エージェントのサンプル時間
%          - ExperienceHorizon: 学習データを収集するステップ数
%          - ClipFactor: 方策の更新幅を制限し学習を安定させる係数
%          - EntropyLossWeight: 探索を促進するためのエントロピー項の重み
%          - MiniBatchSize: 1回の学習更新で使用するデータサイズ
%          - NumEpoch: 収集したデータセットを繰り返し学習する回数
%          - ActorLearnRate: アクターネットワークの学習率
%          - CriticLearnRate: クリティックネットワークの学習率
%
% -------------------------------------------------------------------------
% [出力引数]
%   - agent (rlPPOAgentオブジェクト)
%      - 目的: 学習に使用できる、設定済みのPPOエージェントです。
%      - 内容: アクター、クリティック、および学習アルゴリズムのオプションを含みます。
%
%==========================================================================


%% ========================================================================
%  ブロック1: アクターとクリティックのニューラルネットワーク定義
% -------------------------------------------------------------------------
% [処理の目的]
%   エージェントの「頭脳」となる2つの深層学習モデル（ニューラルネットワーク）の
%   構造を定義します。PPOはActor-Critic手法に基づいているため、以下の2つが必要です。
%   - アクター(Actor): 現在の状態を見て、次にとるべき「行動」を決定する。
%   - クリティック(Critic): 現在の状態が将来的にどれくらいの報酬をもたらすかの「価値」を評価する。
%
% [処理内容]
%   ここでは、アクターとクリティックで初期の層を共有する構造を採用します。
%   これにより、観測データから共通の特徴量を効率的に抽出できます。
%==========================================================================

% --- 共通入力パスの定義 ---
% [処理内容] 観測データを入力とし、中間的な特徴量を計算するネットワーク層を定義します。
commonPath = [
    % 入力層: 環境からの観測データをネットワークに入力します。
    % 'obsInfo.Dimension(1)'で観測ベクトルのサイズを自動で設定します。
    featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'observation')
    
    % 中間層1 (全結合層 + 活性化関数)
    fullyConnectedLayer(128, 'Name', 'fc1') % 128個のニューロンを持つ層
    reluLayer('Name', 'relu1')              % ReLU活性化関数で非線形性を導入
    
    % 中間層2 (全結合層 + 活性化関数)
    fullyConnectedLayer(128, 'Name', 'fc2') % さらに特徴量を抽出
    reluLayer('Name', 'relu2')
];

% --- クリティックネットワークの定義 ---
% [処理の目的] 状態の価値を評価するネットワークを作成します。
% [入力] 環境の状態 (観測)
% [出力] その状態の価値を示す単一のスカラー値
% [処理内容] 共通パスの出力に、最終的な価値を出力するための全結合層を1つ追加します。
criticNetwork = [
    commonPath
    fullyConnectedLayer(1, 'Name', 'critic_output') % 出力ニューロンは1つ（状態価値）
];

% --- アクターネットワークの定義 ---
% [処理の目的] 状態に基づいて行動を決定する方策ネットワークを作成します。
% [入力] 環境の状態 (観測)
% [出力] 連続値行動の確率分布（ガウス分布）を決定するパラメータ（平均と標準偏差）
% [処理内容] 共通パスの出力に、最終的なパラメータを出力するための全結合層を追加します。
% 出力サイズは行動の次元数の2倍です（各行動次元に対して平均と標準偏差のペアが必要なため）。

% layerGraphの初期化と共通層の追加
actorNetwork =layerGraph(commonPath);

% 平均を出力するブランチ
meanBranch = fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'mean_output');

% 標準偏差を出力するブランチ
stdBranch = [
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'std_fc_output')
    softplusLayer('Name', 'std_output');
];

% グラフにブランチを追加
actorNetwork = addLayers(actorNetwork, meanBranch);
actorNetwork = addLayers(actorNetwork, stdBranch);

% 共通部分の出力を、2つのブランチの入力に接続
actorNetwork = connectLayers(actorNetwork, 'relu2', 'mean_output');
actorNetwork = connectLayers(actorNetwork, 'relu2', 'std_fc_output');

% dlnetworkに変換
actorNetwork = dlnetwork(actorNetwork);

%% ========================================================================
%  ブロック2: アクターとクリティックの「表現オブジェクト」を作成
% -------------------------------------------------------------------------
% [処理の目的]
%   ブロック1で定義した純粋なネットワーク構造（層のリスト）を、Reinforcement 
%   Learning Toolboxが解釈できる「アクター」および「クリティック」オブジェクトに
%   変換します。このオブジェクトは、ネットワークと環境仕様を紐づける役割を持ちます。
%==========================================================================

% --- クリティック表現の作成 ---
% [入力] criticNetwork (ネットワーク構造), obsInfo (観測仕様)
% [出力] critic (rlValueRepresentationオブジェクト)
% [処理内容] rlValueRepresentation関数を使い、状態価値を評価するクリティックを作成します。
critic = rlValueRepresentation(criticNetwork, obsInfo, 'Observation', {'observation'});

% --- アクター表現の作成 ---
% [入力] actorNetwork (ネットワーク構造), obsInfo (観測仕様), actInfo (行動仕様)
% [出力] actor (rlContinuousGaussianActorオブジェクト)
% [処理内容] rlContinuousGaussianActor関数を使い、連続値行動のためのアクターを作成します。
% このアクターは、ガウス分布（正規分布）に従って行動を確率的に選択します。
actor = rlContinuousGaussianActor(actorNetwork, obsInfo, actInfo, 'ActionMeanOutputNames', 'mean_output', 'ActionStandardDeviationOutputNames', 'std_output');

%% ========================================================================
%  ブロック3: PPOエージェントのオプションを設定
% -------------------------------------------------------------------------
% [処理の目的]
%   PPOアルゴリズムの学習プロセスを制御する様々なハイパーパラメータを設定します。
%   これらのパラメータは学習の安定性、速度、最終的な性能に大きく影響します。
%
% [入力] ppoParams (GUIやスクリプトから渡されるハイパーパラメータ構造体)
% [出力] agentOpts (rlPPOAgentOptionsオブジェクト)
%==========================================================================
agentOpts = rlPPOAgentOptions(...
    'SampleTime', ppoParams.Ts, ...
    'ExperienceHorizon', ppoParams.ExperienceHorizon, ...
    'ClipFactor', ppoParams.ClipFactor, ...
    'EntropyLossWeight', ppoParams.EntropyLossWeight, ...
    'MiniBatchSize', ppoParams.MiniBatchSize, ...
    'NumEpoch', ppoParams.NumEpoch, ...
    'ActorOptimizerOptions', rlOptimizerOptions('LearnRate', ppoParams.ActorLearnRate), ...
    'CriticOptimizerOptions', rlOptimizerOptions('LearnRate', ppoParams.CriticLearnRate));


%% ========================================================================
%  ブロック4: PPOエージェントの最終的な組み立て
% -------------------------------------------------------------------------
% [処理の目的]
%   これまでに作成したアクター表現、クリティック表現、およびエージェントオプションを
%   すべて統合し、最終的なPPOエージェントオブジェクトを完成させます。
%
% [入力] actor, critic, agentOpts
% [出力] agent (rlPPOAgentオブジェクト)
%==========================================================================
agent = rlPPOAgent(actor, critic, agentOpts);

% --- 処理完了のメッセージ表示 ---
% [処理目的] この関数が正常に実行されたことをユーザーに通知します。
disp("PPOエージェントが正常に作成されました。");

end