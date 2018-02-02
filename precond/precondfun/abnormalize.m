function newskel = abnormalize(tdskel, ~)
newskel = tdskel + rand(size(tdskel));
end