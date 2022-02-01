%%% MergeFoundVideoFilesMat.m
%% Written by Pho Hale on 5/8/2020
%% Reads in "FoundVideoFiles.mat" files produced by "BatchProcessVideoFileAnalyzer.m" and does its best to produce the data for an updated FoundVideoFiles.mat file:
%%% It updates the: "is_actigraphy_processed" and "actigraphy_file_output_path" variables
%% The number of boxes AND number of video files in each box must be the same, and the only differences it copies over are newer entries in those two mentioned variables.
%% See the "Merge FoundVideoFiles.mat results" section of ActigraphyPlotExplorerer.mlx for a more advanced but incomplete implementation of merging.
 
foundVideoFilesName_MergedOutputPath = 'FoundVideoFiles_Merged.mat';
perform_output_file_save = true;

% target_files = {'C:\Users\watsonlab\source\repos\PhoMatlabBBVideoAnalyzer\MAIN\FoundVideoFiles.mat', ...
% 'C:\Users\watsonlab\source\repos\PhoMatlabBBVideoAnalyzer\MAIN\FoundVideoFiles_Merged.mat', ...
% 'C:\Users\watsonlab\source\repos\PhoMatlabBBVideoAnalyzer\MAIN\FoundVideoFiles_WatsonBB16.mat'};
target_files = {'C:\Users\watsonlab\source\repos\PhoMatlabBBVideoAnalyzer\MAIN\FoundVideoFiles.mat', ...
'C:\Users\watsonlab\source\repos\PhoMatlabBBVideoAnalyzer\MAIN\FoundVideoFiles_WatsonBB16.mat'};

is_first_file = true;

for target_file_index = 1:length(target_files)
	currFileName = target_files{target_file_index};
	currLoadedS = load(currFileName, 'activeTranscodedVideosPathRoot', 'bbIDs', 'all_videos_output_data', 'totalCombinedVideoCount', 'totalBoxFolderCount');
	fprintf('Loaded %s: contains %i total videos spanning %i folders.\n', currFileName, currLoadedS.totalCombinedVideoCount, currLoadedS.totalBoxFolderCount);

	if is_first_file
		final.activeTranscodedVideosPathRoot = currLoadedS.activeTranscodedVideosPathRoot;
		final.bbIDs = currLoadedS.bbIDs;
		final.all_videos_output_data = currLoadedS.all_videos_output_data;
		final.totalCombinedVideoCount = currLoadedS.totalCombinedVideoCount;
		final.totalBoxFolderCount = currLoadedS.totalBoxFolderCount;
		curr_file_num_completed_actigraphy_statuses = zeros([1, length(final.bbIDs)]);
		
		for box_index = 1:length(final.bbIDs)
			curr_file_num_completed_actigraphy_statuses(box_index) = sum(currLoadedS.all_videos_output_data{box_index}.is_actigraphy_processed, 'all');
		end

% 		final_actigraphy_is_processed = 
		is_first_file = false;

		
	else
% 		curr_loaded.bbIDs = currLoadedS.bbIDs;
% 		curr_loaded.all_videos_output_data = currLoadedS.all_videos_output_data;

		curr_file_num_changed_actigraphy_statuses = zeros([1, length(final.bbIDs)]);
		curr_file_num_completed_actigraphy_statuses = zeros([1, length(final.bbIDs)]);
		for box_index = 1:length(final.bbIDs)
			final_bbID = final.bbIDs{box_index};
			curr_bbID = currLoadedS.bbIDs{box_index};
			if ~strcmpi(final_bbID, curr_bbID)
				error('bbIDs differ for file_index %i and box_index %i\n', target_file_index, box_index)
				perform_output_file_save = true;
				break;
			end

			num_final_files_count = length(final.all_videos_output_data{box_index}.videoFilesData);
			num_curr_files_count = length(currLoadedS.all_videos_output_data{box_index}.videoFilesData);
			if num_final_files_count ~= num_curr_files_count
				error('num_curr_files_count and num_final_files_count differ for file_index %i and box_index %i\n', target_file_index, box_index)
				perform_output_file_save = true;
				break;
			end

			curr_file_num_completed_actigraphy_statuses(box_index) = sum(currLoadedS.all_videos_output_data{box_index}.is_actigraphy_processed, 'all');

			for foundVideoFileIndex = 1:length(num_final_files_count)
				if ~strcmpi(final.all_videos_output_data{box_index}.videoFilesData(foundVideoFileIndex).name, currLoadedS.all_videos_output_data{box_index}.videoFilesData(foundVideoFileIndex).name)
					error('video file names differ for file_index %i, box_index %i, video file index %i\n', target_file_index, box_index, foundVideoFileIndex)
					perform_output_file_save = true;
				end

				% Set the current actigraphy status and file output path from the loaded file:
				if ~final.all_videos_output_data{box_index}.is_actigraphy_processed(foundVideoFileIndex)
					% IF actigraphy isn't processed in the final, but is in the currently loaded file, set the final file status to that of the curr file (which still might be False, indicating not processed)
					if currLoadedS.all_videos_output_data{box_index}.is_actigraphy_processed(foundVideoFileIndex)
						final.all_videos_output_data{box_index}.is_actigraphy_processed(foundVideoFileIndex) = currLoadedS.all_videos_output_data{box_index}.is_actigraphy_processed(foundVideoFileIndex);
						curr_file_num_changed_actigraphy_statuses(box_index) = curr_file_num_changed_actigraphy_statuses(box_index) + 1;
						% if the final's actigraphy_file_output_path is the empty string
						if strcmpi(final.all_videos_output_data{box_index}.actigraphy_file_output_path{foundVideoFileIndex},'')
							% check if the current's is, and if it's not:
							if ~strcmpi(currLoadedS.all_videos_output_data{box_index}.actigraphy_file_output_path{foundVideoFileIndex},'')
								% IF actigraphy path is empty in the final, but is non-empty in the loaded file, set the final file status to that of the loaded (curr) file (which still might be False, indicating not processed)
								final.all_videos_output_data{box_index}.actigraphy_file_output_path{foundVideoFileIndex} = currLoadedS.all_videos_output_data{box_index}.actigraphy_file_output_path{foundVideoFileIndex}; 
							end
						end
					end
				end
				

			end % End for video file index

			

		end % end for box index

		fprintf('For loaded file %s, the following change counts (per box) occured:\n    ', currFileName);
		disp(curr_file_num_changed_actigraphy_statuses);

		if ~exist('all_files_num_changed_actigraphy_statuses','var')
			all_files_num_changed_actigraphy_statuses = curr_file_num_changed_actigraphy_statuses;
		else
			all_files_num_changed_actigraphy_statuses = all_files_num_changed_actigraphy_statuses + curr_file_num_changed_actigraphy_statuses;
		end

	end % End is_first_file

	fprintf('For loaded file %s, the following true completed actigraphy status counts (per box) occured:\n    ', currFileName);
	disp(curr_file_num_completed_actigraphy_statuses);

end % end for FoundVideoFiles.mat loop

fprintf('For all loaded FoundVideoFiles.mat files, the following total change counts (per box) occured:\n    ', currFileName);
disp(all_files_num_changed_actigraphy_statuses);


if perform_output_file_save
	% Save the result to a .mat file:
	activeTranscodedVideosPathRoot = final.activeTranscodedVideosPathRoot;
	bbIDs = final.bbIDs;
	all_videos_output_data = final.all_videos_output_data;
	totalCombinedVideoCount = final.totalCombinedVideoCount;
	totalBoxFolderCount = final.totalBoxFolderCount;
	save(foundVideoFilesName_MergedOutputPath, 'activeTranscodedVideosPathRoot', 'bbIDs', 'all_videos_output_data', 'totalCombinedVideoCount', 'totalBoxFolderCount', '-v7.3');
	fprintf('    Result saved to %s\n', foundVideoFilesName_MergedOutputPath);
end

% %% Move variables inside:
% box_index = 6;
% curr_actigraphy_is_processed = all_videos_output_data{box_index}.is_actigraphy_processed;
% for foundVideoFileIndex = 1:length(curr_actigraphy_is_processed)
% 	all_videos_output_data{box_index}.videoFilesData(foundVideoFileIndex).is_actigraphy_processed = curr_actigraphy_is_processed(foundVideoFileIndex);
% 	all_videos_output_data{box_index}.videoFilesData(foundVideoFileIndex).actigraphy_file_output_path = all_videos_output_data{box_index}.actigraphy_file_output_path{foundVideoFileIndex};
% 	
% end