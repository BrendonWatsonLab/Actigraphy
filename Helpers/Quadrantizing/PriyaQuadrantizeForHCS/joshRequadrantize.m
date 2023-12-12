function joshRequadrantize(FoundVideoFilesPath, BBlist, BBToAnalyze, BBParentPath)
%TODO: Function definition. What a frame means, how the algorithm to make a quadrantized frame works.

% Author: Priya Vijayakumar, vijayak@umich.edu
% Last Update: 12/6/22 3:30PM EST
%READ: requadrantize.m needs to be in the SAME folder as 1) BB## folder (containing "Current Experiment" folder with videos to analyze)...
% cont... & 2)the corresponding FoundVideoFiles.mat file. 
% Quadrantized Videos will save under subfolder 'MUXED' within the BB## "Current Experiment" subfolder; 
% Other Generated Outputs: 1) black_frame.jpg 2)black_frame.mp4 
%% loading videos

addpath(genpath(FoundVideoFilesPath))   %Folder containing FoundVideoFiles.mat 
addpath(genpath(BBParentPath))          %Folder on Overseer containing the many BB folders with video files from the expt. 
load('FoundVideoFiles.mat')

num_boxes = 1;                          %Set to 1 for testing, use BBlist or BBToAnalyze later.
%num_boxes = size(BBlist,2);
%num_boxes=size(bbIDs,2); - Priya was using bbIDs from foundvideofiles I think?

for k=1:num_boxes
   %if BBToAnalyze(k) == 1 4.2023 Josh-TODO only quadrantize boxes we're interested in.
    box_folder = all_videos_output_data{1,k}.curr_folder;
	% box_number=all_videos_output_data{1,k}.curr_bbID;
	% box_folder=sprintf('BB%s',box_number);
	% formatSpec='%s\\CurrentExperiment';
	% box_folder=sprintf(formatSpec,box_folder);
	% addpath(box_folder);
	vid_data=all_videos_output_data{1,k}.videoFilesData;    %vid_data has name of vid, folder, date, bytes, isdir, datenum
	vid_data=struct2table(vid_data);
	% vid_dir=vid_data.folder{1,1}
	%each column will contain all file names for each BB##
	vid_name=vid_data.name;
	total_vids=size(vid_data,1);
	all_vids={}; %8.7.23 Josh- Why did I do this again? 

    for i = 1:num_boxes
        addpath(all_videos_output_data{1,i}.curr_folder); %messy way to do this now, but ffprobe is difficult to use without this?
        cd(all_videos_output_data{1,i}.curr_folder); %messy way to do this now, but ffprobe is difficult to use without this?
	    for j = 1:17      %for j = 1:total_vids ;changed to 1-17 for quick testing
            videoToAnalyze = vid_name{j};
            [~, videoMetadata] = system(sprintf('ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=width,height,nb_read_packets -print_format csv %s', videoToAnalyze)); 
            videoWidth = str2num(videoMetadata(8:10));      %messy way to confirm width of video frame w/ ffprobe
            videoHeight = str2num(videoMetadata(12:14));    %messy way to confirm the height of the video frame w/ffprobe
            videoNumFrames = str2num(videoMetadata(16:end));    %messy (absolutely degenerate way) to confrim the number of packets (aka vid frames) w/ffprobe
            all_videos_output_data{1, 1}.videoFilesData(j).height = videoHeight;
            all_videos_output_data{1, 1}.videoFilesData(j).width = videoWidth;
            all_videos_output_data{1, 1}.videoFilesData(j).numFrames = videoNumFrames; %Reminder, using num packets, which should be equal to num frames, but no gurantees? (Josh- from testing num packets was always equal to num frames)
            %Note, this command also seems to work at the same speed, but not for windows: 
            %!ffmpeg -i BehavioralBox_B01_T20230113-0528250041.mp4 -map 0:v:0 -c copy -f null -y /dev/null 2>&1 | grep -Eo 'frame= *[0-9]+ *' | grep -Eo '[0-9]+' | tail -1
		    
            %videoToAnalyze = fullfile(box_folder,videoToAnalyze)
		    fprintf('BB%s Video %d: %d Frames \n',box_folder,j, videoNumFrames)          
        end

    disp('Done Loading Vids')   
        
    end    
	
	%v1=all_vids{1,1}; row=v1.Height; col=v1.Width;
        %v1 = all_videos_output_data{1,k}.videoFilesData(1).name;
    % v1 = all_videos_output_data{1, i}.videoFilesData(1).name;
    % row = all_videos_output_data{1, i}.videoFilesData(1).videoHeight;
    % col = vall_videos_output_data{1, i}.videoFilesData(1).videoWidth;

	%% videos properties (appears to be the most time-intensive step)

	%x=total_vids;
	%vid_names=cell(1,x); %refer to all_videos_output_data{1, i}.videoFilesData.name    for the name of BB01videos. 
	%vid_filepaths=cell(1,x); %refer to all_videos_output_data{1, i}.videoFilesData.folder    for the filepaths of BB01videos.
	frames=zeros(1,total_vids); %refer to all_videos_output_data{1, i}.videoFilesData.numFrames    for the name of BB01videos. 
    %12.5.23, what is this step for? Was this something I didn't take out of Priya's code?

    for i=1:17
	%for i=1:total_vids
		%video=all_vids(i);
        videos(i).videoName =all_videos_output_data{1,k}.videoFilesData(i).name;
		videos(i).videoObject = VideoReader(videos(i).videoName); %can I put video objects in the fields of a struct?
		%vid_names{1,i}=video.Name;
		%vid_filepaths{1,i}=video.Path;
		%frames(1,i)=video.NumFrames;
        %6.8.23 Come back and remove this block? I do this already after the ffprobe step of reading height, width, and numFrames.
	end 

	%min_frames=min(frames); %minimum number of frames
	y= ceil(17/4);
    %y= ceil(total_vids/4); %number of quadrants needed
	empty= zeros(2,2,y); 
    remainder=mod(17,4);
	%remainder=mod(total_vids,4); 

	%% determining index of each video
    

    index_list=zeros(1,17);
	%index_list=zeros(1,total_vids);

	if remainder==0
        for i=1:17
		%for i=1:total_vids 
			index_list(1:y)=1;
			index_list(y+1:2*y)=2;
			index_list(2*y+1:3*y)=3;
			index_list(3*y+1:4*y)=4; 
		end 
	elseif remainder==1
        for i=1:17
		%for i=1:total_vids
			index_list(1:y)=1;
			index_list(y+1:2*y-1)=2;
			index_list(2*y:3*y-2)=3;
			index_list(3*y-1:4*y-3)=4;
		end 

	elseif remainder==2
        for i=1:17
		%for i=1:total_vids
			index_list(1:y)=1;
			index_list(y+1:2*y)=2;
			index_list(2*y+1:3*y-1)=3;
			index_list(3*y:4*y-2)=4;
		end 

	elseif remainder==3
        for i=1:17
		%for i=1:total_vids
			index_list(1:y)=1;
			index_list(y+1:2*y)=2;
			index_list(2*y+1:3*y)=3;
			index_list(3*y+1:4*y-1)=4;
		end 
	end 

	%% assigning index to each video

	%how many instances of each quadrant position
	index_list_chr= mat2str(index_list);
	num_1= count(index_list_chr,'1'); num_2= count(index_list_chr,'2'); num_3= count(index_list_chr,'3'); num_4= count(index_list_chr,'4');
	grayframes=max([num_1 num_2 num_3 num_4]); %confusion, shouldn't this be the reaminders?
    %maybe Priya is generating a grayframe (why name it this and not black frame?) that videos will stitch into/over?

	%puts videos in list based on their assigned index
	vid1=[]
    vid2=[]
    vid3=[]
    vid4=[]

    for i=1:17
	%for i=1:total_vids
		if index_list(1,i)==1
			  vid1= [vid1 all_vids(1,i)];zero1=cell(1,grayframes-num_1);
		elseif index_list(1,i)==2
			vid2= [vid2 all_vids(1,i)];zero2=cell(1,grayframes-num_2);
		elseif index_list(1,i)==3
			vid3= [vid3 all_vids(1,i)];zero3=cell(1,grayframes-num_3);
		elseif index_list(1,i)==4
			vid4= [vid4 all_vids(1,i)];zero4=cell(1,grayframes-num_4);
		end 
	end

	%appends zeros based on empty elements necessary
	vid1=[vid1 zero1]; vid2=[vid2 zero2]; vid3=[vid3 zero3]; vid4=[vid4 zero4];

	%puts indices in correct quadrant
	empty_quad=cell(2,2,y);

	for k=1:y
		empty_quad{1,1,k}=vid1{1,k}; empty_quad{1,2,k}=vid2{1,k}; empty_quad{2,1,k}=vid3{1,k}; empty_quad{2,2,k}=vid4{1,k};
	end 


	% video stitching

	length=v1.NumFrames;
	vid_dir=filepath;
	mkdir(fullfile(vid_dir,'MUXED'));

	%generates blank frame for filler elements
	if isfile('black_frame.jpg')
		%do nothing
		blank_dir=vid_dir(1:end-23)
		filler_path=fullfile(blank_dir, 'black_frame.mp4')
	else
		solid_black_frame = zeros([row, col], 'uint8'); blank_dir=vid_dir(1:end-23); 
		filler_path=fullfile(blank_dir,'black_frame.jpg');
		imwrite(solid_black_frame,filler_path)
		%SOMETHING IS WRONG
		eval(['!ffmpeg -framerate 30 -i black_frame.JPG -vf format=yuv420p black_frame.mp4']); 
		filler_path=fullfile(blank_dir, 'black_frame.mp4');
	end 

	%stitches all videos together based on assigned indices
	for j=1:y
		filename = sprintf('BB%s_quadrantized_%d.mp4',box_number,j);
		output=fullfile(vid_dir,'MUXED',filename);
		q1=empty_quad(:,:,j);
		v1=q1{1,1}; v2=q1{1,2}; v3=q1{2,1}; v4=q1{2,2};
		if isempty(v1)
			v1=filler_path;
		else
			v1=q1{1,1}.Name; v1=fullfile(vid_dir, v1);
		end

		if isempty(v2)
			v2=filler_path;
		else
			v2=q1{1,2}.Name; v2=fullfile(vid_dir, v2);
		end

		if isempty(v3)
			v3=filler_path;
		else
			v3=q1{2,1}.Name; v3=fullfile(vid_dir, v3); 
		end
		if isempty(v4)
			v4=filler_path;
		else
			v4=q1{2,2}.Name; v4=fullfile(vid_dir, v4);
		end
		eval(['!ffmpeg -i "' v1 '" -i "' v3 '" -i "' v2 '" -i "' v4 '" -filter_complex " [0:v] setpts=PTS-STARTPTS, scale=qvga [a0]; [1:v] setpts=PTS-STARTPTS, scale=qvga [a1]; [2:v] setpts=PTS-STARTPTS, scale=qvga [a2]; [3:v] setpts=PTS-STARTPTS, scale=qvga [a3]; [a0][a1][a2][a3]xstack=inputs=4:layout=0_0|0_h0|w0_0|w0_h0[out] " -map "[out]" -c:v libx264 "' output '"'])  ;
		sprintf('Quadrantized Video #%d is Complete!',j);
    end
    rmpath(all_videos_output_data{1,i}.curr_folder);%Josh- from line 35, messy way to do this now, but ffprobe is difficult to use without this?
end 
	
end
