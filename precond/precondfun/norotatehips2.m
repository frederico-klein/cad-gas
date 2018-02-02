function tdskel = norotatehips2(tdskel, skelldef)
a = detectrotation(tdskel, skelldef, 'hips');
tdskel = rotskel(tdskel,0,a,0);
end