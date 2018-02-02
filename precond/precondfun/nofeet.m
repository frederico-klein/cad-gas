function tdskel = nofeet(tdskel, skelldef)
bod = skelldef.bodyparts;
sizeofnans = size(tdskel([bod.RIGHT_FOOT, bod.LEFT_FOOT],:));
tdskel([bod.RIGHT_FOOT, bod.LEFT_FOOT],:) = NaN(sizeofnans);
end