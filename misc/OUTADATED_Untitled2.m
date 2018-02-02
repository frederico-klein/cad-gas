clear all;
close all;
env = aa_environment;
classfdata = loadfileload('realclassifier',env); 
realclass = classfdata.realclass;
realvideo(gca, realclass.outstruct, realclass.allconn, realclass.simvar,0)
%realvideo(classfdata.outstruct, baq(classfdata.pallconn),
%classfdata.simvar,0);  