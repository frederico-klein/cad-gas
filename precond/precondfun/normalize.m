function tdskel = normalize(tdskel, skelldef)
if skelldef.novel
    upperlim = skelldef.hh;
else
    upperlim = skelldef.hh/2;
end

for i = 1:upperlim
    tdskel(i,:) = (tdskel(i,:) - skelldef.pos_mean)/skelldef.pos_std; %- skelldef.pos_mean
end

if ~skelldef.novel
    for i = (skelldef.hh/2+1):skelldef.hh
        tdskel(i,:) = (tdskel(i,:) - skelldef.vel_mean)/skelldef.vel_std;%- skelldef.vel_mean
    end
end
end