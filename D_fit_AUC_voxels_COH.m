%% 3. Fit to model VP on a voxel by voxel basis

function xdata = D_fit_AUC_voxels_COH(directory1, CPU, CHECK, r2filter, timestamp)
%% 1. Load files from C_fit_AIFnoCP.m

% r2filter = 0; % Filter out all fits with r2 < r2filter
% CPU      = 0; % Use only if you are doing multicore
CPU

% Load the data files

rootname  = 'mooAUC'
% [gogo,PathName1,FilterIndex] = uigetfile(['/data/studies/' '/*AIF_with_vpFIT_ROI.mat'],'Choose R1 file');
%
% % Load the data files
% directory = PathName1
% rootname  = strrep(gogo, '.nii', '');
% load(fullfile(PathName1, gogo));
%directory1 = strrep(directory1, 'AIF_with_vpFIT_ROI.mat', '_fitted_R1info.mat');
load(directory1)
timer = xdata{1}.timer;
inject = xdata{1}.inject;

ind1    = find(timer >= inject);
ind2    = find(timer<=timestamp);
ind1  = ind1(1);
ind2 = ind2(end);

% 
Ct = xdata{1}.Ct;
Cp = xdata{1}.Cp;

wholeCt = mean(Ct, 2);
WHOLEAUC = trapz(timer(ind1:ind2), wholeCt(ind1:ind2)); 

for i = 1:size(Ct,2)
    CurCt = Ct(:,i);
    bad = 1;
  
    %[CurCt bad] = smoothcurve(Ct(:,i), xdata, 1);
    if(bad ~= -1)
        AUC(i) = trapz(timer(ind1:ind2), CurCt(ind1:ind2));
    else
        AUC(i) = -1;
    end
end
   
badind = find(AUC<0);
AUC(badind) = [];
tumind(badind) = [];

AUCCp = trapz(timer(ind1:ind2), Cp(ind1:ind2));




%Normalize AUC
NAUC = AUC./AUCCp;

%Normalize Whole AUC

NWHOLEAUC = WHOLEAUC./AUCCp;
%% f) Make maps

AUCROI    = zeros(size(currentimg));


AUCROI(tumind) = NAUC;

xdata{1}.AUC = AUC;
xdata{1}.NAUC= NAUC;
xdata{1}.AUCCp=AUCCp;
xdata{1}.tumind = tumind;
xdata{1}.NWHOLEAUC = NWHOLEAUC;


res = [0 0.25 0.25 2];

%% Calculate Fractals
% Take central slice

A = AUCROI(:,:,2);
[i j] = find(A~=0);
BLOCKA = zeros((max(i)-min(i)+1), max(j)-min(j)+1);
BLOCKA(1:end, 1:end) = A(min(i):max(i), min(j):max(j));

imagesc(A)
fract = FractalDim(BLOCKA,10);
close gcf

xdata{1}.fract = fract;

%% h) Save image files

[discard actual] = fileparts(strrep(dynamname.fileprefix, '\', '/'));

save_nii(make_nii(AUCROI, res(2:4), [1 1 1]), fullfile(fileparts(directory1), [actual '_NAUC_min' num2str(timestamp) '.nii']));

a = 1;





