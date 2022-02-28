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


for j = 0:1439
    for i = find((shortname.HrOfDay*60) + shortname.Time.Minute == j)
       temp = shortname.NumChangedPixels(i);
      clockdat(j+1)= median(temp(~isnan(shortname.NumChangedPixels(i)))); %Median can be changed to mean or sum
    end
end
figure;
subplot(1,2,1);
bar(clockdat');
title('Minutely Binned');

%normalizing (optional);
clockdat = round((clockdat / min(clockdat)) * 10);

histcounts = [];
for i = 1:length(clockdat)
    histcounts = [histcounts; i*ones(round(clockdat(i)),1)];
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
sumvector = VectorSum(hourbins,l.BinCounts);
overlayingarrow(1,angle(sumvector),abs(sumvector));

hold off;
title(['Bihourly Binned P = ',num2str(hourRayleighPval)])
thetaticks(0:15:345)
thetaticklabels({'00:00','01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'})

subplot(1,2,2);
polarhistogram((2*pi*(histcounts/1440)) - (pi/1440),1440);
RayleighPval = circ_rtest(2*pi*(histcounts/1440) - (pi/1440));
VecLength = circ_r(2*pi*(histcounts/1440) - (pi/1440));
VecDir = circ_mean(2*pi*(histcounts/1440) - (pi/1440));
hold on;
newsumvector = VectorSum(1440,clockdat');
overlayingarrow(1,angle(newsumvector),abs(newsumvector));
hold off;
title(['Minutely Binned P = ',num2str(RayleighPval)]);
thetaticks(0:15:345)
thetaticklabels({'00:00','01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'})
sgtitle('HR 24hour Plotted NumChangedPixels using Bin Median')
