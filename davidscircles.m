%David's Circles :DDD
% Let's go

%REQUIREMENTS:
%This needs something to be loaded called
%curr_activity_timetable_hourly_binned_mean. This is created by running
%ActigraphyRun, but more specifically, it's created by the function
%ProduceActigraphyFinalOutputTable. You can also access this dataset by
%going into a GeneralOutputs folder and loading MergedBoxActigraphyData dot
%mat files. Good luck!

%Libraries: This also relies on the circular statistics library. It can be
%found online at: https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox-directional-statistics

shortname = curr_activity_timetable_hourly_binned_mean;
clockdat = zeros(1440,1);
hourbins = 12;
minuteradlimit = 4500;
hourradlimit = 150000;

shortname.HrOfDay = shortname.HrOfDay + 5;
shortname.HrOfDay(find(shortname.HrOfDay > 23)) = shortname.HrOfDay(find(shortname.HrOfDay > 23)) - 24;

for j = 0:1439
    for i = find((shortname.HrOfDay*60) + shortname.Time.Minute == j)
<<<<<<< Updated upstream
       temp = shortname.NumChangedPixels(i);
      clockdat(j+1)= median(temp(~isnan(shortname.NumChangedPixels(i)))); %Median can be changed to mean or sum
=======
		filtered = i(~isnan(shortname.NumChangedPixels(i)));
		clockdat(j+1)= sum(shortname.NumChangedPixels(filtered));
>>>>>>> Stashed changes
    end
end
figure;
subplot(1,2,1);
bar(clockdat');
title('Minutely Binned');




%Okay, so there's this thing where you can either choose to normalize or
%scale down... I'm doing to scale down and then scale up at the end...
%normalizing (optional);
scales = 100;
%clockdat = round((clockdat / min(clockdat)) * 10);
clockdat = round((clockdat / scales));




normclockdat = 10 * clockdat / min(clockdat);

histcounts = [];
<<<<<<< Updated upstream
for i = 1:length(clockdat)
    histcounts = [histcounts; i*ones(round(clockdat(i)),1)];
=======
for i = 1:length(normclockdat)
    histcounts = [histcounts; i*ones(round(normclockdat(i)),1)];
>>>>>>> Stashed changes
end
subplot(1,2,2);
histogram(histcounts,24);
title('Hourly Binned');


figure;
subplot(1,2,1);
l = polarhistogram(2*pi*(histcounts/1440) - (pi/1440),hourbins);
%Toying
hourhistcounts = [];
for i = 1:hourbins
    hourhistcounts = [hourhistcounts; i*ones(round(l.BinCounts(i)),1)];
end
hourRayleighPval = circ_rtest(2*pi*(hourhistcounts/hourbins) - (pi/hourbins));
hourVecLength = circ_r(2*pi*(hourhistcounts/hourbins) - (pi/hourbins));
hourVecDir = circ_mean(2*pi*(hourhistcounts/hourbins) - (pi/hourbins));
hold on;
l.BinCounts = l.BinCounts * scales; % Rescaling up
sumvector = VectorSum(hourbins,l.BinCounts);
overlayingarrow(1,angle(sumvector),abs(sumvector));

hold off;
title(['Bihourly Binned P = ',num2str(hourRayleighPval)])

rlim([0 hourradlimit]);

thetaticks(0:15:345)
thetaticklabels({'00:00','01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'})

subplot(1,2,2);
v = polarhistogram((2*pi*(histcounts/1440)) - (pi/1440),1440);
RayleighPval = circ_rtest(2*pi*(histcounts/1440) - (pi/1440));
VecLength = circ_r(2*pi*(histcounts/1440) - (pi/1440));
VecDir = circ_mean(2*pi*(histcounts/1440) - (pi/1440));
hold on;
v.BinCounts = v.BinCounts * scales;
newsumvector = VectorSum(1440,clockdat');
overlayingarrow(1,angle(newsumvector),abs(newsumvector) * scales);
hold off;
title(['Minutely Binned P = ',num2str(RayleighPval)]);

rlim([0 minuteradlimit]);

thetaticks(0:15:345)
thetaticklabels({'00:00','01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'})
sgtitle('LR 24hour Plotted NumChangedPixels using Bin Median')
