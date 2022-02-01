function [bw_flood_filling_mask_final, bw_flood_filling_mask_no_holes, active_preprocessing_results, pca_exportSettings, phiImageFixedBackgroundRemoved, phiImageColorRangeFixed] = FnPhoCustomAnalysis(active_background_frame_original_image, currFrameImage, currFrameIndex, iips_OutputStats)
%FNPHOCUSTOMANALYSIS Summary of this function goes here
%   This is an adaptation of the livescript 'Pho_06_21_2020_Custom_Analysis.mlx' to a function form.
% Takes a single frame of the video in as input.

should_invert_all_images = true;
% should_maximize_contrast_all_image: if true, performs.
should_maximize_contrast_all_image = false;
% should_maximize_contrast_all_intermediate_processed_images: if true, performs imadjust on each intermediate step of the computation.
should_maximize_contrast_all_intermediate_processed_images = false;

% Background Image: Display only settings:
should_show_background_image_inverted = true;
should_show_background_image_heatmap = false;

% Display only settings:
should_plot_original_image_separate_figure = false; % should_plot_original_image_separate_figure: if true, plots the original image in a separate figure in addition to combined with the results.
should_show_original_image_inverted = true;
should_show_original_image_heatmap = false;
should_show_max_contrast_image = true;


% Export Settings:

%%%+S- pca_exportSettings
    %- should_export_image_to_disk - if true, saves the processed result to disk
    %- curr_fig_export_path -
    %= curr_output_name - constructed from the actual frame index
    %= curr_output_path - 
%
pca_exportSettings.should_export_image_to_disk = true;
pca_exportSettings.curr_fig_export_path = '/Volumes/Speakhard/Temp/Videos/BB02/SAMPLED/ExtractedFrames/PhoProcessed';
pca_exportSettings.curr_output_name = '';
pca_exportSettings.curr_output_path = '';


active_frames_results.originalImage = currFrameImage;
active_background_frame.originalImage = active_background_frame_original_image;

% Background Image: Invert and Maximize Contrast if needed.
if should_maximize_contrast_all_image
    active_background_frame.image = imadjust(active_background_frame.originalImage);
else
    active_background_frame.image = active_background_frame.originalImage;
end

if should_invert_all_images
    active_background_frame.image = imcomplement(active_background_frame.image);
else
    active_background_frame.image = active_background_frame.image;
end


if should_invert_all_images & (~should_show_background_image_inverted)
    % Invert back to get the original image.
    phiImageBackground.image = active_background_frame.originalImage;
else
    phiImageBackground.image = active_background_frame.image;
end
% phiImageBackground.title = 'background_frame_image';
% 
% if ~should_show_background_image_heatmap
%     phiImageBackground.colorMap = 'Gray';
% else
%     phiImageBackground.colorMap = '';
% end
% % Background Image: Plot:
% [curr_fig, h_plots, h] = plotHeatImageComparison(phiImageBackground);


%% All Images: Start processing:
% active_preprocessing_results = cell([1,numImages]);
% active_preprocessing_results will be an empty struct

if should_maximize_contrast_all_image
	active_frames_results.image = imadjust(active_frames_results.originalImage);
else
	active_frames_results.image = active_frames_results.originalImage;
end

if should_invert_all_images
	% Invert the image if that's needed
	active_frames_results.image = imcomplement(active_frames_results.image);
else
	active_frames_results.image = active_frames_results.image;
end
% Maximize contrast:
% Adjust data to span data range.
active_frames_results.maxContrastImage = imadjust(active_frames_results.image);

% Normalized Difference from Baseline:
[active_preprocessing_results.curr_change_from_baseline, active_preprocessing_results.curr_frame_hist] = FnComputeNormalizedDifferenceFromBaseline(active_background_frame.image, active_frames_results.image);

% Momentum Change from Baseline:
active_preprocessing_results.curr_momentum_change_from_baseline = active_preprocessing_results.curr_change_from_baseline .* active_frames_results.image;

active_preprocessing_results.curr_non_equalized_change_from_baseline = abs(active_frames_results.image - active_background_frame.image);
if should_maximize_contrast_all_intermediate_processed_images
	active_preprocessing_results.curr_non_equalized_change_from_baseline = imadjust(active_preprocessing_results.curr_non_equalized_change_from_baseline);
end

% Equalize the Histograms of the current frame and the static reference frame for valid comparisons.
active_preprocessing_results.curr_normalized_static_reference_frame = histeq(active_background_frame.image, active_preprocessing_results.curr_frame_hist);
active_preprocessing_results.curr_directional_change_from_baseline = active_frames_results.image - active_preprocessing_results.curr_normalized_static_reference_frame; % Uses no absolute value:
active_preprocessing_results.curr_reversed_directional_change_from_baseline = active_preprocessing_results.curr_normalized_static_reference_frame - active_frames_results.image;

% IDEA:  Threshold the change at required to show up at the lower boundary of the mouse change in front of the object.

% IDEA:  Subtract off the inverse of the background after the fact?

% IDEA:  Look at the percent change from background (no that would be less when the mouse is over a darker part in the background too).

% IDEA:  Throw out the elements of the image that get lighter by throwing out the absolute value in the FnComputeNormalizedDifferenceFromBaseline function, and instead only consider the values getting darker. (I mean the opposite for the inverted images).


%% Begin Main Processing Section:
curr_result = active_frames_results;
curr_image = curr_result.image;
curr_maxContrastImage = curr_result.maxContrastImage;
curr_change_from_baseline_image = active_preprocessing_results.curr_change_from_baseline;
curr_non_equalized_change_from_baseline = active_preprocessing_results.curr_non_equalized_change_from_baseline;

curr_momentum_change_from_baseline = active_preprocessing_results.curr_momentum_change_from_baseline;

curr_directional_change_from_baseline = active_preprocessing_results.curr_directional_change_from_baseline;
curr_reversed_directional_change_from_baseline = active_preprocessing_results.curr_reversed_directional_change_from_baseline;

% disp('currImage:')
% imshow(curr_image)
curr_index_string = ['[', num2str(currFrameIndex), ']'];
% plotHeatImage(curr_image, ['curr_image' curr_index_string]);
% disp('curr_change_from_baseline_image')
% imshow(curr_change_from_baseline_image)

% plotHeatImage(curr_change_from_baseline_image, ['curr_change_from_baseline_image' curr_index_string]);

% curr_figure_index = 13370;

if should_show_max_contrast_image
    phiImageCurr.image = curr_maxContrastImage;
else
    phiImageCurr.image = curr_image;
end

if should_invert_all_images & (~should_show_original_image_inverted)
    % Invert back to get the original image.
    phiImageCurr.image = imcomplement(phiImageCurr.image);
else
    phiImageCurr.image = phiImageCurr.image;
end
% phiImageCurr.title = ['curr_image' curr_index_string];
% 
% if ~should_show_original_image_heatmap
%     phiImageCurr.colorMap = 'Gray';
% else
%     phiImageCurr.colorMap = '';
% end
% 
% % Background Image: Plot:
% if should_plot_original_image_separate_figure
%     [curr_fig, h_plots, h] = plotHeatImageComparison(phiImageCurr);
% end

phiImageCurrChangeFromBaseline.image = curr_change_from_baseline_image;
phiImageCurrChangeFromBaseline.title = ['curr_change_from_baseline_image' curr_index_string];
% phiImageCurr.colorMap = '';

phiImageCurrDirectionalChangeFromBaseline.image = curr_directional_change_from_baseline;
phiImageCurrDirectionalChangeFromBaseline.title = ['curr_directional_change_from_baseline' curr_index_string];


phiImageCurrReversedDirectionalChangeFromBaseline.image = curr_reversed_directional_change_from_baseline;
phiImageCurrReversedDirectionalChangeFromBaseline.title = ['curr_reversed_directional_change_from_baseline' curr_index_string];

phiImageCurrMomentumChangeFromBaseline.image = curr_momentum_change_from_baseline;
phiImageCurrMomentumChangeFromBaseline.title = ['curr_momentum_change_from_baseline' curr_index_string];

phiImageCurrNonEqualizedChangeFromBaseline.image = curr_non_equalized_change_from_baseline;
phiImageCurrNonEqualizedChangeFromBaseline.title = ['curr_non_equalized_change_from_baseline' curr_index_string];

% %% PLOT:
% curr_figure_title = ['Processing Phase 0: Change from Baseline Comparsion: Source Image ', curr_index_string];
% [curr_fig, curr_figure_index] = phoCustomPlot(curr_figure_index, false, curr_figure_title);
% [curr_fig, h_plots, h] = plotHeatImageComparison(curr_fig, phiImageCurr, phiImageCurrChangeFromBaseline, phiImageCurrNonEqualizedChangeFromBaseline);


% For some unknowable reason, setting the figure to be visible loses the annotations.

% Export Only Settings:
pca_exportSettings.curr_output_name = [num2str(currFrameIndex), '.png']; % Add Extension
pca_exportSettings.curr_output_path = fullfile(pca_exportSettings.curr_fig_export_path, pca_exportSettings.curr_output_name);

% if pca_exportSettings.should_export_image_to_disk
%     fprintf('Writing file out to %s... ', pca_exportSettings.curr_output_path);
%     saveas(curr_fig, pca_exportSettings.curr_output_path)
%     %imwrite(exportImage, curr_output_path, 'bmp'); % Write it out to file           
%     fprintf('Current Image written to %s.\n', pca_exportSettings.curr_output_path)
% end

% Find Maximum:
% largest_row_values = maxk(curr_change_from_baseline_image, 10) % Finds the 10 largest values of each row of the matrix
% largest_values = maxk(largest_row_values, 10)
% largest_value_index = find(curr_change_from_baseline_image == largest_values(1))

% [largest_column_values, largest_column_value_indicies] = max(curr_change_from_baseline_image,[],1);
% [largest_row_values, largest_row_value_indicies] = max(curr_change_from_baseline_image,[],2);

[largest_value, largest_value_linear_index] = max(curr_change_from_baseline_image,[],"all",'linear'); % largest_value_linear_index is unused. We just search instead
% [largest_x, largest_y] = find(curr_change_from_baseline_image==largest_value)
fprintf('Maximum Value: %f\n',largest_value);

maxima_linear_index = find(curr_change_from_baseline_image==largest_value);
if length(maxima_linear_index) > 1
    disp("Warning: found two maxima points:")
    disp(maxima_linear_index)
    disp('Choose first one and discarding second...')
    % TODO: perhaps try both, or do something more intellegent than just choosing one at random.
    maxima_linear_index = maxima_linear_index(1);
end
% [maxima_row_index, maxima_col_index] = ind2sub(size(curr_change_from_baseline_image), maxima_linear_index);
% h_roi_indicator_point_handle = drawpoint('Position', [maxima_row_index, maxima_col_index],"InteractionsAllowed","none","Label","Maxima","LabelVisible","hover"); % 'Position' and a 1-by-2 array of the form [x y]
%disp('Largest values:', string(largest_values))
%disp('Largest value indicies:', string(largest_value_index))

% Flood filling
bw_flood_filling_mask.image = FnFloodFillMask(curr_change_from_baseline_image, maxima_linear_index);
bw_flood_filling_mask.title = 'bw_flood_filling_mask';
bw_flood_filling_mask.colorMap = 'Gray';

% figure()
% stats = regionprops(bw_flood_filling_mask.image,"all");
% centroid = stats.Centroid;
% imshow(stats.FilledImage);

% Plot flood fill.
% %% PLOT:
% curr_figure_title = ['Processing Phase I: Flood Filling Mask: Source Image ', curr_index_string];
% [curr_fig, curr_figure_index] = phoCustomPlot(curr_figure_index, false, curr_figure_title);
% [~, h_plots, h] = plotHeatImageComparison(curr_fig, bw_flood_filling_mask);


% [edgePointLinearIndicies, bwEdgePoints.image] = FnFindBoundaryPixels(bw_flood_filling_mask.image);
% bwEdgePoints.title = 'bwEdgePoints';
% bwEdgePoints.colorMap = 'Gray';

% %% PLOT:
% curr_figure_title = ['Edge Points: Source Image ', curr_index_string];
% [curr_fig, curr_figure_index] = phoCustomPlot(curr_figure_index, false, curr_figure_title);
% [~, h_plots, h] = plotHeatImageComparison(curr_fig, bwEdgePoints);

% Fill in the holes:

% bw_flood_filling_mask_no_holes = imfill(bw_flood_filling_mask, 'holes');

se = strel('disk',9); % 9 gets rid of the holes completely, at the cost of the fineness of the outline
% bw_flood_filling_mask_no_holes = imerode( bw_flood_filling_mask , se );

% bw_flood_filling_mask_no_holes = imdilate( bw_flood_filling_mask , se );
bw_flood_filling_mask_no_holes.image = imclose(bw_flood_filling_mask.image, se);
bw_flood_filling_mask_no_holes.title = 'bw_flood_filling_mask_no_holes';
bw_flood_filling_mask_no_holes.colorMap = 'Gray';

% % PLOT:
% curr_figure_title = ['Processing Phase II: Flood Filling Mask with No Holes: Source Image ', curr_index_string];
% [curr_fig, curr_figure_index] = phoCustomPlot(curr_figure_index, false, curr_figure_title);
% [~, h_plots, h] = plotHeatImageComparison(curr_fig, bw_flood_filling_mask_no_holes);

% curr_fig_prefix = 'PhoFloodFillingMask-06-25-2020_Frame_';
% curr_output_name = [curr_fig_prefix, num2str(currFrameIndex), '.png']; % Add Extension
% curr_output_path = fullfile(pca_exportSettings.curr_fig_export_path, curr_output_name);
% if pca_exportSettings.should_export_image_to_disk
%     fprintf('Writing file out to %s... ', curr_output_path);
%     saveas(curr_fig, curr_output_path)         
%     fprintf('Flood Fill Image written to %s.\n', curr_output_path)
% end


% Use Mask to constrain color:

% FIXIT Attempt
%phiImageFixed.image = curr_image .* curr_change_from_baseline_image;
% phiImageFixed.image = curr_image + curr_change_from_baseline_image;


% Processing: Remove the erronious features that the mouse was supposed to be occluding that were inappropriately added when subtracting the background. This probably needs to be done on the un-normalized subtracted version, and we need to watch for ABS problems.
% Actually, why add it back in? Just start fresh with the best-guess mask and the background.
phiImageFixed.image = curr_change_from_baseline_image;
phiImageFixed.title = ['fixed_image' curr_index_string];

phiImageFixedMasked.image = phiImageFixed.image;
phiImageFixedMasked.image(~bw_flood_filling_mask_no_holes.image) = 0;
phiImageFixedMasked.title = ['fixed_image_masked' curr_index_string];

phiImageFixedBackgroundRemoved.image = phiImageFixedMasked.image;
quickAddImage = active_background_frame.image;
quickAddImage(~bw_flood_filling_mask_no_holes.image) = 0; % We clear the non-mouse region from the background image, so the image only reflects the background values that were subtracted off in the first step from the mouse region.
phiImageFixedBackgroundRemoved.image = phiImageFixedBackgroundRemoved.image + quickAddImage; % We add the values subtracted off back in to compensate.

phiImageFixedBackgroundRemoved.title = ['fixed_image_backgrounded' curr_index_string];

% %% PLOT:
% curr_figure_title = ['Processing Phase III: Fixed Image Attempt: Source Image ', curr_index_string];
% [curr_fig, curr_figure_index] = phoCustomPlot(curr_figure_index, false, curr_figure_title);
% [curr_fig, h_plots, h] = plotHeatImageComparison(curr_fig, phiImageCurr, phiImageFixedMasked, phiImageFixedBackgroundRemoved);


%% Apply Computed Color Stats to Image:
if exist('iips_OutputStats','var')
	% iips_OutputStats.nameToIndexMap('Floor')
	currStatsGroupIndex = iips_OutputStats.nameToIndexMap('MouseBody');
	currStatsGroupMin = iips_OutputStats.nanmin(currStatsGroupIndex);
	currStatsGroupMax = iips_OutputStats.nanmax(currStatsGroupIndex);

	% currStatsGroupMean = iips_OutputStats.means(currStatsGroupIndex);
	currStatsGroupRange = iips_OutputStats.ranges(currStatsGroupIndex);

	currStatsGroup_ExtraTolerance = currStatsGroupRange * 0.2; % Allow wiggle room of up to 10% more of the range
	currStatsGroup_ComputedLowerThreshold = (currStatsGroupMin - currStatsGroup_ExtraTolerance);

	fprintf('MouseBody (min: %i, max: %i)\n', currStatsGroupMin, currStatsGroupMax);

	% original_image_above_threshold_mask: regions where the original image is above the threshold:
	original_image_above_threshold_mask = (curr_image >= currStatsGroup_ComputedLowerThreshold);

	% Compute the color range improved image:
	phiImageColorRangeFixed.image = phiImageFixedBackgroundRemoved.image; % Start with most advanced image we have
	phiImageColorRangeFixed.image(~original_image_above_threshold_mask) = 0; % zero out any areas that weren't above the mouse threshold (meanining unlikely to contain a mouse based on color alone) in the original image

	

	% %% PLOT:
	% curr_figure_title = ['Processing Phase IV: Fixed Image Attempt: Color Range Clamped: Source Image ', curr_index_string];
	% [curr_fig, curr_figure_index] = phoCustomPlot(curr_figure_index, true, curr_figure_title);
	% [curr_fig, h_plots, h] = plotHeatImageComparison(curr_fig, phiImageFixedBackgroundRemoved, phiImageColorRangeFixed);

	% Compute the final binary threshold mask:
	bw_flood_filling_mask_final.image = bw_flood_filling_mask_no_holes.image;
	bw_flood_filling_mask_final.image(~original_image_above_threshold_mask) = 0; 



else
	disp('Warning: No color stats (iips_OutputStats)')
	phiImageColorRangeFixed.image = phiImageFixedBackgroundRemoved.image; % Start with most advanced image we have
	bw_flood_filling_mask_final.image = bw_flood_filling_mask_no_holes.image;
end

phiImageColorRangeFixed.title = ['phiImageColorRangeFixed' curr_index_string];

bw_flood_filling_mask_final.title = 'bw_flood_filling_mask_final';
bw_flood_filling_mask_final.colorMap = 'Gray';


% % PLOT:
% curr_figure_title = ['Processing Phase IV: Flood Filling Mask with Color Correction (Final): Source Image ', curr_index_string];
% [curr_fig, curr_figure_index] = phoCustomPlot(curr_figure_index, false, curr_figure_title);
% [~, h_plots, h] = plotHeatImageComparison(curr_fig, bw_flood_filling_mask_final);

% curr_fig_prefix = 'PhoFloodFillingMaskFinal-07-03-2020_Frame_';
% curr_output_name = [curr_fig_prefix, num2str(currFrameIndex), '.png']; % Add Extension
% curr_output_path = fullfile(pca_exportSettings.curr_fig_export_path, curr_output_name);
% if pca_exportSettings.should_export_image_to_disk
%     fprintf('Writing file out to %s... ', curr_output_path);
%     saveas(curr_fig, curr_output_path)         
%     fprintf('Final Flood Fill Image written to %s.\n', curr_output_path)
% end


% % Combined Plot (popup figure):
% curr_figure_title = ['Final Result: Flood Filling Masks: Source Image ', curr_index_string];
% [curr_fig, curr_figure_index] = phoCustomPlot(curr_figure_index, true, curr_figure_title);
% [~, h_plots, h] = plotHeatImageComparison(curr_fig, bw_flood_filling_mask, bw_flood_filling_mask_no_holes, bw_flood_filling_mask_final);
% bw_flood_filling_mask_no_holes


end

