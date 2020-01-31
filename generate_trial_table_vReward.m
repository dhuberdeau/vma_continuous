function [trial_target_numbers, trial_home_numbers, trial_type, prescribed_PT, trial_stimA, reward] = generate_trial_table_vReward(subject_code)
% subject_code = 'S025';

%% setup:

% setup pairs of stimuli that are predictable: [ A, B ]
predictable_pairs = [...
    1 1; ...
    2 1;...
    2 2;...
    3 2;...
    3 3;...
    4 3;...
    4 4;...
    1 4];
    
unpredictable_list = [5 6 7 8];

EXTRM_PT = [.6 -.3];

%% Block 0 (practice)
% Just target:
seed_targ_nums = repmat(1:4, 1, 3);
trial_target_numbers_0 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_0 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_0)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_0(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_0(i_targ) = targ_num_possibilities(coin_flip + 1);
end


trial_type_0 = ones(size(trial_target_numbers_0));

prescribed_PT_0 = linspace(.9, 0, length(trial_target_numbers_0));

trial_stimA_0 = ones(size(trial_target_numbers_0));

reward_0 = zeros(size(trial_stimA_0));
total_inds = 1:length(reward_0);
half_inds = total_inds(randperm(length(total_inds)));
half_inds = half_inds(1:floor(length(half_inds)/2));
reward_0(half_inds) = 1;

%% Block 1 (Training)
% more of Just target:
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_1 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_1 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_1)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_1(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_1(i_targ) = targ_num_possibilities(coin_flip + 1);
end

trial_type_1 = ones(size(trial_target_numbers_1));

seed_pPT = repmat(linspace(EXTRM_PT(1), EXTRM_PT(2), block_len/4), 1, 4);
prescribed_PT_1 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

trial_stimA_1 = ones(size(trial_target_numbers_1));

reward_1 = zeros(size(trial_stimA_1));
total_inds = 1:length(reward_1);
half_inds = total_inds(randperm(length(total_inds)));
half_inds = half_inds(1:floor(length(half_inds)/2));
reward_1(half_inds) = 1;

%% Block 2 (Introduce symbols - all predictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_2 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_2 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_2)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_2(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_2(i_targ) = targ_num_possibilities(coin_flip + 1);
end

trial_type_2 = 2*ones(size(trial_target_numbers_2));

seed_pPT = repmat(linspace(EXTRM_PT(1), EXTRM_PT(2), block_len/4), 1, 4);
prescribed_PT_2 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

seed_stimA = repmat(1:4, 1, block_len/4);
trial_stimA_2 = seed_stimA(randperm(length(seed_stimA)));

reward_2 = zeros(size(trial_stimA_2));
reward_2(trial_stimA_2 == 1) = 1;
reward_2(trial_stimA_2 == 2) = 1;

%% Block 3 (mix of predictable and unpredictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_3 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_3 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_3)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_3(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_3(i_targ) = targ_num_possibilities(coin_flip + 1);
end

trial_type_3 = 2*ones(size(trial_target_numbers_3));

seed_pPT = repmat(linspace(EXTRM_PT(1), EXTRM_PT(2), block_len/4), 1, 4);
prescribed_PT_3 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

% seed_stimA = nan(size(trial_target_numbers_3));
% for i_tr = 1:length(seed_stimA)
%     matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_3(i_tr), 1);
%     this_pair = matching_pairs(randperm(2));
%     seed_stimA(i_tr) = this_pair(1);
% end
% trial_stimA_3 = seed_stimA;
seed_stimA = repmat(1:4, 1, block_len/4);
trial_stimA_3 = seed_stimA(randperm(length(seed_stimA)));

reward_3 = zeros(size(trial_stimA_3));
reward_3(trial_stimA_3 == 1) = 1;
reward_3(trial_stimA_3 == 2) = 1;

%% Block 4 (mix of predictable and unpredictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_4 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_4 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_4)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_4(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_4(i_targ) = targ_num_possibilities(coin_flip + 1);
end

trial_type_4 = 2*ones(size(trial_target_numbers_4));

seed_pPT = repmat(linspace(EXTRM_PT(1), EXTRM_PT(2), block_len/4), 1, 4);
prescribed_PT_4 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

% seed_stimA = nan(size(trial_target_numbers_4));
% coin = randperm(length(seed_stimA));
% for i_tr = 1:length(seed_stimA)
% %     coin_flip = mod(coin(i_tr), 2);
% %     if coin_flip == 1
%         % make this trial predictable 
%         matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_4(i_tr), 1);
%         this_pair = matching_pairs(randperm(2));
%         seed_stimA(i_tr) = this_pair(1);
% %     else
% %         % make this trial unpredictable
% %         shuffled_list = unpredictable_list(randperm(length(unpredictable_list)));
% %         seed_stimA(i_tr) = shuffled_list(1);
% %     end
%     
% end
% trial_stimA_4 = seed_stimA;
seed_stimA = repmat(1:4, 1, block_len/4);
trial_stimA_4 = seed_stimA(randperm(length(seed_stimA)));

reward_4 = zeros(size(trial_stimA_4));
reward_4(trial_stimA_4 == 1) = 1;
reward_4(trial_stimA_4 == 2) = 1;

%% Block 5 (mix of predictable and unpredictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_5 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_5 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_5)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_5(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_5(i_targ) = targ_num_possibilities(coin_flip + 1);
end

trial_type_5 = 2*ones(size(trial_target_numbers_5));

seed_pPT = repmat(linspace(EXTRM_PT(1), EXTRM_PT(2), block_len/4), 1, 4);
prescribed_PT_5 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

% seed_stimA = nan(size(trial_target_numbers_5));
% coin = randperm(length(seed_stimA));
% for i_tr = 1:length(seed_stimA)
% %     coin_flip = mod(coin(i_tr), 2);
% %     if coin_flip == 1
%         % make this trial predictable 
%         matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_5(i_tr), 1);
%         this_pair = matching_pairs(randperm(2));
%         seed_stimA(i_tr) = this_pair(1);
% %     else
% %         make this trial unpredictable
% %         shuffled_list = unpredictable_list(randperm(length(unpredictable_list)));
% %         seed_stimA(i_tr) = shuffled_list(1);
% %     end
%     
% end
% trial_stimA_5 = seed_stimA;
seed_stimA = repmat(1:4, 1, block_len/4);
trial_stimA_5 = seed_stimA(randperm(length(seed_stimA)));

reward_5 = zeros(size(trial_stimA_5));
reward_5(trial_stimA_5 == 1) = 1;
reward_5(trial_stimA_5 == 2) = 1;

%% Block 6 (mix of predictable and unpredictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_6 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_6 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_6)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_6(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_6(i_targ) = targ_num_possibilities(coin_flip + 1);
end

trial_type_ = [ones(ceil(length(trial_target_numbers_6)/2), 1); 2*ones(floor(length(trial_target_numbers_6)/2), 1)];
% trial_type_6 = 2*ones(size(trial_target_numbers_6));
trial_type_6 = trial_type_(randperm(length(trial_type_)))';

seed_pPT = repmat(linspace(EXTRM_PT(1), EXTRM_PT(2), block_len/4), 1, 4);
prescribed_PT_6 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

% seed_stimA = nan(size(trial_target_numbers_6));
% coin = randperm(length(seed_stimA));
% for i_tr = 1:length(seed_stimA)
% %     coin_flip = mod(coin(i_tr), 2);
% %     if coin_flip == 1
%         % make this trial predictable 
%         matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_6(i_tr), 1);
%         this_pair = matching_pairs(randperm(2));
%         seed_stimA(i_tr) = this_pair(1);
% %     else
% %         % make this trial unpredictable
% %         shuffled_list = unpredictable_list(randperm(length(unpredictable_list)));
% %         seed_stimA(i_tr) = shuffled_list(1);
% %     end
%     
% end
% trial_stimA_6 = seed_stimA;
seed_stimA = repmat(1:4, 1, block_len/4);
trial_stimA_6 = seed_stimA(randperm(length(seed_stimA)));

reward_6 = zeros(size(trial_stimA_6));
reward_6(trial_stimA_6 == 1) = 1;
reward_6(trial_stimA_6 == 2) = 1;

%% Block 7 (post-test - all predictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_7 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_7 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_7)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_7(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_7(i_targ) = targ_num_possibilities(coin_flip + 1);
end

trial_type_7 = 2*ones(size(trial_target_numbers_7));

seed_pPT = repmat(linspace(EXTRM_PT(1), EXTRM_PT(2), block_len/4), 1, 4);
prescribed_PT_7 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

seed_stimA = nan(size(trial_target_numbers_7));
for i_tr = 1:length(seed_stimA)
    matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_7(i_tr), 1);
    this_pair = matching_pairs(randperm(2));
    seed_stimA(i_tr) = this_pair(1);
end
trial_stimA_7 = seed_stimA;

%% Block 8 (post-test w/ arc targets - all predictable)
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_8 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_8 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_8)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_8(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_8(i_targ) = targ_num_possibilities(coin_flip + 1);
end

trial_type_ = [ones(ceil(length(trial_target_numbers_8)/2), 1); 2*ones(floor(length(trial_target_numbers_8)/2), 1)];
% trial_type_6 = 2*ones(size(trial_target_numbers_6));
trial_type_8 = trial_type_(randperm(length(trial_type_)))';
% trial_type_8 = 2*ones(size(trial_target_numbers_8));

seed_pPT = repmat(linspace(EXTRM_PT(1), EXTRM_PT(2), block_len/4), 1, 4);
prescribed_PT_8 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

seed_stimA = nan(size(trial_target_numbers_8));
for i_tr = 1:length(seed_stimA)
    matching_pairs = predictable_pairs(predictable_pairs(:, 2) == trial_target_numbers_8(i_tr), 1);
    this_pair = matching_pairs(randperm(2));
    seed_stimA(i_tr) = this_pair(1);
end
trial_stimA_8 = seed_stimA;

%% Block 9 (Training)
% more of Just target:
block_len = 48;
seed_targ_nums = repmat(1:4, 1, block_len/4);
trial_target_numbers_9 = seed_targ_nums(randperm(length(seed_targ_nums)));

seed_targ_nums = 5:8;
trial_home_numbers_9 = nan(size(seed_targ_nums));
for i_targ = 1:length(trial_target_numbers_9)
    targ_num_possibilities = circshift(seed_targ_nums, -trial_target_numbers_9(i_targ));
    coin_flip = round(rand(1));
    trial_home_numbers_9(i_targ) = targ_num_possibilities(coin_flip + 1);
end

trial_type_9 = ones(size(trial_target_numbers_9));

seed_pPT = repmat(linspace(EXTRM_PT(1), EXTRM_PT(2), block_len/4), 1, 4);
prescribed_PT_9 = seed_pPT + .15*(rand(1, length(seed_pPT)) - .5);

trial_stimA_9 = ones(size(trial_target_numbers_9));

%% combine blocks
trial_target_numbers = [...
    trial_target_numbers_0, ...
    trial_target_numbers_1, ...
    trial_target_numbers_2, ...
    trial_target_numbers_3, ...
    trial_target_numbers_4, ...
    trial_target_numbers_5, ...
    trial_target_numbers_6, ...
    trial_target_numbers_7, ...
    trial_target_numbers_8, ...
    trial_target_numbers_9,...
    ];

trial_home_numbers = [...
    trial_home_numbers_0, ...
    trial_home_numbers_1, ...
    trial_home_numbers_2, ...
    trial_home_numbers_3, ...
    trial_home_numbers_4, ...
    trial_home_numbers_5, ...
    trial_home_numbers_6, ...
    trial_home_numbers_7, ...
    trial_home_numbers_8, ...
    trial_home_numbers_9, ...
    ];

trial_type = [...
    trial_type_0, ...
    trial_type_1, ...
    trial_type_2, ...
    trial_type_3, ...
    trial_type_4, ...
    trial_type_5, ...
    trial_type_6, ...
    trial_type_7, ...
    trial_type_8, ...
    trial_type_9, ...
    ];

prescribed_PT = [...
    prescribed_PT_0, ...
    prescribed_PT_1, ...
    prescribed_PT_2, ...
    prescribed_PT_3, ...
    prescribed_PT_4, ...
    prescribed_PT_5, ...
    prescribed_PT_6, ...
    prescribed_PT_7, ...
    prescribed_PT_8, ...
    prescribed_PT_9, ...
    ];

trial_stimA = [...
    trial_stimA_0, ...
    trial_stimA_1, ...
    trial_stimA_2, ...
    trial_stimA_3, ...
    trial_stimA_4, ...
    trial_stimA_5, ...
    trial_stimA_6, ...
    trial_stimA_7, ...
    trial_stimA_8, ...
    trial_stimA_9, ...
    ];

reward = [...
    reward_0, ...
    reward_1,...
    reward_2,...
    reward_3,...
    reward_4,...
    reward_5,...
    reward_6,...
    reward_6,...
    reward_6,...
    reward_6...
    ];

%% save subject data
save(['trial_parameters_', subject_code], 'trial_target_numbers', 'trial_home_numbers', 'trial_type', 'prescribed_PT', 'trial_stimA', 'reward');


