%% Routine run
% Select NII output from dcm2nii in separate folders
% Make selection of datasets to process
% MCFLIRT refvolume 0 or middle
%
% Output: MCFLIRT .png .par files and overview in .mat/.csv format.
%
% NEEDED SAVEFIG.M
%
 
clc
list={};
[PathName] = uigetdir(pwd,'Select directory with NII files');
cd (PathName);
d = dir('SMS*'); str = {d.name}; 
 
% Make a selection all datasets or pick what's needed.
[s] = listdlg('PromptString','Select NII dataset(s) to process:','ListString',str);
if length(s)==length(d); % All datasets selected
    list={d.name};
    disp('Selected all datasets');
else                     % Make selection based on s
    for i=1:length(s);
        list{i,1}=str{1,(s(i))};
        disp(['Selected ' str{1,(s(i))}]);
    end
end
clear str d s v i
 
% Next specifiy the reference volume for MC FLIRT
% 1= First = vol0
% 2= Middle = nvols/2 = DEFAULT
reference_vol=listdlg('PromptString','Provide reference volume (default = 0):','SelectionMode','single','ListSize',[180 40],'ListString',{'First' 'Middle'});
if reference_vol==1 % Do -refvol 0 - to the first
    ref_vol_input='-refvol 0';
    ref_vol_name='first';
else % Do default nvols/2
    ref_vol_input='';
    ref_vol_name='middle';
end 
clear reference_vol
 
% Some dependencies
 
if exist('MC')==7;
else
    system('mkdir MC'); 
end
k=1;
m=1;
%% Loop over list
for i=1:length(list);
    tic
    
% PROCESS D1 DATA
    dir_list=dir([list{i} '/D1/20*']);
    if isempty(dir_list)==1;
        disp(['No D1 NII for ' list{i}]);
    else
    D1=textscan(ls([list{i} '/D1/20*ep2*']),'%s');D1=D1{1,1};
    for scan=1:length(D1);
        fsl_command=['fslinfo ' D1{scan}];
        [fsl_info]=evalc('system(fsl_command)');
        fsl_info=textscan(fsl_info,'%s');fsl_info=fsl_info{1,1};
        overview_nii{k+scan,1}=D1{scan};
        overview_nii{k+scan,2}=str2double(fsl_info(4));
        overview_nii{k+scan,3}=str2double(fsl_info(6));
        overview_nii{k+scan,4}=str2double(fsl_info(8));
        overview_nii{k+scan,5}=str2double(fsl_info(10));
        % Check motion using MC FLIRT
        mc_flirt=['mcflirt -in ' D1{scan} ' -plots -o temp_mc ' ref_vol_input];
        evalc('system(mc_flirt)');
        mc_info=textread('temp_mc.par','%s');
        for j=1:6:length(mc_info);
            motion_cor(m,1:6)=str2double(mc_info(j:j+5)');
            m=m+1;
        end
        m=1;
            if length(motion_cor(:,1)) > 1;
            % Create plot for visual inspection
            [x]=size(motion_cor);
            x=1:x;
            y1=motion_cor(:,4); % X trans
            y2=motion_cor(:,5); % Y trans
            y3=motion_cor(:,6); % Z trans
            y4=180/(pi)*motion_cor(:,1); % X rot
            y5=180/(pi)*motion_cor(:,2); % Y rot
            y6=180/(pi)*motion_cor(:,3); % Z rot
            hold on
            h1 = subplot(2,1,1); plot(x,y1,x,y2,x,y3); legend('X','Y','Z','Location','northeastoutside');
            axis([0 length(motion_cor) min(min(motion_cor(:,4:6))) max(max(motion_cor(:,4:6)))]);
            title([D1{scan}]); xlabel('Volume (#)'); ylabel('Translation (mm)');
            h2 = subplot(2,1,2); plot(x,y4,x,y5,x,y6); legend('X','Y','Z','Location','northeastoutside');
            axis([0 length(motion_cor) min(min([y4 y5 y6])) max(max([y4 y5 y6]))]);
            title([D1{scan}]); xlabel('Volume (#)'); ylabel('Rotation (degrees)');
            hold off
            savefig(['MC/MC_D1_' D1{scan}(1:11) '_NO_' num2str(scan) '_' num2str(length(motion_cor)) '_' ref_vol_name],'png','-lossless');
            clear x y1 y2 y3 y4 y5 y6 h1 h2
            copyfile('temp_mc.par',['MC/Raw_MC_D1_' D1{scan}(1:11) '_NO_' num2str(scan) '_' num2str(length(motion_cor)) '_' ref_vol_name '.par']);
            copyfile('temp_mc.nii.gz',['MC/MC_' D1{scan}(1:11) '_D1_NO_' num2str(scan) '_' num2str(length(motion_cor)) '_' ref_vol_name '.nii.gz']);
            else
                disp(['No MC for ' D1{scan}]);
            end
        clf
        
        % Put it together in an overview variable
        overview_nii{k+scan,6}=180/(pi)*max(motion_cor(:,1));    % Max column 1
        overview_nii{k+scan,7}=180/(pi)*max(motion_cor(:,2));    % Max column 2
        overview_nii{k+scan,8}=180/(pi)*max(motion_cor(:,3));    % Max column 3
        overview_nii{k+scan,9}=max(motion_cor(:,4));             % Max column 4
        overview_nii{k+scan,10}=max(motion_cor(:,5));            % Max column 5
        overview_nii{k+scan,11}=max(motion_cor(:,6));            % Max column 6
        overview_nii{k+scan,12}=180/(pi)*min(motion_cor(:,1));   % Min column 1
        overview_nii{k+scan,13}=180/(pi)*min(motion_cor(:,2));   % Min column 2
        overview_nii{k+scan,14}=180/(pi)*min(motion_cor(:,3));   % Min column 3
        overview_nii{k+scan,15}=min(motion_cor(:,4));            % Min column 4
        overview_nii{k+scan,16}=min(motion_cor(:,5));            % Min column 5
        overview_nii{k+scan,17}=min(motion_cor(:,6));            % Min column 6
        motion_cor=[];
        mc_info=[]; 
    end
    end
    
% PROCESS D2 DATA
    dir_list=dir([list{i} '/D2/20*']);
    if isempty(dir_list)==1;
        disp(['No D2 NII for ' list{i}]);
    else
    D2=textscan(ls([list{i} '/D2/20*']),'%s');D2=D2{1,1};
    for scan2=1:length(D2);
        fsl_command=['fslinfo ' D2{scan2}];
        [fsl_info]=evalc('system(fsl_command)');
        fsl_info=textscan(fsl_info,'%s');fsl_info=fsl_info{1,1};
        overview_nii{k+scan+scan2,1}=D2{scan2};
        overview_nii{k+scan+scan2,2}=str2double(fsl_info(4));
        overview_nii{k+scan+scan2,3}=str2double(fsl_info(6));
        overview_nii{k+scan+scan2,4}=str2double(fsl_info(8));
        overview_nii{k+scan+scan2,5}=str2double(fsl_info(10));
        % Check motion using MC FLIRT
        mc_flirt=['mcflirt -in ' D2{scan2} ' -plots -o temp_mc ' ref_vol_input];
        evalc('system(mc_flirt)');
        mc_info=textread('temp_mc.par','%s');
        for j=1:6:length(mc_info);
            motion_cor(m,1:6)=str2double(mc_info(j:j+5)');
            m=m+1;
        end
        m=1;
            if length(motion_cor(:,1)) > 1;
            % Create plot for visual inspection
            [x]=size(motion_cor);
            x=1:x;
            y1=motion_cor(:,4); % X trans
            y2=motion_cor(:,5); % Y trans
            y3=motion_cor(:,6); % Z trans
            y4=180/(pi)*motion_cor(:,1); % X rot
            y5=180/(pi)*motion_cor(:,2); % Y rot
            y6=180/(pi)*motion_cor(:,3); % Z rot
            hold on
            h1 = subplot(2,1,1); plot(x,y1,x,y2,x,y3); legend('X','Y','Z','Location','northeastoutside');
            axis([0 length(motion_cor) min(min(motion_cor(:,4:6))) max(max(motion_cor(:,4:6)))]);
            title([D2{scan2}]); xlabel('Volume (#)'); ylabel('Translation (mm)');
            h2 = subplot(2,1,2); plot(x,y4,x,y5,x,y6); legend('X','Y','Z','Location','northeastoutside');
            axis([0 length(motion_cor) min(min([y4 y5 y6])) max(max([y4 y5 y6]))]);
            title([D2{scan2}]); xlabel('Volume (#)'); ylabel('Rotation (degrees)');
            hold off
            savefig(['MC/MC_D2_' D2{scan2}(1:11) '_NO_' num2str(scan2) '_' num2str(length(motion_cor)) '_' ref_vol_name],'png','-lossless');
            clear x y1 y2 y3 y4 y5 y6 h1 h2
            copyfile('temp_mc.par',['MC/Raw_MC_D2_' D2{scan2}(1:11) '_NO_' num2str(scan2) '_' num2str(length(motion_cor)) '_' ref_vol_name '.par']);
            copyfile('temp_mc.nii.gz',['MC/MC_' D2{scan2}(1:11) '_D2_NO_' num2str(scan) '_' num2str(length(motion_cor)) '_' ref_vol_name '.nii.gz']);
            else
                disp(['No MC for ' D2{scan2}]);
            end
        clf
        
        % Put it together in an overview variable
        overview_nii{k+scan+scan2,6}=180/(pi)*max(motion_cor(:,1));    % Max column 1
        overview_nii{k+scan+scan2,7}=180/(pi)*max(motion_cor(:,2));    % Max column 2
        overview_nii{k+scan+scan2,8}=180/(pi)*max(motion_cor(:,3));    % Max column 3
        overview_nii{k+scan+scan2,9}=max(motion_cor(:,4));             % Max column 4
        overview_nii{k+scan+scan2,10}=max(motion_cor(:,5));            % Max column 5
        overview_nii{k+scan+scan2,11}=max(motion_cor(:,6));            % Max column 6
        overview_nii{k+scan+scan2,12}=180/(pi)*min(motion_cor(:,1));   % Min column 1
        overview_nii{k+scan+scan2,13}=180/(pi)*min(motion_cor(:,2));   % Min column 2
        overview_nii{k+scan+scan2,14}=180/(pi)*min(motion_cor(:,3));   % Min column 3
        overview_nii{k+scan+scan2,15}=min(motion_cor(:,4));            % Min column 4
        overview_nii{k+scan+scan2,16}=min(motion_cor(:,5));            % Min column 5
        overview_nii{k+scan+scan2,17}=min(motion_cor(:,6));            % Min column 6
        motion_cor=[];
        mc_info=[];
    end
    end
    
% PROCESS D3 DATA
dir_list=dir([list{i} '/D3/20*']);
    if isempty(dir_list)==1;
        disp(['No D3 NII for ' list{i}]);
    else    
    D3=textscan(ls([list{i} '/D3/20*']),'%s');D3=D3{1,1};
    for scan3=1:length(D3);
        fsl_command=['fslinfo ' D3{scan3}];
        [fsl_info]=evalc('system(fsl_command)');
        fsl_info=textscan(fsl_info,'%s');fsl_info=fsl_info{1,1};
        overview_nii{k+scan+scan2+scan3,1}=D3{scan3};
        overview_nii{k+scan+scan2+scan3,2}=str2double(fsl_info(4));
        overview_nii{k+scan+scan2+scan3,3}=str2double(fsl_info(6));
        overview_nii{k+scan+scan2+scan3,4}=str2double(fsl_info(8));
        overview_nii{k+scan+scan2+scan3,5}=str2double(fsl_info(10));
        % Check motion using MC FLIRT
        mc_flirt=['mcflirt -in ' D3{scan3} ' -plots -o temp_mc ' ref_vol_input];
        evalc('system(mc_flirt)');
        mc_info=textread('temp_mc.par','%s');
        for j=1:6:length(mc_info);
            motion_cor(m,1:6)=str2double(mc_info(j:j+5)');
            m=m+1;
        end
        m=1;
            if length(motion_cor(:,1)) > 1;
            % Create plot for visual inspection
            [x]=size(motion_cor);
            x=1:x;
            y1=motion_cor(:,4); % X trans
            y2=motion_cor(:,5); % Y trans
            y3=motion_cor(:,6); % Z trans
            y4=180/(pi)*motion_cor(:,1); % X rot
            y5=180/(pi)*motion_cor(:,2); % Y rot
            y6=180/(pi)*motion_cor(:,3); % Z rot
            hold on
            h1 = subplot(2,1,1); plot(x,y1,x,y2,x,y3); legend('X','Y','Z','Location','northeastoutside');
            axis([0 length(motion_cor) min(min(motion_cor(:,4:6))) max(max(motion_cor(:,4:6)))]);
            title([D3{scan3}]); xlabel('Volume (#)'); ylabel('Translation (mm)');
            h2 = subplot(2,1,2); plot(x,y4,x,y5,x,y6); legend('X','Y','Z','Location','northeastoutside');
            axis([0 length(motion_cor) min(min([y4 y5 y6])) max(max([y4 y5 y6]))]);
            title([D3{scan3}]); xlabel('Volume (#)'); ylabel('Rotation (degrees)');
            hold off
            savefig(['MC/MC_D3_' D3{scan3}(1:11) '_NO_' num2str(scan3) '_' num2str(length(motion_cor)) '_' ref_vol_name],'png','-lossless');
            clear x y1 y2 y3 y4 y5 y6 h1 h2
            copyfile('temp_mc.par',['MC/Raw_MC_D3_' D3{scan3}(1:11) '_NO_' num2str(scan3) '_' num2str(length(motion_cor)) '_' ref_vol_name '.par']);
            copyfile('temp_mc.nii.gz',['MC/MC_' D3{scan3}(1:11) '_D3_NO_' num2str(scan) '_' num2str(length(motion_cor)) '_' ref_vol_name '.nii.gz']);
            else
                disp(['No MC for ' D3{scan3}]);
            end
        clf
        
        overview_nii{k+scan+scan2+scan3,6}=180/(pi)*max(motion_cor(:,1));    % Max column 1
        overview_nii{k+scan+scan2+scan3,7}=180/(pi)*max(motion_cor(:,2));    % Max column 2
        overview_nii{k+scan+scan2+scan3,8}=180/(pi)*max(motion_cor(:,3));    % Max column 3
        overview_nii{k+scan+scan2+scan3,9}=max(motion_cor(:,4));             % Max column 4
        overview_nii{k+scan+scan2+scan3,10}=max(motion_cor(:,5));            % Max column 5
        overview_nii{k+scan+scan2+scan3,11}=max(motion_cor(:,6));            % Max column 6
        overview_nii{k+scan+scan2+scan3,12}=180/(pi)*min(motion_cor(:,1));   % Min column 1
        overview_nii{k+scan+scan2+scan3,13}=180/(pi)*min(motion_cor(:,2));   % Min column 2
        overview_nii{k+scan+scan2+scan3,14}=180/(pi)*min(motion_cor(:,3));   % Min column 3
        overview_nii{k+scan+scan2+scan3,15}=min(motion_cor(:,4));            % Min column 4
        overview_nii{k+scan+scan2+scan3,16}=min(motion_cor(:,5));            % Min column 5
        overview_nii{k+scan+scan2+scan3,17}=min(motion_cor(:,6));            % Min column 6
        motion_cor=[];
        mc_info=[];
    end
    end
    k=length(overview_nii);
    disp(['MC for ' list{i} ' done in ' seconds2human(toc)]);
end
overview_nii(1,1:17)={'Serie_name' 'x_dim' 'y_dim' 'z_dim' 'volumes' 'max_rot_x' 'max_rot_y' 'max_rot_z' 'max_trans_x' 'max_trans_y' 'max_trans_z' 'min_rot_x' 'min_rot_y' 'min_rot_z' 'min_trans_x' 'min_trans_y' 'min_trans_z'};
 
if exist(['MC/MCFLIRT_' date])==7;
    save(['MC/MCFLIRT_' date], 'overview_nii', '-append'); % Add date
    save(['MC/MCFLIRT_ALL'], 'overview_nii', '-append');
else
    save(['MC/MCFLIRT_' date], 'overview_nii');
    save(['MC/MCFLIRT_ALL_' ref_vol_name], 'overview_nii', '-append');
end
 
cell2csv(['MC/MCFLIRT_' ref_vol_name '_' date '.csv'], overview_nii);
clear scan scan2 scan3 k m i j D1 D2 D3 fsl_command fsl_info mc_info motion_cor mc_flirt ref_vol_input ref_vol_name
