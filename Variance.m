
% RCAP - Risky Cookie and P_ke wrapper script

% start pVAS

function Variance()
clear;
clc;

javaaddpath('.');
    PsychJavaTrouble % There was trouble with ListenChar...
    pwd
    thePath.main = pwd;
    % Make sure you are starting from the CAP directory! ...
    [pathstr,curr_dir,ext,versn] = fileparts(pwd);
    if ~strcmp(curr_dir,'smellrisk')
        error('You must start the experiment fromthe smellrisk directory. Go there and try again.\n');
    end
    thePath.scripts = fullfile(thePath.main, 'scripts');
    thePath.data = fullfile(thePath.main, 'data');
    thePath.baseline = fullfile(thePath.main, 'baseline');
    
    % add more dirs above
    
    % Add relevant paths for this experiment
    addpath(thePath.scripts)
    addpath(thePath.baseline)
    addpath(thePath.data)
    
    
    fprintf('Welcome to the Experiment\n');
    subNumber = input('What is the subject number? (0-99): ');
    
    subjgender=input('M/F? 0/1: ');
    scanner = input ('behavioral/scanner? 0/1: ');
    
    
    RunVariance(thePath,subNumber,subjgender,scanner);
end

%===================================================
%define a helper function to ensure valid filenames.
function fileName = getFileName(filetype)
    %no valid file yet
    validfile = 0;
    while ~validfile 
        %get a filename
        fileName = input(['What is the name of the ', filetype, '? '],'s');
        %check the file exists
        validfile = exist(fileName, 'file');
        if ~validfile
            fprintf(['\nCould not find file. Please try again.\n']);
        end
    end
end

