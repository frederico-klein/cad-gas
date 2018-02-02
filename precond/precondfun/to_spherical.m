function newskel = to_spherical(tdskel, ~)
newskel = zeros(size(tdskel));
[newskel(:,1),newskel(:,2),newskel(:,3)] = cart2sph(tdskel(:,1),tdskel(:,2),tdskel(:,3));
end