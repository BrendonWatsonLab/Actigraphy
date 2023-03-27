function BatchProcessVideoFileAnalyzer(FoundVideoFilesPath,BBParentPath,BBlist,BBToAnalyze)
% BatchProcessVideoFileAnalyzer
% Pho Hale, 5/1/2020
% Actigraphy Pipeline Stage: 
% Use the list of found video files (foundvideofiles.mat) to loop through them and compute actigraphy data for each of them. This data is saved out to a video-specific actigraphy file (meaning 1 per video) in the actigraphy directory/bbID folder.
% It tries not to over-write previous results, and it stores a list of the videos that have been processed in a variable named all_videos_output_data stored in FoundVideoFiles.mat
% Estimated Runtime: ~1hr per 4hr video


%% Loop through the bbIDs again to process them:
%% TODO for 4/27/2020: Call the "BatchAnalyzeVideo.m" Helper script.
% m = matfile(output_file_name,'Writable',true);
actigraphy_output_parent_path = [DriveRootPath, 'ActigraphyResults'];


% Loop through each folder:
num_boxes_to_process = length(all_videos_output_data);
for i=1:num_boxes_to_process
    
    curr_box_output_data = all_videos_output_data{i};
    curr_bbID = curr_box_output_data.curr_bbID;
    curr_folder = curr_box_output_data.curr_folder;
    videoFilesData = curr_box_output_data.videoFilesData;
    curr_output_relative_path = ['BB', curr_bbID];
    
    num_total_videos = length(videoFilesData);
	num_processed_videos = sum(all_videos_output_data{i}.is_actigraphy_processed, 'all');
	num_videos_to_process = num_total_videos - num_processed_videos;


	if num_videos_to_process == 0
		fprintf('All %d videos in %s (Folder %d/%d) are already processed... skipping.\n', num_total_videos, curr_folder, i, totalBoxFolderCount);
	else
		if ~current_included_bbIDs(i)
			fprintf('Skipping Processing %s (Folder %d/%d): containing %d/%d videos (%d unprocessed) because it is not included in the current_included_bbIDs.\n', curr_folder, i, totalBoxFolderCount, num_total_videos, totalCombinedVideoCount, num_videos_to_process);
			continue;
		else
			fprintf('Begin Processing %s (Folder %d/%d): containing %d/%d videos (%d unprocessed). \n Results will be output to %s.\n', curr_folder, i, totalBoxFolderCount, num_total_videos, totalCombinedVideoCount, num_videos_to_process, actigraphy_output_parent_path);

			% Need to get the indices of the unprocessed videos:
			unprocessed_video_indicies = find(all_videos_output_data{i}.is_actigraphy_processed < 1);

			%% Process video files
			for unprocessedIndex = 1:num_videos_to_process
				% Get the corresponding file index from the unprocessed index:
				fileIndex = unprocessed_video_indicies(unprocessedIndex);
				% Construct the full file path
				currVideoFileName = videoFilesData(fileIndex).name;
				currVideoFullPath = fullfile(curr_folder, currVideoFileName);
				currVideoIsProcessed = all_videos_output_data{i}.is_actigraphy_processed(fileIndex);
				if currVideoIsProcessed
					% This shouldn't happen anymore, as we only look at the unprocessed videos:
					fprintf('    WARNING: Skipping already processed Video[%d] (%d of %d unprocessed videos in current folder) %s...\n', fileIndex, unprocessedIndex, num_videos_to_process, currVideoFullPath);
				else
					fprintf('    Processing Video[%d] (%d of %d unprocessed videos in current folder) %s...\n', fileIndex, unprocessedIndex, num_videos_to_process, currVideoFullPath);
					try
						[results, curr_output_bbvaSettings, bbvaSettings, bbvaVideoFile, bbvaCurrFrameSegment] = BatchAnalyzeVideo(curr_folder, currVideoFileName, actigraphy_output_parent_path, curr_output_relative_path, false);
						all_videos_output_data{i}.is_actigraphy_processed(fileIndex) = true; % Set file as processed in the .mat file. TODO: this might mess up parallelism.
						all_videos_output_data{i}.actigraphy_file_output_path{fileIndex} = curr_output_bbvaSettings.final_output_path; % Get name of output file

					catch e %e is an MException struct
						disp('    WARNING: Problem with video file! Skipping for now!');
						fprintf(2,'    Error processing the video file! \n    The identifier was: %s\n    The message was: %s\n', e.identifier, e.message);
						continue
					end
				end

				%% TODO: Need to save the updated is_actigraphy_processed result back to the .mat file!
				% Save the updated atigraphy results back to the .mat file:
				save(output_found_videos_file_name, 'activeTranscodedVideosPathRoot', 'bbIDs', 'all_videos_output_data', 'totalCombinedVideoCount', 'totalBoxFolderCount', '-v7.3');

			end % end for unprocessed videos
    
		end % end if current_included_bbIDs(i)
	end % end if num_videos_to_process
    
end

disp('done.')