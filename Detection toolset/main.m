%%
% It's cilia detection toolset entry.

% add path
addpath(fullfile(pwd,'cilia detection method'));
addpath(fullfile(pwd,'cnn'))
addpath(fullfile(pwd,'doc'));
addpath(fullfile(pwd,'figure files'));
addpath(fullfile(pwd,'gui method'));

% run detection toolset
warning('off');
run tst.m