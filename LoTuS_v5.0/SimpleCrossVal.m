%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inferring Temporal Logic Specifications for Robot-Assisted Feeding in Social Dining Settings
%
% Jan Ondras (janko@cs.cornell.edu, jo951030@gmail.com)
% Project for Program Synthesis (CS 6172)
% Cornell University, Fall 2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run cross-validation using LoTuS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Load data
dataset_path_prefix = '/home/janko/projects/social-dining/data/processed/traces/';

load(strcat(dataset_path_prefix, 'R2f_60w.mat'), 'data')

%% Shuffle data and train-test split
rng(47)
f_use = 1.0; % fraction of data to use
f_train = 0.8; % fraction of data to use for training
[train_data, test_data] = splitTrainTest(data, f_train, f_use);

%% Build the decision tree
tic()
tree = buildTreeSup(train_data, 'primset', 'setPrim1', ...
                                'optzalg', 'PS_Gen_Fast', ...
                                'max_depth', 3);
% primset: setPrim1, setPrim2, setPrim12
% objfun: 'Sup_IGc','Sup_MGc'
% optz alogs: {'PS_Gen_Fast', 'PS_Gen', 'PS', 'SimAnneal'}
total_time = toc()

%% Show formula
disp('STL formula:')
disp(treeToFormulaStrR(tree))
treeViewPrimitives(tree)

%% Show formula performance on train and test sets
[train_MCR, train_confusion_matrix] = treeEvalPerformance(tree, train_data)
[test_MCR, test_confusion_matrix] = treeEvalPerformance(tree, test_data)

%% Post-completion tree pruning
tree_pruning_sequence = pruningConstructTreeSeq(tree);
tree_pruned = pruningSelectBestTree_Sup(tree_pruning_sequence, test_data);

disp('STL formula after pruning:')
disp(treeToFormulaStrR(tree_pruned))
treeViewPrimitives(tree_pruned)
