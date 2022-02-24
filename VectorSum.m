function [outs] = VectorSum(bins,data)
    
phases = (2*pi*(1:bins) / bins) - (pi/bins);

complexvals = (cos(phases()) .* data()) + sin(phases()) .* data() * 1i;

% for j = 1:length(complexvals)
%     overlayingarrow(1,angle(complexvals(j)),abs(complexvals(j)));
% end
outs = sum(complexvals) / bins;
end

