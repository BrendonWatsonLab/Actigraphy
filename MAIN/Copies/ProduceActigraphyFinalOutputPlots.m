% ProduceActigraphyFinalOutputPlots
% Pho Hale, 5/1/2020
% Actigraphy Pipeline Stage: 4

% Loads the binned timetable files produced in the previous step, and plots them.
% Estimated Runtime: <1 minute per box

addpath(genpath('../Helpers'));
%% Set default datetime display properties (this doesn't affect the values stored, only their display/preview in MATLAB)
datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSS');
time_reference = datenum('1970', 'yyyy');


min_time = datetime('2021-07-13 00:00:00.000', 'TimeZone', 'local');
%max_time = datetime('2020-03-16 01:23:12.900');
max_time = datetime('2021-07-14 00:00:00.000', 'TimeZone', 'local');

bbIDs = {'02','04','06','09','12','14','15','17'};

% current_included_bbIDs: the BBIDs to process:
current_included_bbIDs = [false, false, false, false, false, false, false, true];
% current_included_bbIDs = [true, false, false, false, false, false, false, false];
%current_included_bbIDs = [false, true, true, false, false, false, false, false];
% current_included_bbIDs = [false, false, false, false, false, true, true, true];

% Create output directories if needed:
general_output_settings.rootPath = 'C:\Users\duck7\Documents\lab shit\GeneralOutputs';
if ~exist(general_output_settings.rootPath,'dir')
   mkdir(general_output_settings.rootPath); 
end

plots_output_settings.relativePath = 'plots';
plots_output_settings.rootPath = fullfile(general_output_settings.rootPath, plots_output_settings.relativePath);
if ~exist(plots_output_settings.rootPath,'dir')
   mkdir(plots_output_settings.rootPath); 
end

tables_output_settings.relativePath = 'tables';
tables_output_settings.rootPath = fullfile(general_output_settings.rootPath, tables_output_settings.relativePath);
if ~exist(tables_output_settings.rootPath,'dir')
   mkdir(tables_output_settings.rootPath); 
end

%% Loop through the bbIDs to process them:
output_found_videos_file_name = 'C:\Users\duck7\Documents\lab shit\FoundVideoFiles.mat';

% Loop through each folder:
num_boxes_to_process = length(bbIDs);
for i=1:num_boxes_to_process
    
    if current_included_bbIDs(i)

        %% Find Actigraphy files:
        curr_bbID = bbIDs{i};
        currBBIDString = ['BB' curr_bbID];
        
        % Load the timetables:
		currRelativeTablesPath = currBBIDString;
        curr_output_tables_path = fullfile(tables_output_settings.rootPath, currRelativeTablesPath); % Location to save the data
        if ~exist(curr_output_tables_path, 'dir')
            error(['The path ' curr_output_tables_path ' does not exist!']); % Create the directory if needed
        end

        output_merged_actigraphy_timetables_file_name = ['MergedBoxActigraphyData_BB', curr_bbID, '_Timetables.mat'];
        output_merged_actigraphy_timetables_file_path = fullfile(curr_output_tables_path, output_merged_actigraphy_timetables_file_name);

        if exist(output_merged_actigraphy_timetables_file_path, 'file')
            disp(['Loading ', output_merged_actigraphy_timetables_file_path, '...'])
            load(output_merged_actigraphy_timetables_file_path, 'video_frames_per_bin', 'curr_activity_timetable', 'curr_activity_timetable_hourly_binned_mean', 'curr_activity_timetable_hourly_binned_sum', 'aggregateGroupings');
            disp('done.')
        else
            error(['ERROR: ' output_merged_actigraphy_timetables_file_path ' does not exist!']);
        end

        disp('Building plots...')			
		% Make the folder for this BBID in the plots folder if needed
		currRelativePlotsPath = currBBIDString;
        curr_output_plots_path = fullfile(plots_output_settings.rootPath, currRelativePlotsPath); % Location to save the data
        if ~exist(curr_output_plots_path, 'dir')
            mkdir(curr_output_plots_path); % Create the directory if needed
        end
        
        disp('Making figures...')
        [fig, axH] = PlotBinnedActigraphyEventsTimetable(curr_activity_timetable_hourly_binned_mean, video_frames_per_bin, currBBIDString, 'hourly', 'mean', curr_output_plots_path, aggregateGroupings, min_time, max_time, curr_activity_timetable);
        % [fig, axH] = PlotBinnedActigraphyEventsTimetable(curr_activity_timetable_hourly_binned_sum, video_frames_per_bin, currBBIDString, 'hourly', 'sum', curr_output_plots_path);
        disp('done.')

    end
        
end




disp('done.')