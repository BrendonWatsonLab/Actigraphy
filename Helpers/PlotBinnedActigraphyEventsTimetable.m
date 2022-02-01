function [fig, axH] = PlotBinnedActigraphyEventsTimetable(binnedEventsTimetable, video_frames_per_bin, currBBIDString, binSizeString, aggregateFnString, figureExportRoot, aggregateGroupings, curr_activity_timetable)
%PLOTBINNEDACTIGRAPHYEVENTSTIMETABLE Summary of this function goes here

aggregatePlotEnable.NumChangedPixels.mean = false;
aggregatePlotEnable.NumChangedPixels.sum = false;
aggregatePlotEnable.TotalSumChangedPixelValues.mean = false;
aggregatePlotEnable.TotalSumChangedPixelValues.sum = false;

if strcmp(aggregateFnString,'sum')
    aggregatePlotEnable.NumChangedPixels.sum = true;
    aggregatePlotEnable.TotalSumChangedPixelValues.sum = true;
end
if strcmp(aggregateFnString,'mean')
    aggregatePlotEnable.NumChangedPixels.mean = true;
    aggregatePlotEnable.TotalSumChangedPixelValues.mean = true;
end

variablePlotEnable.video_frames_per_bin = true;
variablePlotEnable.NumChangedPixels = true;
variablePlotEnable.TotalSumChangedPixelValues = true;

% if ~exist('shouldShowPlots','var')
% 	shouldShowPlots = true;
% end

maxVideoFramesPerBinCount = max(video_frames_per_bin,[],'all');
maxNumChangedPixelsCount = max(binnedEventsTimetable.NumChangedPixels,[],'all');
maxTotalSumChangedPixelValuesCount = max(binnedEventsTimetable.TotalSumChangedPixelValues,[],'all');
globalMaxCount = max(maxNumChangedPixelsCount, maxTotalSumChangedPixelValuesCount);
graphProperties.yAxisMaxCount = globalMaxCount * 1.2;
dateTimes = binnedEventsTimetable.Time;

graphProperties.binnedSting = ['Binned ' binSizeString, ' using ', aggregateFnString];
% graphProperties.preBinnedStringSeparator = ', ';
% graphProperties.preBinnedStringSeparator = '\n';
graphProperties.figureExportPath = figureExportRoot;


if variablePlotEnable.video_frames_per_bin
	curr_figure_variable_name = 'Video Frames Per Bin';
	%fig = figure(1);
    figure;
	clf
	axH(1) = subplot(1,1,1);
	phoBar(dateTimes, video_frames_per_bin);
	[curr_figure_export_name] = phoSetTitle(currBBIDString, curr_figure_variable_name, graphProperties);
	% title([currBBIDString, ': ', curr_figure_variable_name, graphProperties.preBinnedStringSeparator, graphProperties.binnedSting])
	% curr_figure_export_name = strrep([currBBIDString '_', curr_figure_variable_name, '_', graphProperties.binnedSting], ' ', '');
	xlabel('Datetime')
	ylabel(curr_figure_variable_name)
% 	xlim([dateTimes(1), dateTimes(end)])
	xlim([curr_activity_timetable.Time(1), curr_activity_timetable.Time(end)])
	ylim([0, (maxVideoFramesPerBinCount * 1.2)]);
	saveas(gcf,fullfile(graphProperties.figureExportPath, [curr_figure_export_name '.png']));
	% dynamicDateTicks(axH, 'link', 'mm/dd')
	% sgtitle(title)
end

if variablePlotEnable.NumChangedPixels
	curr_figure_variable_name = 'NumChangedPixels';
	%fig = figure(2);
	figure;
    clf
	axH(1) = subplot(1,1,1);
	phoBar(dateTimes, binnedEventsTimetable.NumChangedPixels);
	[curr_figure_export_name] = phoSetTitle(currBBIDString, curr_figure_variable_name, graphProperties);
	xlabel('Datetime')
	ylabel(curr_figure_variable_name)
 	xlim([curr_activity_timetable.Time(1), curr_activity_timetable.Time(end)])
%	xlim([datetime(2020,02,14,'TimeZone','local'), datetime(2020,03,15,'TimeZone','local')])
	ylim([0, (maxNumChangedPixelsCount * 1.2)]);
	saveas(gcf, fullfile(graphProperties.figureExportPath, [curr_figure_export_name '.png']));
end
% dynamicDateTicks(axH, 'link', 'mm/dd')
% sgtitle(title)

if variablePlotEnable.TotalSumChangedPixelValues
	curr_figure_variable_name = 'TotalSumChangedPixelValues';
	%fig = figure(3);
	figure;
    clf
	axH(1) = subplot(1,1,1);
	phoBar(dateTimes, binnedEventsTimetable.TotalSumChangedPixelValues);
	[curr_figure_export_name] = phoSetTitle(currBBIDString, curr_figure_variable_name, graphProperties);
	xlabel('Datetime')
	ylabel(curr_figure_variable_name)
 	xlim([curr_activity_timetable.Time(1), curr_activity_timetable.Time(end)])
%	xlim([datetime(2020,02,14,'TimeZone','local'), datetime(2020,03,15,'TimeZone','local')])
	ylim([0, (maxTotalSumChangedPixelValuesCount * 1.2)]);
	saveas(gcf, fullfile(graphProperties.figureExportPath, [curr_figure_export_name '.png']));
	% dynamicDateTicks(axH, 'link', 'mm/dd')
	% sgtitle(title)
end

if exist('aggregateGroupings','var')
		% Aggregate events:

		if aggregatePlotEnable.NumChangedPixels.mean
			curr_figure_variable_name = 'NumChangedPixels byHrOfDay';
			%fig = figure(4);
			fig = figure;
            clf
			axH(1) = subplot(1,1,1);
			phoBar(aggregateGroupings.hourly_mean_byHrOfDay{:,{'mean_NumChangedPixels'}}); %David's edits chaned nanmean to mean
			[curr_figure_export_name] = phoSetTitle(currBBIDString, curr_figure_variable_name, graphProperties);
			xlabel('Hour of Day')
			ylabel(curr_figure_variable_name)
			xlim([1, 24])
			saveas(gcf, fullfile(graphProperties.figureExportPath, [curr_figure_export_name '.png']));
		end

		if aggregatePlotEnable.NumChangedPixels.sum
			curr_figure_variable_name = 'sum NumChangedPixels byHrOfDay';
			%fig = figure(4);
			fig = figure;
            clf
			axH(1) = subplot(1,1,1);
			phoBar(aggregateGroupings.hourly_sum_byHrOfDay{:,{'sum_NumChangedPixels'}}); %David's edits again			
            [curr_figure_export_name] = phoSetTitle(currBBIDString, curr_figure_variable_name, graphProperties);
			xlabel('Hour of Day')
			ylabel(curr_figure_variable_name)
			xlim([1, 24])
			saveas(gcf, fullfile(graphProperties.figureExportPath, [curr_figure_export_name '.png']));
		end

		%% TotalSumChangedPixelValues
		if aggregatePlotEnable.TotalSumChangedPixelValues.mean
			curr_figure_variable_name = 'TotalSumChangedPixelValues byHrOfDay';
			%fig = figure(5);
			fig = figure;
            clf
			axH(1) = subplot(1,1,1);
			phoBar(aggregateGroupings.hourly_mean_byHrOfDay{:,{'mean_TotalSumChangedPixelValues'}});			[curr_figure_export_name] = phoSetTitle(currBBIDString, curr_figure_variable_name, graphProperties);
			xlabel('Hour of Day')
			ylabel(curr_figure_variable_name)
			xlim([1, 24])
			saveas(gcf, fullfile(graphProperties.figureExportPath, [curr_figure_export_name '.png']));
		end

		if aggregatePlotEnable.TotalSumChangedPixelValues.sum
			curr_figure_variable_name = 'sum TotalSumChangedPixelValues byHrOfDay';
			%fig = figure(5);
			fig = figure;
            clf
			axH(1) = subplot(1,1,1);
			phoBar(aggregateGroupings.hourly_sum_byHrOfDay{:,{'sum_TotalSumChangedPixelValues'}});			
			[curr_figure_export_name] = phoSetTitle(currBBIDString, curr_figure_variable_name, graphProperties);
			xlabel('Hour of Day')
			ylabel(curr_figure_variable_name)
			xlim([1, 24])
			saveas(gcf, fullfile(graphProperties.figureExportPath, [curr_figure_export_name '.png']));
		end
end

function result = phoBar(varargin)
	result = bar(varargin{:}, 'EdgeColor','none','BarWidth',1);
	box off
% 	set(gcf, 'PaperUnits', 'inches');
% 	set(gcf, 'PaperSize', [4 2]);
% 	set(gcf, 'PaperPositionMode', 'manual');
% 	set(gcf, 'PaperPosition', [0 0 4 2]);
end

function [curr_figure_export_name] = phoSetTitle(currBBIDString, curr_figure_variable_name, graphProperties)
	titleLine1 = [currBBIDString, ': ', curr_figure_variable_name];
	titleLine2 = [graphProperties.binnedSting];
	titleComplete = {titleLine1, titleLine2};
	title(titleComplete)
	curr_figure_export_name = [currBBIDString '_', strrep(curr_figure_variable_name, ' ', ''), '_', graphProperties.binnedSting];
end


end

