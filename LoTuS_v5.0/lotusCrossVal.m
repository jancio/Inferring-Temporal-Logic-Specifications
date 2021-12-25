function [cv_results] = lotusCrossVal(traces_type, max_tree_depth, primitives_set)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inferring Temporal Logic Specifications for Robot-Assisted Feeding in Social Dining Settings
%
% Jan Ondras (janko@cs.cornell.edu, jo951030@gmail.com)
% Project for Program Synthesis (CS 6172)
% Cornell University, Fall 2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LoTuS cross-validation function (called from Python)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dataset_path_prefix = '/home/janko/projects/social-dining/data/processed/traces/';
load(strcat(dataset_path_prefix, traces_type, '.mat'), 'data')

num_folds = 5;
rng(47);

% Create k-fold partitions
data_parts = kRandomPartition(data, num_folds);
[train_data, test_data] = kFoldTrainTest(data_parts);

% Perform cross-validation
formulas = strings();
train_conf_mats = zeros(num_folds, 2, 2);
test_conf_mats = zeros(num_folds, 2, 2);
formulas_pruned = strings();
train_conf_mats_pruned = zeros(num_folds, 2, 2);
test_conf_mats_pruned = zeros(num_folds, 2, 2);
for i = 1:num_folds
    % Build the decision tree
    tic();
    trees(i) = buildTreeSup(train_data(i), 'max_depth', max_tree_depth, ...
                                           'frac_same', 0.98, ...
                                           'min_nobj', 5, ...
                                           'primset', primitives_set);
    times(i) = toc();

    % Post-completion tree pruning
    tree_pruning_sequence = pruningConstructTreeSeq(trees(i));
    trees_pruned(i) = pruningSelectBestTree_Sup(tree_pruning_sequence, test_data(i));

    % Get formula from the tree
    formulas(i) = treeToFormulaStrR(trees(i));
    formulas_pruned(i) = treeToFormulaStrR(trees_pruned(i));

    % Evaluate
    [train_mcrs(i), train_conf_mats(i,:,:)] = treeEvalPerformance(trees(i), train_data(i));
    [test_mcrs(i), test_conf_mats(i,:,:)] = treeEvalPerformance(trees(i), test_data(i));
    [train_mcrs_pruned(i), train_conf_mats_pruned(i,:,:)] = treeEvalPerformance(trees_pruned(i), train_data(i));
    [test_mcrs_pruned(i), test_conf_mats_pruned(i,:,:)] = treeEvalPerformance(trees_pruned(i), test_data(i));

end

cv_results.num_folds = num_folds;
cv_results.max_tree_depth = max_tree_depth;
cv_results.traces_type = traces_type;
cv_results.times = times;

%cv_results.trees = trees;
cv_results.formulas = formulas;
cv_results.train_mcrs = train_mcrs;
cv_results.test_mcrs = test_mcrs;
cv_results.train_conf_mats = train_conf_mats;
cv_results.test_conf_mats = test_conf_mats;

%cv_results.trees_pruned = trees_pruned;
cv_results.formulas_pruned = formulas_pruned;
cv_results.train_mcrs_pruned = train_mcrs_pruned;
cv_results.test_mcrs_pruned = test_mcrs_pruned;
cv_results.train_conf_mats_pruned = train_conf_mats_pruned;
cv_results.test_conf_mats_pruned = test_conf_mats_pruned;

% Stats

cv_results.times_mean = mean(times);
cv_results.times_std = std(times);

cv_results.train_mcrs_mean = mean(train_mcrs);
cv_results.train_mcrs_std = std(train_mcrs);
cv_results.test_mcrs_mean = mean(test_mcrs);
cv_results.test_mcrs_std = std(test_mcrs);
cv_results.train_conf_mats_sum = sum(train_conf_mats);
cv_results.test_conf_mats_sum = sum(test_conf_mats);

cv_results.train_mcrs_pruned_mean = mean(train_mcrs_pruned);
cv_results.train_mcrs_pruned_std = std(train_mcrs_pruned);
cv_results.test_mcrs_pruned_mean = mean(test_mcrs_pruned);
cv_results.test_mcrs_pruned_std = std(test_mcrs_pruned);
cv_results.train_conf_mats_pruned_sum = sum(train_conf_mats_pruned);
cv_results.test_conf_mats_pruned_sum = sum(test_conf_mats_pruned);

end
