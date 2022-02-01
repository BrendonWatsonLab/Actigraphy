% ExportCombinedActigraphyOutputs_ToPythonCSV
% Pho Hale, 5/11/2020
% Actigraphy Pipeline Stage: 3.5

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

% csvs_output_settings.relativePath = 'CSV';
% csvs_output_settings.rootPath = fullfile(general_output_settings.rootPath, csvs_output_settings.relativePath);
% if ~exist(csvs_output_settings.rootPath,'dir')
%    mkdir(csvs_output_settings.rootPath); 
% end


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
        output_merged_actigraphy_CSV_file_name = ['MergedBoxActigraphyData_BB', curr_bbID, '.csv'];

        final_merged_actigraphy_filePath =  fullfile(merged_actigraphy_output_settings.rootPath, output_merged_actigraphy_data_file_name);
        if exist(final_merged_actigraphy_filePath, 'file')
            disp(['Loading ', final_merged_actigraphy_filePath, '...'])
            load(final_merged_actigraphy_filePath);
            disp('done.')
        else
            error(['ERROR: ' final_merged_actigraphy_filePath ' does not exist!']);
		end
        
		% Convert data to prepare for output to CSV file:
		curr_timestamps = datenum(all_actigraphy_files_output_data{i}.concatenatedTimestamps);
		
		
		final_merged_actigraphy_CSV_filePath =  fullfile(merged_actigraphy_output_settings.rootPath, output_merged_actigraphy_CSV_file_name);
        disp(['Creating CSV file at ', final_merged_actigraphy_CSV_filePath, '...'])
		% Header:
		fileID = fopen(final_merged_actigraphy_CSV_filePath,'w');
		fprintf(fileID,'%s,%s,%s\n','timestamp','NumChangedPixels', 'TotalSumChangedPixelValues');
		
		for timestamp_index = 1:length(curr_timestamps)
			% Print the specific line out to file:
			fprintf(fileID,'%12.8f,%d,%d\n', curr_timestamps(timestamp_index), ...
				all_actigraphy_files_output_data{i}.concatenatedResults.num_changed_pixels(timestamp_index), ...
				all_actigraphy_files_output_data{i}.concatenatedResults.total_sum_changed_pixel_value(timestamp_index));
		
		end
		
		fclose(fileID);
	
        disp('Done.')
        
        % Done with box:
	
    end
        
end




disp('done.')