function nonmatrixkilldim_proposals = nmc(func, nmco, skelldef)
[exampleskel1, skelldef.hh] = makefatskel((skelldef.length:-1:1)'*1.8756327 +1.9072136);
[exampleskel2, skelldef.hh] = makefatskel((1:skelldef.length)'*0.3385476 +2.547346);
[exampleskel3, skelldef.hh] = makefatskel(ones(90,1)*2.432328 +4.545346);
a = func(exampleskel1, skelldef);
b = func(exampleskel2, skelldef);
c = func(exampleskel3, skelldef);
nonmatrixkilldim_proposals = unique([setdiff(1:skelldef.length, unique([find(a); find(b); find(c)])) nmco]);
end