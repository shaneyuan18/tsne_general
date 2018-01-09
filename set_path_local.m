% DESC:
% set_path_local sets necessary path for initialization
% 
% AUTHOR:
% Shane Yuan shane.yuan@epicsciences.com

curr_dir = pwd;
cd ..
base_dir = pwd;
cd(curr_dir);
addpath(genpath(fullfile(base_dir,'thirdparty')));

fprintf('\nSet paths for t-SNE General Tool\n');
