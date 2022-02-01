%FixUnnamedVideoFiles.m
% Finds and fixes un-named video files like "$currentOBSString (2).mkv".

addpath(genpath('../../Helpers'));
%% Set default datetime display properties (this doesn't affect the values stored, only their display/preview in MATLAB)
datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSS');
time_reference = datenum('1970', 'yyyy');

enable_rename = true;
enable_renamed_transcoded_also = true;

% is_undo_rename_mode: if true, replaces the renamed files with the originally named versions.
is_undo_rename_mode = false;

bbIDs = {'02','04','06','09','12','14','15','16'};

% current_included_bbIDs: the BBIDs to process:
current_included_bbIDs = [true, true, true, true, true, true, true, true];

general_output_settings.rootPath = '..\..\OUTPUT';
if ~exist(general_output_settings.rootPath,'dir')
   mkdir(general_output_settings.rootPath); 
end

rename_records_output_settings.relativePath = 'rename_records';
rename_records_output_settings.rootPath = fullfile(general_output_settings.rootPath, rename_records_output_settings.relativePath);
if ~exist(rename_records_output_settings.rootPath,'dir')
   mkdir(rename_records_output_settings.rootPath); 
end

output_found_unnamed_videos_file_name = 'RenamedVideoFiles.mat';
output_found_unnamed_videos_file_path = fullfile(rename_records_output_settings.rootPath, output_found_unnamed_videos_file_name);

was_loaded = false;
if exist(output_found_unnamed_videos_file_path, 'file')
% 	error(['Renamed video files file at ', output_found_unnamed_videos_file_path, ' already exists and we will not overwrite it!'])
	load(output_found_unnamed_videos_file_path, 'activeOriginalVideosPathRoot', 'all_unnamed_videos_rename_data', 'bbIDs', 'num_total_unnamed_videos');
	was_loaded = true;
end

activeOriginalVideosPathRoot = 'F:\Videos\BB';
activeTranscodedVideosPathRoot = 'E:\Transcoded Videos\BB';

% Loop through each folder:
num_boxes_to_process = length(bbIDs);
num_total_unnamed_videos = 0;
for boxIndex=1:num_boxes_to_process
    
    if current_included_bbIDs(boxIndex)

        %% Find Actigraphy files:
        curr_bbID = bbIDs{boxIndex};
        currBBIDString = ['BB' curr_bbID];
		curr_folder = [activeOriginalVideosPathRoot, curr_bbID];
		curr_transcoded_folder = [activeTranscodedVideosPathRoot, curr_bbID];

		if was_loaded
			num_box_unnamed_video_files = all_unnamed_videos_rename_data{boxIndex}.num_box_unnamed_video_files;

			if num_box_unnamed_video_files > 0
				unnamedVideoFilesData = all_unnamed_videos_rename_data{boxIndex}.unnamedVideoFilesData;
			else
				continue; % end the loop, nothing to do for this box
			end

		else
			all_unnamed_videos_rename_data{boxIndex}.curr_bbID = curr_bbID;
			all_unnamed_videos_rename_data{boxIndex}.curr_folder = curr_folder;

			%curr_search_string = fullfile(curr_folder, '*.mkv');
			curr_search_string = fullfile(curr_folder, '$currentOBSString*.mkv'); % malformed only
			unnamedVideoFilesData = dir(curr_search_string);
			num_box_unnamed_video_files = length(unnamedVideoFilesData);

			all_unnamed_videos_rename_data{boxIndex}.num_box_unnamed_video_files = num_box_unnamed_video_files;
			num_total_unnamed_videos = num_total_unnamed_videos + num_box_unnamed_video_files;
		end

		for fileIndex = 1:num_box_unnamed_video_files
			if ~was_loaded
				[~, unnamedVideoFilesData(fileIndex).originalBaseName, unnamedVideoFilesData(fileIndex).fileExtension] = fileparts(unnamedVideoFilesData(fileIndex).name);
				temp.TimeStruct = GetFileTime(curr_file_path, 'UTC');
				unnamedVideoFilesData(fileIndex).creation_time = temp.TimeStruct.Creation;
				unnamedVideoFilesData(fileIndex).modification_time = temp.TimeStruct.Write;
				temp.t = datetime(unnamedVideoFilesData(fileIndex).creation_time);
				[OBSVideoBasename] = MakePhoOBSVideoBaseFileName(curr_bbID, temp.t);
				% Re-parse just to test:
				[videoFile] = ParsePhoOBSVideoFileName(OBSVideoBasename);
				temp.reverse_parsed_datetime = videoFile.dateTime;
				temp.reverse_parsed_datetime.TimeZone = 'UTC';
				temp.t.TimeZone = 'UTC';
% 				temp.parsed_time_difference = temp.reverse_parsed_datetime - temp.t;
% 				disp(temp.parsed_time_difference);
				if temp.reverse_parsed_datetime ~= temp.t
					error('Time conversion issue! Filename invalid!')
				end

				unnamedVideoFilesData(fileIndex).expected_basename = OBSVideoBasename;
			end
			
			curr_file_path = fullfile(unnamedVideoFilesData(fileIndex).folder, unnamedVideoFilesData(fileIndex).name);
			%output_TimeStructs{end+1} = TimeStruct;
			if enable_rename

				final_renamed_filename = [unnamedVideoFilesData(fileIndex).expected_basename, unnamedVideoFilesData(fileIndex).fileExtension];
				final_renamed_file_path = fullfile(unnamedVideoFilesData(fileIndex).folder, final_renamed_filename);

				if ~is_undo_rename_mode
					final_curr_file_path = curr_file_path;
					final_destination_file_path = final_renamed_file_path;
				else
					final_curr_file_path = final_renamed_file_path;
					final_destination_file_path = curr_file_path;
				end

				if exist(final_curr_file_path, 'file')						
					fprintf('File would be renamed from %s to %s.\n', final_curr_file_path, final_destination_file_path);
					[status, message, messageId] = movefile(final_curr_file_path, final_destination_file_path);
					if ~status
						error('File rename from %s to %s failed with message %s', final_curr_file_path, final_destination_file_path, message);
					else
						fprintf('File renamed from %s to %s successfully.\n', final_curr_file_path, final_destination_file_path);
					end

				else
					fprintf('Original File (expected at %s) does not exist. Skipping Original and trying transcoded rename.', final_curr_file_path);
				end

				% Rename transcoded item:
				if enable_renamed_transcoded_also
					transcoded_file_extension = '.mp4';
					analagous_transcoded_filename = [unnamedVideoFilesData(fileIndex).originalBaseName, transcoded_file_extension];
					analagous_transcoded_filePath = fullfile(curr_transcoded_folder, analagous_transcoded_filename);

					final_renamed_transcoded_filename = [unnamedVideoFilesData(fileIndex).expected_basename, transcoded_file_extension];
					final_renamed_transcoded_file_path = fullfile(curr_transcoded_folder, final_renamed_transcoded_filename);


					if ~is_undo_rename_mode
						final_curr_file_path = analagous_transcoded_filePath;
						final_destination_file_path = final_renamed_transcoded_file_path;
					else
						final_curr_file_path = final_renamed_transcoded_file_path;
						final_destination_file_path = analagous_transcoded_filePath;
					end

					if exist(final_curr_file_path, 'file')
						fprintf('File would be renamed from %s to %s.\n', final_curr_file_path, final_destination_file_path);

						[status, message, messageId] = movefile(final_curr_file_path, final_destination_file_path, 'f');
						if ~status
							error('Transcoded file rename from %s to %s failed with message %s', final_curr_file_path, final_destination_file_path, message);
						else
							fprintf('Transcoded file renamed from %s to %s successfully.\n', final_curr_file_path, final_destination_file_path);
						end

					else
						fprintf('Analagous Transcoded file (expected at %s) does not exist. Skipping Transcoded rename.', final_curr_file_path);
					end
				end

			end
		end

		if num_box_unnamed_video_files > 0
			all_unnamed_videos_rename_data{boxIndex}.unnamedVideoFilesData = unnamedVideoFilesData;
		else
% 			all_unnamed_videos_rename_data{boxIndex}.unnamedVideoFilesData = [];
		end

% 		% Save:
% 		disp(['Done with box, saving to ' output_found_unnamed_videos_file_path, '...'])
%         save(output_found_unnamed_videos_file_path, 'activeOriginalVideosPathRoot', 'all_unnamed_videos_rename_data', 'bbIDs', 'num_total_unnamed_videos, '-v7.3');

	end % end if included

end

% Save:
disp(['Done with all boxes. Saving to ' output_found_unnamed_videos_file_path, '...'])
save(output_found_unnamed_videos_file_path, 'activeOriginalVideosPathRoot', 'all_unnamed_videos_rename_data', 'bbIDs', 'num_total_unnamed_videos', '-v7.3');


