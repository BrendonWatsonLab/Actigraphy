function [mux_settings] = fnQuadrantizeFourVideos(videoParentPath, videoFileNames, outputName, videoFileStructures, isDryRun)
%FNQUADRANTIZEFOURVIDEOS Takes four video files, and "quadrentizes" them into a 2x2 grid, rendering the output.
%% Builds four-quadrant multiplexed videos for use in Homecagescan
% Pho Hale Updated 06/02/2020
addpath(genpath('../../Helpers'));

%activeTranscodedVideosPathRoot: 'E:\Transcoded Videos'
%curr_folder: ''E:\Transcoded Videos\BB02'

% if it's a dry run, nothing will actually be saved
if exist('isDryRun','var')
	is_dry_run = isDryRun;
else
	is_dry_run = false;
end

%% MUX Settings:
%%%+S- mux_settings
	%- original_video_width* - original_video_width is the width of the original videos to be multiplexed
	%- original_video_height* - original_video_height is the height of the original videos to be multiplexed 
	%- output_video_parent_path* - output_video_parent_path is a 
	%- output_video_name* - output_video_name is a 
	%- final_video_output_path - final_video_output_path is a 
	%- output_width - output_width is a 
	%- output_height - output_height is a 
	%- videoWriter - videoWriter is a 
%
mux_settings.original_video_width = 640;
mux_settings.original_video_height = 512;
mux_settings.output_width = mux_settings.original_video_width * 2;
mux_settings.output_height = mux_settings.original_video_height * 2;

% Folder to store the data files
mux_settings.output_datafile_relative_parent_path = 'MUXED'; % Added to the current transcoded videos path root.
mux_settings.output_datafile_parent_path = fullfile(videoParentPath, mux_settings.output_datafile_relative_parent_path);
if ~exist(mux_settings.output_datafile_parent_path, 'dir')
	mkdir(mux_settings.output_datafile_parent_path); % Create the folder if needed
end

% Folder to store the original videos
mux_settings.output_video_relative_parent_path = 'MUXED\MP4'; % Added to the current transcoded videos path root.
mux_settings.output_video_parent_path = fullfile(videoParentPath, mux_settings.output_video_relative_parent_path);
if ~exist(mux_settings.output_video_parent_path, 'dir')
	mkdir(mux_settings.output_video_parent_path); % Create the folder if needed
end

% A folder that won't be used by MATLAB, but will be used by handbrake to store the .MPG videos
mux_settings.output_converted_video_relative_parent_path = 'MUXED\MPEG'; % Added to the current transcoded videos path root.
mux_settings.output_converted_video_parent_path = fullfile(videoParentPath, mux_settings.output_converted_video_relative_parent_path);
if ~exist(mux_settings.output_converted_video_parent_path, 'dir')
	mkdir(mux_settings.output_converted_video_parent_path); % Create the folder if needed
end

mux_settings.output_video_name = [outputName '.mp4'];
mux_settings.final_video_output_path = fullfile(mux_settings.output_video_parent_path, mux_settings.output_video_name);
%mux_settings.videoWriter = VideoWriter(mux_settings.final_video_output_path, 'MPEG-4');
%muxedFrames = zeros([mux_settings.output_height, mux_settings.output_width, num_output_frames_to_allocate], 'uint8');

% 'E:\Transcoded Videos\BB02\MUXED\MP4'
mux_settings.final_output_datafile_name = [outputName '.mat'];
mux_settings.final_output_datafile_path = fullfile(mux_settings.output_datafile_parent_path, mux_settings.final_output_datafile_name);

disp(['Output will be written to ', mux_settings.final_video_output_path, ' and ', mux_settings.final_output_datafile_path])

should_print_status = true;

%%% MAIN:

if ~is_dry_run
	%% Video Files Loading
	is_preexisting_video_structures_mode = false;
	if (~exist('videoFileStructures','var') || isempty(videoFileStructures))
		for video_index = 1:length(videoFileNames)
			curr_video_name = videoFileNames{video_index};
			[bbvaVideoFile{video_index}, bbvaCurrFrameSegment{video_index}] = BuildVideoFileReaderStructure(videoParentPath, curr_video_name);
		end
		% Start Frame for analysis. Can be the frame just after the mouse is introduced, or after everything is settled down:
		start_frame_index = bbvaCurrFrameSegment{1}.startFrameIndex;
		estimated_frame_indicies = start_frame_index:bbvaVideoFile{1}.estimatedEndFrameIndex;

		for video_index = 1:length(videoFileNames)
			bbvaVideoFile{video_index}.num_frames_actually_read = 0;
		end

	else
		% Not fully checked
		for video_index = 1:length(videoFileStructures)
			bbvaVideoFile{video_index} = videoFileStructures(video_index);
		end
		% Start Frame for analysis. Can be the frame just after the mouse is introduced, or after everything is settled down:
		start_frame_index = 1;
		max_num_read_frames = max([bbvaVideoFile{1}.num_frames_actually_read, bbvaVideoFile{2}.num_frames_actually_read, bbvaVideoFile{3}.num_frames_actually_read, bbvaVideoFile{4}.num_frames_actually_read]);
		estimated_frame_indicies = start_frame_index:max_num_read_frames;
		is_preexisting_video_structures_mode = true;
	end

	% num_frames_to_process = length(frame_indicies);
	estimated_num_frames_to_process = length(estimated_frame_indicies);


	%%%%%%%%%%%%%%%%%%%%%%
	%% Main Run:    
	if exist('prev_greyscale_frame','var')
		clear prev_greyscale_frame;
	end
	
	fprintf('Begin main run for files: \n');
	for video_index = 1:length(videoFileNames)
		curr_video_name = videoFileNames{video_index};
		fprintf('    \t %s\n', curr_video_name)
	end
		

	i = 1;

	% Open the output video writer
	mux_settings.videoWriter = VideoWriter(mux_settings.final_video_output_path, 'MPEG-4');

	solid_black_frame = zeros([mux_settings.original_video_height, mux_settings.original_video_width], 'uint8');
	open(mux_settings.videoWriter) % Open the output file

	while hasFrame(bbvaVideoFile{1}.v)
		if (mod(i, 30) == 0)
			% Display the output message every 30 frames (1-second) of video.
			if should_print_status
				disp(['Processing ', num2str(i), ' of ', num2str(estimated_num_frames_to_process), ' Estimated Frames...'])
			end
		end

		if (mod(i, 9000) == 0)
			% Close and re-open the output video writer every 9000 frames of video to produce a usable video in case of a crash.
	% 		disp('Writing checkpoint...')
	% 		close(mux_settings.videoWriter); %% Close the output file
	% 		open(mux_settings.videoWriter); % Open the output file
	% 		disp('done. resuming...')
		end
		%% Allocate output:
		%curr_muxed_greyscale_frame = zeros([mux_settings.output_height, mux_settings.output_width], 'uint8');

		%% Read the frames from each video
		curr_greyscale_frame{1} = rgb2gray(readFrame(bbvaVideoFile{1}.v, 'native'));
		if ~is_preexisting_video_structures_mode
			bbvaVideoFile{1}.num_frames_actually_read = bbvaVideoFile{1}.num_frames_actually_read + 1;
		end
		for video_index = 2:length(videoFileNames)
			if hasFrame(bbvaVideoFile{video_index}.v)
				curr_greyscale_frame{video_index} = rgb2gray(readFrame(bbvaVideoFile{video_index}.v, 'native'));
				if ~is_preexisting_video_structures_mode
					bbvaVideoFile{video_index}.num_frames_actually_read = bbvaVideoFile{video_index}.num_frames_actually_read + 1;
				end
			else
				curr_greyscale_frame{video_index} = solid_black_frame;
			end
		end

		%% Concatenate the frames
		topRow = [curr_greyscale_frame{1}, curr_greyscale_frame{2}];
		bottomRow = [curr_greyscale_frame{3}, curr_greyscale_frame{4}];
		curr_muxed_greyscale_frame = [topRow; bottomRow];

		%% TODO: write the frames out to a file.
		writeVideo(mux_settings.videoWriter, curr_muxed_greyscale_frame)

		i = i + 1;

	end

	%% Close the output file
	close(mux_settings.videoWriter)

	% write some stuff
	if ~is_preexisting_video_structures_mode
		for video_index = 1:length(videoFileNames)
			% Compute the videoFile timestmap information now that we have the actual number of frames:
			bbvaVideoFile{video_index}.endFrameIndex = bbvaVideoFile{video_index}.num_frames_actually_read;
			bbvaVideoFile{video_index}.frameIndexes = bbvaVideoFile{video_index}.startFrameIndex:bbvaVideoFile{video_index}.endFrameIndex;
			bbvaVideoFile{video_index}.frameTimestamps = bbvaVideoFile{video_index}.parsedDateTime + seconds(bbvaVideoFile{video_index}.frameIndexes/bbvaVideoFile{video_index}.FrameRate);
		end
	end

	%% Write the output files:
	save(mux_settings.final_output_datafile_path, 'bbvaVideoFile','bbvaCurrFrameSegment','mux_settings','-v7.3');

% 'videoParentPath', 'videoFileNames', 'outputName'
else
	disp('dry-run: skipping actual processing.')
end

end
