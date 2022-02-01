% ProduceActigraphyFinalOutputTable
% Pho Hale, 5/1/2020
% Actigraphy Pipeline Stage: 3

% Loads the raw actigraphy data vectors from the concatenated file produced in the previous step, and builts a MATLAB "timetable" structure from them to allow for efficient binning and processing of data.
% It optionally saves out a MergedBoxActigraphyData_BB00_Timetables.mat file just in case you don't want to repeat this step for multiple analysis. The runtime of this step is fairly low compared to the others though.
% Finally, it bins and analyzes the timetable and produces the final plots for variables of interest.

% Estimated Runtime: <5 minutes per box

%     %%%+S- bbvaOutputPlotsSettings
%     %- *curr_output_root - The root outputs folder to save to.
% 	%- *curr_output_root - The root outputs folder to save to.
% contains the output-relative folder for the current output time (i.e., 'plots', or 'timetables')
% 	%- *output_relative_path - output_relative_path is the path to currently save to relative to the curr_output_root. If empty, curr_output_root is used.
% 	%- curr_output_folder_root - curr_output_folder_root is a 
% bbvaOutputPlotsSettings.curr_output_root: 
% %


addpath(genpath('../Helpers'));
%% Set default datetime display properties (this doesn't affect the values stored, only their display/preview in MATLAB)
datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSS');
time_reference = datenum('1970', 'yyyy');


shouldPlotInline = false; % If true, the plots are generated and output after creating the data table. If false, they're skipped and can be ran later by running "ProduceActigraphyFinalOutputPlots"
bbIDs = {'02','04','06','09','12','14','15','17'};

% current_included_bbIDs: the BBIDs to process:
% current_included_bbIDs = [true, false, false, false, false, false, false, false];
%current_included_bbIDs = [false, true, true, false, false, false, false, false];
% current_included_bbIDs = [true, true, true, true, true, false, false, false];
current_included_bbIDs = [false, false, false, false, false, false, false, true];

% Create output directories if needed:
general_output_settings.rootPath = 'C:\Users\duck7\Documents\lab shit\GeneralOutputs';
if ~exist(general_output_settings.rootPath,'dir')
   mkdir(general_output_settings.rootPath); 
end

if shouldPlotInline
    plots_output_settings.relativePath = 'plots';
    plots_output_settings.rootPath = fullfile(general_output_settings.rootPath, plots_output_settings.relativePath);
    if ~exist(plots_output_settings.rootPath,'dir')
    mkdir(plots_output_settings.rootPath); 
    end
end

tables_output_settings.relativePath = 'tables';
tables_output_settings.rootPath = fullfile(general_output_settings.rootPath, tables_output_settings.relativePath);
if ~exist(tables_output_settings.rootPath,'dir')
   mkdir(tables_output_settings.rootPath); 
end


% Input directory for merged actigraphy files:
merged_actigraphy_output_settings.relativePath = 'merged_actigraphy';
merged_actigraphy_output_settings.rootPath = fullfile(general_output_settings.rootPath, merged_actigraphy_output_settings.relativePath);


%% Loop through the bbIDs to process them:
output_found_videos_file_name = 'C:\Users\duck7\Documents\lab shit\FoundVideoFiles.mat';
actigraphy_output_parent_path_root = 'C:\Users\duck7\Documents\lab shit\ActigraphyResults\BB';

totalBoxFolderCount = 0;
totalCombinedActigraphyFilesCount = 0;

% Loop through each folder:
num_boxes_to_process = length(bbIDs);
for i=1:num_boxes_to_process
    
    if current_included_bbIDs(i)

        %% Find Actigraphy files:
        curr_bbID = bbIDs{i};
        currBBIDString = ['BB' curr_bbID];
        curr_actigraphy_folder = [actigraphy_output_parent_path_root, curr_bbID];
        if ~exist(curr_actigraphy_folder,'dir')
            error(curr_actigraphy_folder); 
        end
        
        output_merged_actigraphy_data_file_name = ['MergedBoxActigraphyData_BB', curr_bbID, '.mat'];
        output_merged_actigraphy_timetables_file_name = ['MergedBoxActigraphyData_BB', curr_bbID, '_Timetables.mat'];

        final_merged_actigraphy_filePath =  fullfile(merged_actigraphy_output_settings.rootPath, output_merged_actigraphy_data_file_name);;
        if exist(final_merged_actigraphy_filePath, 'file')
            disp(['Loading ', final_merged_actigraphy_filePath, '...'])
            load(final_merged_actigraphy_filePath);
            disp('done.')
        else
            error(['ERROR: ' final_merged_actigraphy_filePath ' does not exist!']);
        end
        
        disp('Creating data table...')
        curr_activity_timetable = timetable(all_actigraphy_files_output_data{i}.concatenatedTimestamps, ...
            all_actigraphy_files_output_data{i}.concatenatedResults.num_changed_pixels, all_actigraphy_files_output_data{i}.concatenatedResults.total_sum_changed_pixel_value, ...
            'VariableNames',{'NumChangedPixels', 'TotalSumChangedPixelValues'});
        
        disp('Binning data table hourly...')
        % Compute the number of frames that fall into each bin: (The final counts per bin). This is the same for all variables and aggregate functions:
        curr_activity_timetable_hourly_binned_counts = retime(curr_activity_timetable,'hourly','count'); 
        video_frames_per_bin = curr_activity_timetable_hourly_binned_counts.NumChangedPixels;
        
        
        curr_activity_timetable_hourly_binned_mean = retime(curr_activity_timetable,'hourly','mean'); 
        curr_activity_timetable_hourly_binned_sum = retime(curr_activity_timetable,'hourly','sum');
        
 
        % Clustering of Data (Time-of-Day):
		% See https://www.mathworks.com/help/matlab/matlab_prog/preprocess-and-explore-bicycle-count-data-using-timetable.html#TTFeatExampleV3-11 for more analysis
		% TODO: there is a discrepancy here, mean and sum of the binning is different from mean or sum for the aggregation
		curr_activity_timetable_hourly_binned_mean.HrOfDay = hour(curr_activity_timetable_hourly_binned_mean.Time);
		aggregateGroupings.hourly_mean_byHrOfDay = varfun(@mean, curr_activity_timetable_hourly_binned_mean(:,{'NumChangedPixels','TotalSumChangedPixelValues','HrOfDay'}),...
			'GroupingVariables','HrOfDay','OutputFormat','table'); %Davids edit is changing nanmean to mean

		aggregateGroupings.hourly_sum_byHrOfDay = varfun(@sum, curr_activity_timetable_hourly_binned_mean(:,{'NumChangedPixels','TotalSumChangedPixelValues','HrOfDay'}),...
			'GroupingVariables','HrOfDay','OutputFormat','table'); %Davids edit is changing nansum to sum

        disp('Done.')
        
        % Done with box:
		
		% Make the folder for this BBID in the tables folder if needed
		currRelativeTablesPath = currBBIDString;
        curr_output_tables_path = fullfile(tables_output_settings.rootPath, currRelativeTablesPath); % Location to save the data
        if ~exist(curr_output_tables_path, 'dir')
            mkdir(curr_output_tables_path); % Create the directory if needed
        end

		output_merged_actigraphy_timetables_file_path = fullfile(curr_output_tables_path, output_merged_actigraphy_timetables_file_name);
        disp(['Done with box, saving to ' output_merged_actigraphy_timetables_file_path, '...'])
        save(output_merged_actigraphy_timetables_file_path, 'video_frames_per_bin', 'curr_activity_timetable', 'curr_activity_timetable_hourly_binned_mean', 'curr_activity_timetable_hourly_binned_sum', 'aggregateGroupings', '-v7.3');

        if shouldPlotInline
            disp('Done, building plots...')			
            % Make the folder for this BBID in the plots folder if needed
            currRelativePlotsPath = currBBIDString;
            curr_output_plots_path = fullfile(plots_output_settings.rootPath, currRelativePlotsPath); % Location to save the data
            if ~exist(curr_output_plots_path, 'dir')
                mkdir(curr_output_plots_path); % Create the directory if needed
            end
            
            disp('Making figures...')
            [fig, axH] = PlotBinnedActigraphyEventsTimetable(curr_activity_timetable_hourly_binned_mean, video_frames_per_bin, currBBIDString, 'hourly', 'mean', curr_output_plots_path, aggregateGroupings);
            % [fig, axH] = PlotBinnedActigraphyEventsTimetable(curr_activity_timetable_hourly_binned_sum, video_frames_per_bin, currBBIDString, 'hourly', 'sum', curr_output_plots_path);
        else
            disp('Done, skipping plots.')
        end

        disp('done.')

    end
        
end




disp('done.')