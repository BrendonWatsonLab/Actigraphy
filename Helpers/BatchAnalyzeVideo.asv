function [results, curr_output_bbvaSettings, bbvaSettings, bbvaVideoFile, bbvaCurrFrameSegment] = BatchAnalyzeVideo(curr_video_parent_path, curr_video_name, curr_output_parent_path, curr_output_relative_path, should_print_status)
%BATCHANALYZEVIDEO Performs Actigraphy (frame-to-frame difference quantification) analysis on video files.
%   Detailed explanation goes here
% curr_video_parent_path: 
% curr_video_name: 'BehavioralBox_B02_T20200220-2214440165.mp4'
% curr_output_parent_path: the folder you want to create the relative output folders in.
% curr_output_relative_path: should be the BBID probably


% Pho Behavioral Box Recordings Analysis Video Processing Project
% Pho Hale, created 04-27-2020
% Goal: Given an input video of a mouse in the behavioral box, develop some metrics to process it

%% Script Operation bbvaSettings:
% should_generate_processed_frames: if true, accumulates two arrays: 
%    processedFrames: the greyscale frame
% If set to false, it greatly lowers memory requirements and speeds up processing. Should be set to true for debugging.
bbvaSettings.should_generate_processed_frames = false;
% bbvaSettings.should_generate_processed_frames = true;

%%%+S- bbvaSettings
	%- *should_generate_processed_frames - should_generate_processed_frames: if true, accumulates frame arrays. if false, it greatly lowers memory requirements and speeds up processing. Should be set to true for debugging.
	%- *curr_output_root - curr_output_root is a 
	%- *output_relative_path - output_relative_path is a 
	%- curr_output_folder_root - curr_output_folder_root is a 
	%- *shouldInvertAllImages - shouldInvertAllImages is a 
	%- *shouldUseBaselineDifferencing - shouldUseBaselineDifferencing is a 
	%- *intra_frame_gap - intra_frame_gap is The number of frames between the two frames to compare
	%- *use_readFrame_mode - use_readFrame_mode is a 
%

%%%+S- curr_output_bbvaSettings
	%- video_frame_string - video_frame_string is string containing the current frames processed in this segment
	%- final_output_path - final_output_path is the final path of the actigrpahy output file produced by this script
	%- final_output_name - final_output_name is the final name of the actigrpahy output file produced by this script
%

%%%+S- bbvaVideoFile
	%- filename* - filename is the filename with extension
	%- relative_file_path - relative_file_path is a 
	%- basename - basename is a 
	%- extension - extension is a 
	%- full_parent_path - full_parent_path is a 
	%- full_path - full_path is a 
	%- boxID - boxID is a 
	%- parsedDateTime - parsedDateTime is a 
	%- FrameRate - FrameRate is a 
	%- DurationSeconds - DurationSeconds is a 
	%- parsedEndDateTime - parsedEndDateTime is a 
	%- startFrameIndex - startFrameIndex is a 
    %- estimatedEndFrameIndex - estimatedEndFrameIndex is the number of frames estimated by videoReader
	%- endFrameIndex - endFrameIndex is a 
	%- frameIndexes - frameIndexes is a 
	%- frameTimestamps - frameTimestamps is a 
	%- num_frames_actually_read - num_frames_actually_read is the number of frames actually read during the getFrame method.
%

%%%+S- bbvaCurrFrameSegment: The block of frames in the current segment: WARNING: the endFrameIndex can be not-reflective of the video's end frame index due to VideoReader estimation errors.
	%- startFrameIndex - startFrameIndex is Absolute video frame to start on
	%- endFrameIndex - endFrameIndex is Absolute video frame to end on
	%- absoluteVideoFrameIndexes - absoluteVideoFrameIndexes is The absolute video indicies corresponding to this segment.
	%- selectedNumberOfFrames - selectedNumberOfFrames
	%- segmentRelativeFrameIndexes - segmentRelativeFrameIndexes is The 1:bbvaCurrFrameSegment.selectedNumberOfFrames indicies for this segment
%



%% Input bbvaSettings:


%% Output bbvaSettings:
bbvaSettings.curr_output_root = curr_output_parent_path;

if exist('curr_output_relative_path','var')
	bbvaSettings.output_relative_path = curr_output_relative_path;
else
	bbvaSettings.output_relative_path = "PhoAnalysis";
end

if ~exist('should_print_status','var')
	should_print_status = false;
end

%%%%! Begin Program:

% Include the helper functions in the path
% addpath(genpath('PhoEyeAnalysis'))
% addpath(genpath('../Helpers'))

%% Computed Properties:
%    Filesystem Paths

bbvaSettings.curr_output_folder_root = bbvaSettings.curr_output_root;
if ~exist(bbvaSettings.curr_output_folder_root, 'dir')
    mkdir(bbvaSettings.curr_output_folder_root); % Create the folder if needed
end


%% UNDO IF NEEDED TODO: replace this whole section with [bbvaVideoFile, bbvaCurrFrameSegment] = BuildVideoFileReaderStructure(curr_video_parent_path, curr_video_name);
%Be sure to re-enable bbvaVideoFile.filename = curr_video_name; above as well

bbvaVideoFile.filename = curr_video_name;
bbvaVideoFile.relative_file_path = fullfile(curr_video_parent_path, bbvaVideoFile.filename);
[~,bbvaVideoFile.basename, bbvaVideoFile.extension] = fileparts(bbvaVideoFile.filename);
v = VideoReader(bbvaVideoFile.relative_file_path);
bbvaVideoFile.full_parent_path = v.Path;
bbvaVideoFile.full_path = fullfile(bbvaVideoFile.full_parent_path, bbvaVideoFile.filename);
[videoFileInfo] = ParsePhoOBSVideoFileName(bbvaVideoFile.full_path);
bbvaVideoFile.boxID = videoFileInfo.boxID;
bbvaVideoFile.parsedDateTime = videoFileInfo.dateTime;
tempVideoReaderInfo = get(v);
% Number of video frames per second
bbvaVideoFile.FrameRate = tempVideoReaderInfo.FrameRate;
% Length of the file in seconds
bbvaVideoFile.DurationSeconds = tempVideoReaderInfo.Duration;
bbvaVideoFile.parsedEndDateTime = bbvaVideoFile.parsedDateTime + seconds(bbvaVideoFile.DurationSeconds);
bbvaVideoFile.num_frames_actually_read = 0;

%    Video Frames
startFrameIndex = 1;
endFrameIndex = v.numFrames;

% All frames of the video file:
bbvaVideoFile.startFrameIndex = 1;
bbvaVideoFile.estimatedEndFrameIndex = v.numFrames;
bbvaVideoFile.endFrameIndex = v.numFrames;
bbvaVideoFile.frameIndexes = bbvaVideoFile.startFrameIndex:bbvaVideoFile.endFrameIndex;
bbvaVideoFile.frameTimestamps = bbvaVideoFile.parsedDateTime + seconds(bbvaVideoFile.frameIndexes/bbvaVideoFile.FrameRate);


% The block of frames in the current segment:
bbvaCurrFrameSegment.startFrameIndex = 1; % Absolute video frame to start on
bbvaCurrFrameSegment.endFrameIndex = bbvaVideoFile.estimatedEndFrameIndex; % Absolute video frame to end on
bbvaCurrFrameSegment.absoluteVideoFrameIndexes = bbvaCurrFrameSegment.startFrameIndex:bbvaCurrFrameSegment.endFrameIndex; % The absolute video indicies corresponding to this segment.
bbvaCurrFrameSegment.selectedNumberOfFrames = length(bbvaCurrFrameSegment.absoluteVideoFrameIndexes);
bbvaCurrFrameSegment.segmentRelativeFrameIndexes = 1:bbvaCurrFrameSegment.selectedNumberOfFrames; % The 1:bbvaCurrFrameSegment.selectedNumberOfFrames indicies for this segment

%%%[bbvaVideoFile, bbvaCurrFrameSegment] = BuildVideoFileReaderStructure(curr_video_parent_path, curr_video_name);


%    Output bbvaSettings
% curr_output_data_path = fullfile(bbvaVideoFile.full_parent_path, bbvaSettings.output_relative_path); % Location to save the data
curr_output_data_path = fullfile(bbvaSettings.curr_output_folder_root, bbvaSettings.output_relative_path); % Location to save the data
if ~exist(curr_output_data_path, 'dir')
    mkdir(curr_output_data_path); % Create the directory if needed
end
% Build the final output info:
curr_output_bbvaSettings = makeActigraphyOutputFileName(bbvaVideoFile.basename, bbvaCurrFrameSegment.startFrameIndex, bbvaCurrFrameSegment.endFrameIndex);
curr_output_bbvaSettings.final_output_path = fullfile(curr_output_data_path, curr_output_bbvaSettings.final_output_name);

% 
% curr_output_bbvaSettings.video_name_string = bbvaVideoFile.basename;
% curr_output_bbvaSettings.video_frame_string = sprintf("frames_%d-%d",bbvaCurrFrameSegment.startFrameIndex,bbvaCurrFrameSegment.endFrameIndex);
% curr_output_bbvaSettings.frames_data_output_suffix = 'processed_output';
% 
% curr_output_bbvaSettings.final_output_name = join([curr_output_bbvaSettings.frames_data_output_suffix, curr_output_bbvaSettings.video_name_string, curr_output_bbvaSettings.video_frame_string, ".mat"],"_");
% curr_output_bbvaSettings.final_output_path = fullfile(curr_output_data_path, curr_output_bbvaSettings.final_output_name);

%% Pre-allocate output structures: This should be done for the current segment
num_output_frames_to_allocate = bbvaCurrFrameSegment.selectedNumberOfFrames;
% processedFrame_isFrameProcessed = zeros([num_output_frames_to_allocate,1], 'logical');

if (bbvaSettings.should_generate_processed_frames)
%     processedFrameSegmentations = zeros([512, 640, num_output_frames_to_allocate], 'logical');
    processedFrames = zeros([512, 640, num_output_frames_to_allocate], 'uint8');
    % processedBinaryFrames = zeros([512, 640, num_output_frames_to_allocate], 'logical');
end


% Expects a video object named 'v', 'bbvaVideoFile',;


% bbvaSettings:
bbvaSettings.shouldInvertAllImages = true;
bbvaSettings.shouldUseBaselineDifferencing = false;
bbvaSettings.intra_frame_gap = 1; % The number of frames between the two frames to compare
bbvaSettings.use_readFrame_mode = true;
% bbvaSettings.use_readFrame_mode = false;

if bbvaSettings.shouldUseBaselineDifferencing
	% Select static reference frame to be subtracted (without the mouse in the pic):
	static_reference_frame_index = 1;
	static_reference_frame = rgb2gray(read(v,static_reference_frame_index,"native"));
	if shouldInvertAllImages
		static_reference_frame = imcomplement(static_reference_frame);
	end

	% Start Frame for analysis. Can be the frame just after the mouse is introduced, or after everything is settled down:
	start_frame_index = static_reference_frame_index;
	
else
	% Start Frame for analysis. Can be the frame just after the mouse is introduced, or after everything is settled down:
	start_frame_index = bbvaCurrFrameSegment.startFrameIndex;
	
end

estimated_frame_indicies = start_frame_index:bbvaVideoFile.estimatedEndFrameIndex;

% num_frames_to_process = length(frame_indicies);
estimated_num_frames_to_process = length(estimated_frame_indicies);

% Allocate Results (Outputs):
results.num_changed_pixels = zeros([estimated_num_frames_to_process, 1]);
results.total_sum_changed_pixel_value = zeros([estimated_num_frames_to_process, 1]);
% results.max_pixel_value_change = zeros([num_frames_to_process, 1]);


%% Main Run:    
if exist('prev_greyscale_frame','var')
    clear prev_greyscale_frame;
end

i = 1;
bbvaVideoFile.num_frames_actually_read = 0;

while hasFrame(v)
    if (mod(i, 30) == 0)
        % Display the output message every 30 frames (1-second) of video.
        if should_print_status
            disp(['Processing ', num2str(i), ' of ', num2str(estimated_num_frames_to_process), ' Estimated Frames...'])
        end
    end

    if bbvaSettings.shouldInvertAllImages
        curr_greyscale_frame = imcomplement(rgb2gray(readFrame(v, 'native')));
    else
        curr_greyscale_frame = rgb2gray(readFrame(v, 'native'));
    end

    if exist('prev_greyscale_frame','var')
        inter_frame_change = abs(curr_greyscale_frame - prev_greyscale_frame);
        % Compute number of different pixels:
        results.num_changed_pixels(i) = sum((inter_frame_change > 1),'all');
        % Compute the sum of different pixel values (total change):
        results.total_sum_changed_pixel_value(i) = sum(inter_frame_change,'all');
        % Compute the max changed pixel value:
        % 	results.max_pixel_value_change(i) = max(inter_frame_change,'all');

    else
        % It's just the first frame, and we don't have a previous frame to compare it to

    end

    prev_greyscale_frame = curr_greyscale_frame;
    i = i + 1;
    bbvaVideoFile.num_frames_actually_read = bbvaVideoFile.num_frames_actually_read + 1;
end

% Compute the videoFile timestmap information now that we have the actual number of frames:
bbvaVideoFile.endFrameIndex = bbvaVideoFile.num_frames_actually_read;
bbvaVideoFile.frameIndexes = bbvaVideoFile.startFrameIndex:bbvaVideoFile.endFrameIndex;
bbvaVideoFile.frameTimestamps = bbvaVideoFile.parsedDateTime + seconds(bbvaVideoFile.frameIndexes/bbvaVideoFile.FrameRate);


%% Write the output files:
save(curr_output_bbvaSettings.final_output_path, 'bbvaVideoFile','bbvaCurrFrameSegment', 'bbvaSettings', 'results','-v7.3');

end

