function [originalImage1, originalImage2, originalImage3, originalImage4, originalImageInfo] = DequadrantizeFrame(quadrantizedFrame)
%DEQUADRANTIZEFRAME Converts a quadrantizedImage back into its original images
%   Detailed explanation goes here

% quadrantizedFrame: a H x W x D image

quadrantized.Size = size(quadrantizedFrame);
quadrantized.height = quadrantized.Size(1);
quadrantized.width = quadrantized.Size(2);
quadrantized.depth = quadrantized.Size(3);

originalImageInfo.depth = quadrantized.depth;
originalImageInfo.height = quadrantized.height / 2.0;
originalImageInfo.width = quadrantized.width / 2.0;
originalImageInfo.Size = [originalImageInfo.height, originalImageInfo.width, originalImageInfo.depth];

right_startWidth = originalImageInfo.width + 1;
bottom_startHeight = originalImageInfo.height + 1;

% 1 is the top left image:
originalImage1 = quadrantizedFrame(1:originalImageInfo.height, 1:originalImageInfo.width, :);

% 2 is the top right image:
originalImage2 = quadrantizedFrame(1:originalImageInfo.height, right_startWidth:end, :);

% 3 is the bottom left image:
originalImage3 = quadrantizedFrame(bottom_startHeight:end, 1:originalImageInfo.width, :);

% 4 is the bottom right image:
originalImage4 = quadrantizedFrame(bottom_startHeight:end, right_startWidth:end, :);

end

