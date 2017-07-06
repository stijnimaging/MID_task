%% Create runlist = amount of SMS numbers 
clc
list={};
[PathName] = uigetdir(pwd,'Select directory');
cd (PathName);
d = dir('sms*'); str = {d.name}; 
% Make a selection all datasets or pick what's needed.
[s] = listdlg('PromptString','Select datasets to process MID:','ListString',str);
if length(s)==length(d); % All datasets selected
    runlist={d.name};
    disp('Selected all datasets');
else                     % Make selection based on s
    for i=1:length(s);
        runlist{i,1}=str{1,(s(i))};
        disp(['Selected ' str{1,(s(i))}]);
    end
end
clear str d s v i list
 
 
%% Convert .txt to .txt.mac (or unix_read.txt) and pick values
% edit to read files on unix
for j=1:length(runlist);
    if exist(runlist{j},'dir') == 7;
    cd(runlist{j});
    day_select=[runlist{j} '_T0_D1/'];
    cd(day_select);
    cd Knutson
    % ***************RUN 1 ********************
    % Convert DOS to UNIX via dos2unix command
    clear input_txt
    input_txt{1}=[ls('*Run1*.txt')];
    input_txt{1}=input_txt{1}(1:end-1);
    input_txt{2}= 'OUTPUT.TXT';
    input_txt=strjoin(input_txt);
    command_syst=['dos2unix -n -q ', input_txt];
    system(command_syst);
    fid = fopen('OUTPUT.TXT');
    log_file=fopen(fid);
    log_file=textscan(fid,'%s'); log_file=log_file{1,1};
 
    k=0;
    log_knutson={};
   
    % Run through log_file (length = 5132)
   for i=130:(length(log_file)-15); % Skip header (1-130)
            if strcmp(log_file(i),'Total:')==1;
                if strcmp(log_file(i+2),'Current:')==1;
                    a=strrep((log_file(i+1)),'.',','); 
                    a=strrep((a),'$','');
                    b=a{1,1};
                    log_knutson(k+1,4)={b(1,2:end-1)};% Dollar setting
                    
                if strcmp(log_file{i+1}(1,1),'-')==1;                
                    log_knutson(k+1,4)={strcat('-',(b(1,3:end-1)))};
                else
                end
               
                else
                a=strrep((log_file(i+2)),'.',','); % Total: = 4
                b=a{1,1};
                log_knutson(k+1,4)={(b(1,1:end-1))};
                if length(log_file{i+1})==3;
                log_knutson(k+1,4)={strcat('-',(b(1,1:end-1)))};
                else
                end
                end
            else
            end
            
            if strcmp(log_file(i),'Shape:')==1;
                log_knutson(k+1,11)=log_file(i+1);    % Shape (sqr, cir, tri) = 11
                log_knutson(k+1,12)=log_file(i+3);    % Risk (p, n, e) = 12
            else
            end
            
            if strcmp(log_file(i),'TgtDur:')==1;
            log_knutson(k+1,3)=log_file(i+1);       % TgtDur = 3
            log_knutson(k+1,1)=log_file(i+5);       % RunList.Sample = 1
            log_knutson(k+1,5)={i};                 % Index = 5
            log_knutson(k+1,6)=log_file(i+7);       % Delay = 6
            log_knutson(k+1,7)=log_file(i+11);      % Delay2 = 7
            log_knutson(k+1,8)=log_file(i+13);      % Fix1.OnsetTime = 8
            log_knutson(k+1,9)=log_file(i+15);      % Cue.OnsetTime = 9
            log_knutson(k+1,10)=log_file(i+24);     % Tgt.RT = 10
            k=k+1;
            else
            end
            
            if strcmp(log_file(i),'CorN:')==1;
            log_knutson_sum(j+1,2)=log_file(i+1);        % ConN: = 1
            log_knutson_sum(j+1,3)=log_file(i+3);        % TotN: = 3
            log_knutson_sum(j+1,4)=log_file(i+5);        % TotRT: = 5
            log_knutson_sum(j+1,5)=log_file(i+7);        % CorRT: = 7
            log_knutson_sum(j+1,6)=log_file(i+9);        % CorSD: = 9
            log_knutson_sum(j+1,7)=log_file(i+11);       % CorSE: = 11
            log_knutson_sum(j+1,8)=log_file(i+13);       % Percnt: = 13
            log_knutson_sum(j+1,9)=log_file(i+15);       % Stats.OnsetTime: = 15
            log_knutson_sum(j+1,10)={str2mat(input_txt(1:end-11))};   % Write filename
            else
            end
   end
    
   
    log_knutson_sum(j+1,1)= {[upper(runlist{j}(1:3)) runlist{j}(4:7)]};
    idx=strfind(log_file(3000:end,:),'SessionDate');
    log_knutson_sum(j+1,11)=log_file(3000+find(not(cellfun('isempty', idx)))); % Session Date 11
    log_knutson_sum(j+1,12)=log_file(3002+find(not(cellfun('isempty', idx)))); % Session Start Time 12 
    clear idx input_txt
    idx=strfind(log_file,'RTOpt.RESP:');
    log_knutson_sum(j+1,52)=mat2cell(log_file(1+find(not(cellfun('isempty', idx))))); % RTOpt.RESP: = LEVEL 
    clear idx
    
    % Write header for summary of all datasets (line 1 in log_knutson_sum)
    log_knutson_sum(1,1:23) = {'ID' 'ConN_R1' 'TotN_R1' 'TotRT_R1' 'CorRT_R1' 'CorSD_R1' 'CorSE_R1' 'Percnt_R1' 'StatsOnsetTime_R1' 'File_R1' 'Date_R1' 'Time_R1' ... 
        'ConN_R2' 'TotN_R2' 'TotRT_R2' 'CorRT_R2' 'CorSD_R2' 'CorSE_R2' 'Percnt_R2' 'StatsOnsetTime_R2' 'File_R2' 'Date_R2' 'Time_R2'};
    log_knutson((length(log_knutson)),1:12) = {'RunList' 'Level' 'TgtDur' 'Total' 'Index' 'Delay' 'Delay2' 'Fix1.OnsetTime' 'Cue.OnsetTime' 'TgtRT' 'Shape' 'Risk'};
    overview_r1.(runlist{j})=log_knutson;
% *************** END RUN 1 ********************
 
 
% ***************RUN 2 ********************
        % Convert DOS to UNIX via dos2unix command
        clear input_txt
        input_txt{1}=[ls('*Run2*.txt')];
        input_txt{1}=input_txt{1}(1:end-1);
        input_txt{2}= 'OUTPUT2.TXT';
        input_txt=strjoin(input_txt);
        command_syst=['dos2unix -n -q ', input_txt];
        system(command_syst);
        fid = fopen('OUTPUT2.TXT');
        log_file=fopen(fid);
        log_file=textscan(fid,'%s'); log_file=log_file{1,1};
                
        k=0;
        log_knutson={};
 
        
        % Run through log_file (length = 5132)
        for i=130:(length(log_file)-15); % Skip header (1-121)
            if strcmp(log_file(i),'ExptList.Sample:')==1;
                log_knutson(k,2)=log_file(i+1); % ExptList: = 2
            else
            end
            
            if strcmp(log_file(i),'Total:')==1;
                if strcmp(log_file(i+2),'Current:')==1;
                    a=strrep((log_file(i+1)),'.',','); 
                    a=strrep((a),'$','');
                    b=a{1,1};
                    log_knutson(k+1,4)={b(1,2:end-1)};% Dollar setting
                    
                if strcmp(log_file{i+1}(1,1),'-')==1;                
                    log_knutson(k+1,4)={strcat('-',(b(1,3:end-1)))};
                else
                end
                
                else
                a=strrep((log_file(i+2)),'.',','); % Total: = 4
                b=a{1,1};
                log_knutson(k+1,4)={(b(1,1:end-1))};
                if length(log_file{i+1})==3;
                log_knutson(k+1,4)={strcat('-',(b(1,1:end-1)))};
                else
                end
                end
            else
            end
            
            if strcmp(log_file(i),'Shape:')==1;
                log_knutson(k+1,11)=log_file(i+1);    % Shape (sqr, cir, tri) = 11
                log_knutson(k+1,12)=log_file(i+3);    % Risk (p, n, e) = 12
            else
            end
            
            if strcmp(log_file(i),'TgtDur:')==1;
            log_knutson(k+1,3)=log_file(i+1);   % TgtDur = 3
            log_knutson(k+1,1)=log_file(i+5);   % RunList.Sample = 1
            log_knutson(k+1,5)={i};             % Index = 5
            log_knutson(k+1,6)=log_file(i+7);   % Delay = 6
            log_knutson(k+1,7)=log_file(i+11);   % Delay2 = 7
            log_knutson(k+1,8)=log_file(i+13);   % Fix1.OnsetTime = 8
            log_knutson(k+1,9)=log_file(i+15);   % Cue.OnsetTime = 9
            log_knutson(k+1,10)=log_file(i+24);   % Tgt.RT = 10
            k=k+1;
            else
            end
            
            if strcmp(log_file(i),'CorN:')==1;
            log_knutson_sum(j+1,13)=log_file(i+1);        % ConN: = 1
            log_knutson_sum(j+1,14)=log_file(i+3);        % TotN: = 3
            log_knutson_sum(j+1,15)=log_file(i+5);        % TotRT: = 5
            log_knutson_sum(j+1,16)=log_file(i+7);        % CorRT: = 7
            log_knutson_sum(j+1,17)=log_file(i+9);        % CorSD: = 9
            log_knutson_sum(j+1,18)=log_file(i+11);        % CorSE: = 11
            log_knutson_sum(j+1,19)=log_file(i+13);        % Percnt: = 13
            log_knutson_sum(j+1,20)=log_file(i+15);        % Stats.OnsetTime: = 15
            log_knutson_sum(j+1,21)={str2mat(input_txt(1:end-11))};     % Write filename
            else
            end
            
        end
        
        idx=strfind(log_file(3000:end,:),'SessionDate');
        log_knutson_sum(j+1,22)=log_file(3000+find(not(cellfun('isempty', idx)))); % Session Date 22
        log_knutson_sum(j+1,23)=log_file(3002+find(not(cellfun('isempty', idx)))); % Session Start Time 23 
        clear idx
        idx=strfind(log_file,'RTOpt.RESP:');
        log_knutson_sum(j+1,53)=mat2cell(log_file(1+find(not(cellfun('isempty', idx))))); % RTOpt.RESP: = LEVEL 
        clear idx input_txt
      
        
        header_row=(length(log_knutson)-1);
        log_knutson((length(log_knutson)),1:12) = {'RunList' 'Level' 'TgtDur' 'Total' 'Index' 'Delay' 'Delay2' 'Fix1.OnsetTime' 'Cue.OnsetTime' 'TgtRT' 'Shape' 'Risk'};
        overview_r2.(runlist{j})=log_knutson;
        cd ../../../
        
        else
        disp (runlist{j});
    end
    disp(runlist{j});
end
clear a b day_select fid header_row input_txt i j k idx command_syst
 
%% Get overview per condition
clc
snames=fieldnames(overview_r1);
for i=1:length(snames);
    % RUN 1    
        for k=1:length(overview_r1.(snames{i}))-1;
            
            if strcmp(overview_r1.(snames{i})(k,11),'cir1.bmp')==1;      % cir1.bmp = 1
                overview_num_r1.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r1.(snames{i})(k,2)=1;    % write CIR1.BPM = 1
                overview_num_r1.(snames{i})(k,3)=str2double(overview_r1.(snames{i})(k,10));    % write RT 
            else
            end
           
            if strcmp(overview_r1.(snames{i})(k,11),'cir2.bmp')==1;      % cir2.bmp = 2
                overview_num_r1.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r1.(snames{i})(k,2)=2;    % write CIR2.BPM = 2
                overview_num_r1.(snames{i})(k,3)=str2double(overview_r1.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r1.(snames{i})(k,11),'cir3.bmp')==1;      % cir3.bmp = 3
                overview_num_r1.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r1.(snames{i})(k,2)=3;    % write CIR2.BPM = 3
                overview_num_r1.(snames{i})(k,3)=str2double(overview_r1.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r1.(snames{i})(k,11),'sqr1.bmp')==1;      % sqr1.bmp = 4
                overview_num_r1.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r1.(snames{i})(k,2)=4;    % write SQR1.BMP = 4
                overview_num_r1.(snames{i})(k,3)=str2double(overview_r1.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r1.(snames{i})(k,11),'sqr2.bmp')==1;      % sqr2.bmp = 5
                overview_num_r1.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r1.(snames{i})(k,2)=5;    % write SQR2.BMP = 5
                overview_num_r1.(snames{i})(k,3)=str2double(overview_r1.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r1.(snames{i})(k,11),'sqr3.bmp')==1;      % sqr3.bmp = 6
                overview_num_r1.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r1.(snames{i})(k,2)=6;    % write SQR3.BMP = 6
                overview_num_r1.(snames{i})(k,3)=str2double(overview_r1.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r1.(snames{i})(k,11),'tri.bmp')==1;      % tri.bmp = 7
                overview_num_r1.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r1.(snames{i})(k,2)=7;    % write SQR1.BMP = 4
                overview_num_r1.(snames{i})(k,3)=str2double(overview_r1.(snames{i})(k,10));    % write RT 
            else
            end
        end
        
        overview_num_r1.(snames{i})=sortrows(overview_num_r1.(snames{i}),2); % Sort on second column
        rt_cir1=overview_num_r1.(snames{i})(1:9,3);         % select cir1
        non_cir1=sum(rt_cir1==0);                           % count zeros
        rt_cir1=round(sum(sum(rt_cir1))./sum(sum(rt_cir1 ~= 0)));  % nonzero mean RT
        
        rt_cir2=overview_num_r1.(snames{i})(10:18,3);       % select cir2
        non_cir2=sum(rt_cir2==0);                           % count zeros
        rt_cir2=round(sum(sum(rt_cir2))./sum(sum(rt_cir2 ~= 0)));  % nonzero mean RT        
        
        rt_cir3=overview_num_r1.(snames{i})(19:27,3);       % select cir3
        non_cir3=sum(rt_cir3==0);                           % count zeros
        rt_cir3=round(sum(sum(rt_cir3))./sum(sum(rt_cir3 ~= 0)));  % nonzero mean RT        
        
        rt_sqr1=overview_num_r1.(snames{i})(28:36,3);       % select sqr1
        non_sqr1=sum(rt_sqr1==0);                           % count zeros
        rt_sqr1=round(sum(sum(rt_sqr1))./sum(sum(rt_sqr1 ~= 0)));  % nonzero mean RT  
 
        rt_sqr2=overview_num_r1.(snames{i})(37:46,3);       % select sqr2
        non_sqr2=sum(rt_sqr2==0);                           % count zeros
        rt_sqr2=round(sum(sum(rt_sqr2))./sum(sum(rt_sqr2 ~= 0)));  % nonzero mean RT          
        
        rt_sqr3=overview_num_r1.(snames{i})(47:54,3);       % select sqr3
        non_sqr3=sum(rt_sqr3==0);                           % count zeros
        rt_sqr3=round(sum(sum(rt_sqr3))./sum(sum(rt_sqr3 ~= 0)));  % nonzero mean RT  
        
        rt_tri=overview_num_r1.(snames{i})(55:72,3);        % select tri
        non_tri=sum(rt_tri==0);                             % count zeros
        rt_tri=round(sum(sum(rt_tri))./sum(sum(rt_tri ~= 0)));     % nonzero mean RT  
        
        % Reaction times
        log_knutson_sum{i+1,24}=num2str(rt_cir1);
        log_knutson_sum{i+1,25}=num2str(rt_cir2);
        log_knutson_sum{i+1,26}=num2str(rt_cir3);
        log_knutson_sum{i+1,27}=num2str(rt_sqr1);
        log_knutson_sum{i+1,28}=num2str(rt_sqr2);
        log_knutson_sum{i+1,29}=num2str(rt_sqr3);
        log_knutson_sum{i+1,30}=num2str(rt_tri);
        
        % Non-responses
         log_knutson_sum{i+1,31}=num2str(non_cir1);
         log_knutson_sum{i+1,32}=num2str(non_cir2);
         log_knutson_sum{i+1,33}=num2str(non_cir3);
         log_knutson_sum{i+1,34}=num2str(non_sqr1);
         log_knutson_sum{i+1,35}=num2str(non_sqr2);
         log_knutson_sum{i+1,36}=num2str(non_sqr3);
         log_knutson_sum{i+1,37}=num2str(non_tri);
        
        % Get money gain total
        log_knutson_sum{i+1,54}=overview_r1.(snames{i})((length(overview_r1.(snames{i}))-1),4);
       
        clear rt_cir1 rt_cir2 rt_cir3 rt_sqr1 rt_sqr2 rt_sqr3 rt_tri non_cir1 non_cir2 non_cir3 non_sqr1 non_sqr2 non_sqr3 non_tri
        
    % RUN 2 %%%%%%%%%%%%%%%%%%%%%    
        for k=1:length(overview_r2.(snames{i}))-1;
            
            if strcmp(overview_r2.(snames{i})(k,11),'cir1.bmp')==1;      % cir1.bmp = 1
                overview_num_r2.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r2.(snames{i})(k,2)=1;    % write CIR1.BPM = 1
                overview_num_r2.(snames{i})(k,3)=str2double(overview_r2.(snames{i})(k,10));    % write RT 
            else
            end
           
            if strcmp(overview_r2.(snames{i})(k,11),'cir2.bmp')==1;      % cir2.bmp = 2
                overview_num_r2.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r2.(snames{i})(k,2)=2;    % write CIR2.BPM = 2
                overview_num_r2.(snames{i})(k,3)=str2double(overview_r2.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r2.(snames{i})(k,11),'cir3.bmp')==1;      % cir3.bmp = 3
                overview_num_r2.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r2.(snames{i})(k,2)=3;    % write CIR2.BPM = 3
                overview_num_r2.(snames{i})(k,3)=str2double(overview_r2.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r2.(snames{i})(k,11),'sqr1.bmp')==1;      % sqr1.bmp = 4
                overview_num_r2.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r2.(snames{i})(k,2)=4;    % write SQR1.BMP = 4
                overview_num_r2.(snames{i})(k,3)=str2double(overview_r2.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r2.(snames{i})(k,11),'sqr2.bmp')==1;      % sqr2.bmp = 5
                overview_num_r2.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r2.(snames{i})(k,2)=5;    % write SQR2.BMP = 5
                overview_num_r2.(snames{i})(k,3)=str2double(overview_r2.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r2.(snames{i})(k,11),'sqr3.bmp')==1;      % sqr3.bmp = 6
                overview_num_r2.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r2.(snames{i})(k,2)=6;    % write SQR3.BMP = 6
                overview_num_r2.(snames{i})(k,3)=str2double(overview_r2.(snames{i})(k,10));    % write RT 
            else
            end
            
            if strcmp(overview_r2.(snames{i})(k,11),'tri.bmp')==1;      % tri.bmp = 7
                overview_num_r2.(snames{i})(k,1)=k;    % write INDEX
                overview_num_r2.(snames{i})(k,2)=7;    % write TRI.BMP = 7
                overview_num_r2.(snames{i})(k,3)=str2double(overview_r2.(snames{i})(k,10));    % write RT 
            else
            end
        end
        
        overview_num_r2.(snames{i})=sortrows(overview_num_r2.(snames{i}),2); % Sort on second column
        rt_cir1=overview_num_r2.(snames{i})(1:9,3);         % select cir1
        non_cir1=sum(rt_cir1==0);                           % count zeros
        rt_cir1=round(sum(sum(rt_cir1))./sum(sum(rt_cir1 ~= 0)));  % nonzero mean RT
        
        rt_cir2=overview_num_r2.(snames{i})(10:18,3);       % select cir2
        non_cir2=sum(rt_cir2==0);                           % count zeros
        rt_cir2=round(sum(sum(rt_cir2))./sum(sum(rt_cir2 ~= 0)));  % nonzero mean RT        
        
        rt_cir3=overview_num_r2.(snames{i})(19:27,3);       % select cir3
        non_cir3=sum(rt_cir3==0);                           % count zeros
        rt_cir3=round(sum(sum(rt_cir3))./sum(sum(rt_cir3 ~= 0)));  % nonzero mean RT        
        
        rt_sqr1=overview_num_r2.(snames{i})(28:36,3);       % select sqr1
        non_sqr1=sum(rt_sqr1==0);                           % count zeros
        rt_sqr1=round(sum(sum(rt_sqr1))./sum(sum(rt_sqr1 ~= 0)));  % nonzero mean RT  
 
        rt_sqr2=overview_num_r2.(snames{i})(37:46,3);       % select sqr2
        non_sqr2=sum(rt_sqr2==0);                           % count zeros
        rt_sqr2=round(sum(sum(rt_sqr2))./sum(sum(rt_sqr2 ~= 0)));  % nonzero mean RT          
        
        rt_sqr3=overview_num_r2.(snames{i})(47:54,3);       % select sqr3
        non_sqr3=sum(rt_sqr3==0);                           % count zeros
        rt_sqr3=round(sum(sum(rt_sqr3))./sum(sum(rt_sqr3 ~= 0)));  % nonzero mean RT  
        
        rt_tri=overview_num_r2.(snames{i})(55:72,3);        % select tri
        non_tri=sum(rt_tri==0);                             % count zeros
        rt_tri=round(sum(sum(rt_tri))./sum(sum(rt_tri ~= 0)));     % nonzero mean RT  
        
        log_knutson_sum{i+1,38}=num2str(rt_cir1);
        log_knutson_sum{i+1,39}=num2str(rt_cir2);
        log_knutson_sum{i+1,40}=num2str(rt_cir3);
        log_knutson_sum{i+1,41}=num2str(rt_sqr1);
        log_knutson_sum{i+1,42}=num2str(rt_sqr2);
        log_knutson_sum{i+1,43}=num2str(rt_sqr3);
        log_knutson_sum{i+1,44}=num2str(rt_tri);
        
        log_knutson_sum{i+1,45}=num2str(non_cir1);
        log_knutson_sum{i+1,46}=num2str(non_cir2);
        log_knutson_sum{i+1,47}=num2str(non_cir3);
        log_knutson_sum{i+1,48}=num2str(non_sqr1);
        log_knutson_sum{i+1,49}=num2str(non_sqr2);
        log_knutson_sum{i+1,50}=num2str(non_sqr3);
        log_knutson_sum{i+1,51}=num2str(non_tri);
        
        log_knutson_sum{i+1,55}=overview_r2.(snames{i})((length(overview_r1.(snames{i}))-1),4);
        clear rt_cir1 rt_cir2 rt_cir3 rt_sqr1 rt_sqr2 rt_sqr3 rt_tri non_cir1 non_cir2 non_cir3 non_sqr1 non_sqr2 non_sqr3 non_tri
end
log_knutson_sum(1,24:37)={'rt_r1_cir1' 'rt_r1_cir2' 'rt_r1_cir3' 'rt_r1_sqr1' 'rt_r1_sqr2' 'rt_r1_sqr3' 'rt_r1_tri' 'non_r1_cir1' 'non_r1_cir2' 'non_r1_cir3' 'non_r1_sqr1' 'non_r1_sqr2' 'non_r1_sqr3' 'non_r1_tri'};
log_knutson_sum(1,38:51)={'rt_r2_cir1' 'rt_r2_cir2' 'rt_r2_cir3' 'rt_r2_sqr1' 'rt_r2_sqr2' 'rt_r2_sqr3' 'rt_r2_tri' 'non_r2_cir1' 'non_r2_cir2' 'non_r2_cir3' 'non_r2_sqr1' 'non_r2_sqr2' 'non_r2_sqr3' 'non_r2_tri'};
log_knutson_sum(1,52:55)={'Level_R1' 'Level_R2' 'Money_R1' 'Money_R2'};
clear k i 
 
%% Create CSV output
 
log_knutson_sum2=cell2dataset(log_knutson_sum,'ReadVarNames',false);
cell2csv(['../Overview_MID_' date '.csv'],log_knutson_sum2);
