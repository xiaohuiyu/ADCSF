clc;
addpath(genpath(strcat(pwd,'/LIB')))
addpath(genpath(strcat(pwd,'/DATA')))
%addpath(genpath('where is mexopencv-master'))

load('LVparms.mat');
load('LVcrash0Mdl.mat')

k = 2;

File = LVparms{k,1}; % test file
gFile = LVparms{k,2}; % ground truth file

eval(['!avconv -i ',which(File),' -vcodec rawvideo -y -loglevel quiet -pix_fmt yuv420p p',File,'.avi']);
eval(['!avconv -i ',which(gFile),' -vcodec rawvideo -y -loglevel quiet -pix_fmt yuv420p p',gFile,'.avi']);

t0 = LVparms{k,3}; % train/test frames

MISC.dockStyle;

visualise = true;

% Generate active cells and FG extractor
fgbg = VIDEO.getfgbgmask(['p',File,'.avi'],1e-2,300,visualise);
[ext,OFbag,FBbag,map] = PERS.genscan(4,0.02,visualise);

%{
% Feature extraction and model generation
n = 0;
[OFbag,FBbag,~] = HEAD.extract4VID(['p',File,'.avi'],OFbag,FBbag,ext,n,fgbg,1e-3,visualise,1,t0);

Mdl = HEAD.genMdlstr(OFbag,FBbag,map);
%}

th = struct;
th.th_of = 6.5;
th.th_fg = 90;

[GTD,CAD,IAD] = HEAD.AnomalyDetection(['p',File,'.avi'],['p',gFile,'.avi'],Mdl,ext,th,true,fgbg,1e-3,t0,Inf);
[TPR,FPR] = ANOMALY.CorrectDetectionRate(GTD,CAD,IAD,0.2);

