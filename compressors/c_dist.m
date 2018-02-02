function [distances] = c_dist(ssvotgas)
distances(length(ssvotgas),length(ssvotgas(1).gas)) = struct;
for i = 1:length(ssvotgas)
    for j = 1:length(ssvotgas(i).gas)
        distances(i,j).mean = mean(ssvotgas(i).gas(j).distances);
        distances(i,j).min = min(ssvotgas(i).gas(j).distances);
        distances(i,j).max = mean(ssvotgas(i).gas(j).distances);
        distances(i,j).std = std(ssvotgas(i).gas(j).distances);
    end
end
end