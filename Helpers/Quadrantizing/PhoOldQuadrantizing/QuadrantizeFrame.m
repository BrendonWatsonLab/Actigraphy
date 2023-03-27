function [quadrantizedFrame, quadrantizedImageInfo] = QuadrantizeFrame(originalImage1, originalImage2, originalImage3, originalImage4)
%QUADRANTIZEFRAME This function takes 4 equally sized frames and combines them into a 2x2 grid of images.
%   Detailed explanation goes here


originalImageInfo.Size = size(originalImage1);
originalImageInfo.height = originalImageInfo.Size(1);
originalImageInfo.width = originalImageInfo.Size(2);
originalImageInfo.depth = originalImageInfo.Size(3);

quadrantizedImageInfo.depth = originalImageInfo.depth;
quadrantizedImageInfo.height = originalImageInfo.height * 2.0;
quadrantizedImageInfo.width = originalImageInfo.width * 2.0;
quadrantizedImageInfo.Size = [quadrantizedImageInfo.height, quadrantizedImageInfo.width, quadrantizedImageInfo.depth];

%% Concatenate the frames
% 	topRow = [curr_greyscale_frame{1}, curr_greyscale_frame{2}];
% 	bottomRow = [curr_greyscale_frame{3}, curr_greyscale_frame{4}];

% Build the Output
topRow = [originalImage1, originalImage2];
bottomRow = [originalImage3, originalImage4];
quadrantizedFrame = [topRow; bottomRow];
	
	
end

