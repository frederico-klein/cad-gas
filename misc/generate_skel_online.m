function skel = generate_skel_online(chunk)
for i = 1:length(chunk)
    chunk15 = translate_from(chunk(i).chunk);
    skel(i).skel = chunk15(:,:,1:end);
    first_is_zero = zeros(size(chunk15(:,:,1)));
    skel(i).vel = cat(3,first_is_zero, diff(chunk15,1,3));
    skel(i).act_type = chunk.label;
end