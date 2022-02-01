% Just Some Plotting Scripts
% The purpose of this script is specifically to compare the LR and HR in
% our initial experiment. Outside of this, this script is not generalizable
% at all.

LRtime = diff([BB18_curr_activity_timetable_hourly_binned_sum.Time(1) BB18_curr_activity_timetable_hourly_binned_sum.Time(end)]);
HRtime = diff([BB17_curr_activity_timetable_hourly_binned_sum.Time(1) BB17_curr_activity_timetable_hourly_binned_sum.Time(end)]);

dur = minutes(max([LRtime HRtime]));

figure(1);
plot(1:max(size(BB18_curr_activity_timetable_hourly_binned_sum.Time)),BB18_curr_activity_timetable_hourly_binned_sum.NumChangedPixels)
hold on;
plot(1:max(size(BB17_curr_activity_timetable_hourly_binned_sum.Time)),BB17_curr_activity_timetable_hourly_binned_sum.NumChangedPixels)
title('BB18 vs BB17 NumChangedPixels by Sum (Binned minutely)');
legend({'BB18','BB17'},'Location','southwest')

figure(2);
plot(1:max(size(BB18_curr_activity_timetable_hourly_binned_sum.Time)),BB18_curr_activity_timetable_hourly_binned_sum.TotalSumChangedPixelValues)
hold on;
plot(1:max(size(BB17_curr_activity_timetable_hourly_binned_sum.Time)),BB17_curr_activity_timetable_hourly_binned_sum.TotalSumChangedPixelValues)
title('BB18 vs BB17 TotalSumChangedPixelValues by Sum (Binned minutely)');
legend({'BB18','BB17'},'Location','southwest')

figure(3);
plot(1:max(size(BB18_curr_activity_timetable_hourly_binned_mean.Time)),BB18_curr_activity_timetable_hourly_binned_mean.NumChangedPixels)
hold on;
plot(1:max(size(BB17_curr_activity_timetable_hourly_binned_mean.Time)),BB17_curr_activity_timetable_hourly_binned_mean.NumChangedPixels)
title('BB18 vs BB17 NumChangedPixels by Mean (Binned minutely)');
legend({'BB18','BB17'},'Location','southwest')

figure(4);
plot(1:max(size(BB18_curr_activity_timetable_hourly_binned_mean.Time)),BB18_curr_activity_timetable_hourly_binned_mean.TotalSumChangedPixelValues)
hold on;
plot(1:max(size(BB17_curr_activity_timetable_hourly_binned_mean.Time)),BB17_curr_activity_timetable_hourly_binned_mean.TotalSumChangedPixelValues)
title('BB18 vs BB17 TotalSumChangedPixelValues by Mean (Binned minutely)');
legend({'BB18','BB17'},'Location','southwest')

