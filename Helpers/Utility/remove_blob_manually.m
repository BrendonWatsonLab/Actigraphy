% Demo to threshold an image to find regions (blobs).
% Then let user point to a blob that you want to eliminate.

clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures if you have the Image Processing Toolbox.
clearvars;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;

% Check that user has the Image Processing Toolbox installed.
hasIPT = license('test', 'image_toolbox');
if ~hasIPT
	% User does not have the toolbox installed.
	message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
	reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
	if strcmpi(reply, 'No')
		% User said No, so exit.
		return;
	end
end
baseFileName = 'coins.png'; % Default

% % Read in a standard MATLAB gray scale demo image.
% folder = fullfile(matlabroot, '\toolbox\images\imdemos');
% button = menu('Use which demo image?', 'CameraMan', 'Moon', 'Eight', 'Coins', 'Pout');
% if button == 1
% 	baseFileName = 'cameraman.tif';
% elseif button == 2
% 	baseFileName = 'moon.tif';
% elseif button == 3
% 	baseFileName = 'coins.png';
% else
% 	baseFileName = 'pout.tif';
% end

% Read in a standard MATLAB gray scale demo image.
folder = fullfile(matlabroot, '\toolbox\images\imdemos');
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
	% File doesn't exist -- didn't find it there.  Check the search path for it.
	fullFileName = baseFileName; % No path this time.
	if ~exist(fullFileName, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
grayImage = imread(fullFileName);
% Get the dimensions of the image.
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(grayImage);
if numberOfColorBands > 1
	% It's not really gray scale like we expected - it's color.
	% Convert it to gray scale by taking only the green channel.
	grayImage = grayImage(:, :, 2); % Take green channel.
end
% Display the original gray scale image.
subplot(2, 3, 1);
imshow(grayImage, []);
title('Original Grayscale Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')

% Let's compute and display the histogram.
[pixelCount, grayLevels] = imhist(grayImage);
subplot(2, 3, 2);
bar(grayLevels, pixelCount);
grid on;
title('Histogram of original image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

% Threshold the image.
binaryImage = grayImage > 100;
% Clean up a bit
binaryImage = bwareaopen(binaryImage, 500);
binaryImage = imfill(binaryImage, 'holes');
% Display the binary image.
subplot(2, 3, 3);
imshow(binaryImage, []);
title('Binary Image', 'FontSize', fontSize);

doAnother = true;
while doAnother
	% Find pixels
	[labeledImage, numberOfBlobs] = bwlabel(binaryImage);
	measurements = regionprops(labeledImage, 'PixelIdxList', 'Centroid')
	allCentroids = [measurements.Centroid];
	centroidX = allCentroids(1:2:end);
	centroidY = allCentroids(2:2:end);
	% Plot the centroids over the blobs
	hold on;
	plot(centroidX, centroidY, 'bo', 'MarkerSize', 10);
	axis on;
	% Put text labels on them.
	for k = 1 : numberOfBlobs
		text(centroidX(k), centroidY(k)+10, num2str(k), 'Color', 'b', 'FontWeight', 'bold');
	end
	promptMessage = sprintf('On the binary image in the upper right,\nClick the region to remove,\nor Cancel to abort processing?');
	titleBarCaption = 'Continue?';
	subplot(2, 3, 3);
	button = questdlg(promptMessage, titleBarCaption, 'Continue', 'Cancel', 'Continue');
	if strcmpi(button, 'Cancel')
		break;
	end
	[x,y] = ginput(1)
	% Plot where they clicked.
	plot(x, y, 'r+', 'MarkerSize', 20, 'LineWidth', 3);
	
	% Find which centroid this (x,y) is closest to
	% First find out the distance from where user clicked to every other centroid.
	xDistances = (centroidX - x);
	yDistances = (centroidY - y);
	distances = sqrt(xDistances .^ 2 + yDistances .^ 2);
	% Find the closest one.
	[minDistance, indexOfClosest] = min(distances)
	% Plot an X over the closest blob.
	plot(centroidX(indexOfClosest), centroidY(indexOfClosest), 'rx', 'MarkerSize', 40, 'LineWidth', 3);
	% Draw a line between them.
	line([x, centroidX(indexOfClosest)], [y, centroidY(indexOfClosest)], 'Color', 'r', 'LineWidth', 2);
	
	% Now remove this index.
	keeperIndexes = 1 : numberOfBlobs; % All of them
	keeperIndexes(indexOfClosest) = []; % Remove this particular blob from the list of blobs.
	% Remove it from the labeled image.
	newLabeledImage = ismember(labeledImage, keeperIndexes);
	% Get new indexes in consequtive order since one if now missing.
	newBinaryImage = newLabeledImage > 0; % All except selected blob.
	% Display the binary image.
	subplot(2, 3, 4);
	imshow(newBinaryImage, []);
	title('New Binary Image', 'FontSize', fontSize);
	% Now make measurements all over again with the indicated blob removed (optional).
	[labeledImage, numberOfBlobs] = bwlabel(binaryImage);
	measurements = regionprops(labeledImage, 'Area');
	
	% Mask the image to make selected blob 0
	% Get the selected blob alone
	selectedBlob = binaryImage & ~newBinaryImage;
	maskedImage1 = grayImage; % Initialize.
	maskedImage1(selectedBlob) = 0;
	% Display the masked image.
	subplot(2, 3, 5);
	imshow(maskedImage1, []);
	title('Masked Image', 'FontSize', fontSize);
	
	% Fill the image with surrounding background.
	% First enlarge blob
	selectedBlob = imdilate(selectedBlob, ones(7));
	% Now do the fill from the boundary.
	maskedImage2 = roifill(grayImage, selectedBlob);
	% Display the masked image.
	subplot(2, 3, 6);
	imshow(maskedImage2, []);
	title('Filled Image', 'FontSize', fontSize);
	
	% If we've deleted the last blob, exit.
	if numberOfBlobs <= 1
		% Bail out if there are no more blobs.
		break;
	end
	
	cumulativeRemoval = true;
	if cumulativeRemoval
		% If you want the removal to be cumulative, set grayImage to be maskedImage2 or maskedImage1.
		% Otherwise comment out the line below to start from the original gray image every time.
		grayImage = maskedImage2;
		binaryImage = newBinaryImage;
	end
end


