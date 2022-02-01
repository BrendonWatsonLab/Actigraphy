% CombineActigraphyOutputResults
% Pho Hale, 5/1/2020
% Actigraphy Pipeline Stage: 2
% Loops over the per-video actigraphy produced in the previous stage to produce a concatenated actigraphy file named "MergedBoxActigraphyData_BB00.mat", where 00 is the BBID.
% The result will be one actigraphy file per box. The structure of the output is similar to the form of the FoundVideoFiles.mat in terms of its variables, which it was inspired by.
% The current boxes included in processing can be changed by setting the corresponding entry in "current_included_bbIDs" to true or false.

% Estimated Runtime: <10 minutes per box.

addpath(genpath('../Helpers'));
%% Set default datetime display properties (this doesn't affect the values stored, only their display/preview in MATLAB)
datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSS');
time_reference = datenum('1970', 'yyyy');


% Create output directories if needed:
general_output_settings.rootPath = 'C:\Users\duck7\Documents\lab shit\GeneralOutputs\';
if ~exist(general_output_settings.rootPath,'dir')
   mkdir(general_output_settings.rootPath); 
end

merged_actigraphy_output_settings.relativePath = 'merged_actigraphy';
merged_actigraphy_output_settings.rootPath = fullfile(general_output_settings.rootPath, merged_actigraphy_output_settings.relativePath);
if ~exist(merged_actigraphy_output_settings.rootPath,'dir')
   mkdir(merged_actigraphy_output_settings.rootPath); 
end



bbIDs = {'02','04','06','09','12','14','15','17'}; % Note these will be overwritten by those loaded from the output_found_videos_file_name

% current_included_bbIDs: the BBIDs to process:
% current_included_bbIDs = [true, true, true, true, true, true, true, true];
current_included_bbIDs = [false, false, false, false, false, false, false, true];

%% Loop through the bbIDs to process them:
output_found_videos_file_name = 'C:\Users\duck7\Documents\lab shit\FoundVideoFiles.mat';
actigraphy_output_parent_path_root = 'C:\Users\duck7\Documents\lab shit\ActigraphyResults\BB';


% Load Found Video File:
if exist(output_found_videos_file_name, 'file')
    disp(['Loading ', output_found_videos_file_name, '...'])
	load(output_found_videos_file_name, 'activeTranscodedVideosPathRoot', 'bbIDs', 'all_videos_output_data', 'totalCombinedVideoCount', 'totalBoxFolderCount');
    disp('done.')
else
    error(['ERROR: ', output_found_videos_file_name, ' does not exist! Make sure pipeline stage 1 has already ran.']);
end




% totalBoxFolderCount = 0;
totalCombinedActigraphyFilesCount = 0;


% Loop through each folder:
num_boxes_to_process = length(all_videos_output_data);
for i=1:num_boxes_to_process
    
    if current_included_bbIDs(i)

        %% Find Actigraphy files:
        curr_bbID = bbIDs{i};
        curr_actigraphy_folder = [actigraphy_output_parent_path_root, curr_bbID];
        if ~exist(curr_actigraphy_folder,'dir')
            error(curr_actigraphy_folder); 
        end
                
        output_merged_actigraphy_data_file_name = ['MergedBoxActigraphyData_BB', curr_bbID, '.mat'];
		output_merged_actigraphy_data_file_fullpath = fullfile(merged_actigraphy_output_settings.rootPath, output_merged_actigraphy_data_file_name);

        rootSearchPath = curr_actigraphy_folder;
            
        % Find all video files in the directory:
        fullSearchPathFilterB = fullfile(rootSearchPath,'*.mat');
        currentActigraphyFilesFilesystemData = dir(fullSearchPathFilterB);
        num_current_found_filesystem_actigraphy_files = length(currentActigraphyFilesFilesystemData);
        
             
        % See what changed from the last seach if it existed:
        
        if exist(output_merged_actigraphy_data_file_fullpath, 'file')
            warning(['WARNING: The file ', output_merged_actigraphy_data_file_fullpath,  ' already exists and will be overwritten (which is probably okay). Continuing.']);
        end       

		actigraphyFilesData = currentActigraphyFilesFilesystemData;

		curr_box_output_data.curr_bbID = curr_bbID;
		curr_box_output_data.curr_folder = curr_actigraphy_folder;
		curr_box_output_data.actigraphyFilesData = actigraphyFilesData;
		curr_box_output_data.is_actigraphy_concatenated = zeros([length(actigraphyFilesData), 1]); % This isn't relevant if we're just going to overwrite the results every time. The runtime is so short it seems like a waste to use a more complex implementation.

		all_actigraphy_files_output_data{i} = curr_box_output_data;

		is_first_concatenated_item = true;

        % totalBoxFolderCount = totalBoxFolderCount + 1;
        totalCombinedActigraphyFilesCount = totalCombinedActigraphyFilesCount + length(actigraphyFilesData);
       
        num_actigraphy_files_to_process = length(actigraphyFilesData);

        fprintf('Begin Processing %s (Folder %d/%d): containing %d/%d actigraphy files. \n Results will be output to %s.\n', curr_actigraphy_folder, i, num_boxes_to_process, num_actigraphy_files_to_process, totalCombinedVideoCount, actigraphy_output_parent_path_root);

        %% Process actigraphy files
        for fileIndex = 1:num_actigraphy_files_to_process
            % Construct the full file path
            currActigraphyFileName = actigraphyFilesData(fileIndex).name;
            currActigraphyFullPath = fullfile(curr_actigraphy_folder, currActigraphyFileName);
           
            currActigraphyFileIsConcatenated = all_actigraphy_files_output_data{i}.is_actigraphy_concatenated(fileIndex);
            if currActigraphyFileIsConcatenated
                warning('Skipping already concatenated actigraphy file.')
            else
                fprintf('    Processing (ActigraphyFile[%d] of %d in current folder) %s...\n', fileIndex, num_actigraphy_files_to_process, currActigraphyFullPath);
   
                S = load(currActigraphyFullPath, 'bbvaVideoFile','bbvaCurrFrameSegment', 'bbvaSettings', 'results');
                [curr_bbvaVideoFile, curr_bbvaCurrFrameSegment, curr_bbvaSettings, curr_results] = deal(S.bbvaVideoFile, S.bbvaCurrFrameSegment, S.bbvaSettings, S.results);
                
                num_estimated_timestamps = length(curr_bbvaVideoFile.frameTimestamps);
                row_count_error = false;

                extra_video_timestamps = [];
                final_video_timestamps = [];
                
                if (length(curr_results.num_changed_pixels) ~= length(curr_results.total_sum_changed_pixel_value))
                    disp('    WARNING: Row count differs for curr_results.total_sum_changed_pixel_value and curr_results.num_changed_pixels! Skipping!');
                    row_count_error = true;
                else
                    if (length(curr_results.num_changed_pixels) < num_estimated_timestamps)
                        disp('    WARNING: Row count differs for results and timestamps, and there are less results!! Skipping!');         
                        row_count_error = true;
                        
                    elseif (length(curr_results.num_changed_pixels) ~= num_estimated_timestamps)
                        % Try to correct it
                        num_timestamps_needed = length(curr_results.num_changed_pixels) - num_estimated_timestamps;
                        disp(['    Adding timestamps! ', num2str(num_timestamps_needed)]);
                        % Add the timestamps!
                        new_end_frameIndex = curr_bbvaVideoFile.endFrameIndex + num_timestamps_needed;
                        
                        extra_video_frameIndicies = [(curr_bbvaVideoFile.endFrameIndex+1):new_end_frameIndex];
                        extra_video_timestamps = curr_bbvaVideoFile.parsedDateTime + seconds(extra_video_frameIndicies/curr_bbvaVideoFile.FrameRate);

                        curr_bbvaVideoFile.estimatedEndFrameIndex = curr_bbvaVideoFile.endFrameIndex; % Save the old endFrameIndex as the estimated one
                        curr_bbvaVideoFile.endFrameIndex = new_end_frameIndex;                        

                        final_video_timestamps  = [curr_bbvaVideoFile.frameTimestamps, extra_video_timestamps];
                        final_video_timestamps  = final_video_timestamps';

                        row_count_error = false;
                    else
                        final_video_timestamps = curr_bbvaVideoFile.frameTimestamps';
                        row_count_error = false; % Nothing more needed                    
                    end
                    
                end

                if row_count_error
                    row_counts_string = ['[timestamps: ', num2str(num_estimated_timestamps), ', num_changed_pixels: ', num2str(length(curr_results.num_changed_pixels)), ', total_sum_changed_pixel_value: ', num2str(length(curr_results.total_sum_changed_pixel_value))];
                    disp(['     Row Counts: ', row_counts_string]);
                else

                    % Post:
                    if is_first_concatenated_item
                        all_actigraphy_files_output_data{i}.concatenatedTimestamps = final_video_timestamps;
                        all_actigraphy_files_output_data{i}.concatenatedResults.num_changed_pixels = curr_results.num_changed_pixels;
                        all_actigraphy_files_output_data{i}.concatenatedResults.total_sum_changed_pixel_value = curr_results.total_sum_changed_pixel_value;
                        is_first_concatenated_item = false;
                    else
                        % Concatenate the timetable to the global one for this box.
                        all_actigraphy_files_output_data{i}.concatenatedTimestamps = [all_actigraphy_files_output_data{i}.concatenatedTimestamps; final_video_timestamps];
                        all_actigraphy_files_output_data{i}.concatenatedResults.num_changed_pixels = [all_actigraphy_files_output_data{i}.concatenatedResults.num_changed_pixels; curr_results.num_changed_pixels];
                        all_actigraphy_files_output_data{i}.concatenatedResults.total_sum_changed_pixel_value = [all_actigraphy_files_output_data{i}.concatenatedResults.total_sum_changed_pixel_value; curr_results.total_sum_changed_pixel_value];                        
                    end
                    all_actigraphy_files_output_data{i}.is_actigraphy_concatenated(fileIndex) = true; % Set file as processed in the .mat file. TODO: this might mess up parallelism.
                end
            end

        end
        
        
        % Done with box:
        disp(['Done with box, saving to ' output_merged_actigraphy_data_file_fullpath, '...'])
        save(output_merged_actigraphy_data_file_fullpath, 'curr_actigraphy_folder', 'bbIDs', 'all_actigraphy_files_output_data', '-v7.3');
		% Video File shouldn't be changed by this process at all...
%         disp(['Saving updated video file......'])
%         save(output_found_videos_file_name, 'activeTranscodedVideosPathRoot', 'bbIDs', 'all_videos_output_data', 'totalCombinedVideoCount', 'totalBoxFolderCount', '-v7.3');

        disp('done.')

    end
        
end




disp('done.')