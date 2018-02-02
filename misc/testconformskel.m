function testconformskel()
load('g:\savesave\testskel')
skeldraw(test)
for i = 1:length(simvar.preconditions)
[data_test, skelldef] = conformskel(test, simvar.preconditions{i});
figure
skeldraw(data_test)
end