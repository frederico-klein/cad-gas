clear all;
%close all;
env = aa_environment;
onlineclassdata = loadfileload('onlineclass',env);

classfdata = loadfileload('realclassifier',env);
%realclass = classfdata.realclass;
%realvideo(classfdata.realclass.outstruct, classfdata.realclass.allconn, classfdata.realclass.simvar,0)
%tic
onlineclassdata.allskel3 = generate_skel_online(onlineclassdata.chunk.chunk);
%classfdata.realclass.simvar.paramsZ.PLOTIT = 0;

labellabel = online_classifier(classfdata.realclass.outstruct,onlineclassdata.allskel3, classfdata.realclass.allconn, classfdata.realclass.simvar);
%toc