% Bin Distributions
% This is basically a script that will take in actigraphy data and plot out
% violin distributions of the bins. This is will be used to select to use
% mean or median binning when plotting circular data.
bin = 24;

shortname = curr_activity_timetable_hourly_binned_mean;
clockdat = zeros(bin,1);
temp = {};
 for j = 0:bin-1
        temp{j + 1} = shortname.NumChangedPixels(find(shortname.HrOfDay == j));
 end

violin(temp);
title('24 Hour Distributions binned Hourly')
xlabel('Hour of Day')
ylabel('NumChangedPixels')

% for i = 1:4
%     subtemp = {};
%     for k = (bin/4)*(i-1)+1:(bin/4)*(i)
%         subtemp{k - (bin/4)*(i-1)} = temp{k};
%     end
%     subplot(4,1,i);
%     violin(subtemp);
% end