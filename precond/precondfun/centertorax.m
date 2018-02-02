function newskel = centertorax(tdskel, skelldef)
bod = skelldef.bodyparts;
if skelldef.novel
    torax = repmat(tdskel(bod.TORSO,:),skelldef.hh,1);
else
    torax = [repmat(tdskel(bod.TORSO,:),skelldef.hh/2,1);zeros(skelldef.hh/2,3)];
end
newskel = tdskel - torax;
end