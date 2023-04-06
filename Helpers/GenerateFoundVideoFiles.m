function [current_included_bbIDs] = GenerateFoundVideoFiles(BBlist, BBToAnalyze, BBParentPath, FoundVideoFilesPath, ExperimentToAnalyze, CohortToAnalyze)
% GenerateFoundVideoFiles - make a Foundvideofiles.mat file that is used for quadrantizing and actigraphy.

% Iterates over .mp4 video files produced by the behavioral box project. 
% Creates an output FoundVideoFiles.mat data file containing a list of video files and metadata about them.
%
% Metadata includes: TODO
%% Allow the user to select the directories containing the video files if they aren't specified:

addpath(genpath('../Helpers'));
%% Set default datetime display properties (this doesn't affect the values stored, only their display/preview in MATLAB)

datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSS');
time_reference = datenum('1970', 'yyyy');
output_found_videos_file_name = fullfile(FoundVideoFilesPath,'FoundVideoFiles.mat');%'C:\Users\duck7\Documents\lab shit\FoundVideoFiles.mat'); %David here!
bbIDs = BBlist; 
current_included_bbIDs = BBToAnalyze;
DriveRootPath = [BBParentPath, '/']; % For Overseer:
% DriveRootPath = 'O:\'; % For WatsonBB16:
activeTranscodedVideosPathRoot = BBParentPath;
activeTranscodedVideosPathRoot = [DriveRootPath, 'BB'];
%% Load Existing 'FoundVideoFiles.mat' results if they exist, otherwise create them. Searches for additional files or included bbID folders no matter what and merges them with the loaded ones:
[all_videos_output_data, totalCombinedVideoCount, totalBoxFolderCount] = FnSmartFindAllVideoFiles(bbIDs, activeTranscodedVideosPathRoot, output_found_videos_file_name, ExperimentToAnalyze, CohortToAnalyze);

end