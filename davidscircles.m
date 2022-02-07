%David's Circles :DDD
% Let's go

%REQUIREMENTS:
%This needs something to be loaded called
%curr_activity_timetable_hourly_binned_mean. This is created by running
%ActigraphyRun, but more specifically, it's created by the function
%ProduceActigraphyFinalOutputTable. You can also access this dataset by
%going into a GeneralOutputs folder and loading MergedBoxActigraphyData dot
%mat files. Good luck!

shortname = curr_activity_timetable_hourly_binned_mean;
clockdat = zeros(1440,1);

for j = 0:1439
    for i = find((shortname.HrOfDay*60) + shortname.Time.Minute == j)
      clockdat(j+1)= sum(shortname.NumChangedPixels(i));
    end
end
figure;
subplot(1,2,1);
bar(clockdat');

histcounts = [];
for i = 1:length(normclockdat)
    histcounts = [histcounts; i*ones(round(clockdat(i)),1)];
end
subplot(1,2,2);
histogram(histcounts);

figure;
subplot(1,2,1);
%PvalueOutput = circ_rtest(histcounts);
polarhistogram(2*pi*(histcounts/1440) - (pi/1440),24);
%title(['P = ' num2str(round(PvalueOutput,3))]);
subplot(1,2,2);
polarhistogram((2*pi*(histcounts/1440)) - (pi/1440),1440);