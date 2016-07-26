 % Put in dummy dataset identification (not required in this example)
 % The script will run in a loop over runlist{j} via for j=1:length(runlist)
 runlist={'SMSXXXX'};
 j=1;
 
  clear input_txt
    input_txt = ls('*Run1*.txt');
    %system(['dos2unix -n ' input_txt ' unix_read.txt']);
    %fid = fopen('unix_read.txt');
    system(['dos2mac ' input_txt]);
    fid = fopen([input_txt(:,1:end-1), '.mac']);
    log_file=textscan(fid,'%s');
    log_file=log_file{1,1};
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
            log_knutson(k+1,8)=log_file(i+13);   % Fix1.OnsetTime = 8
            log_knutson(k+1,9)=log_file(i+15);   % Cue.OnsetTime = 9
            log_knutson(k+1,15)=log_file(i+17);   % Dly.OnsetTime = 15
            log_knutson(k+1,16)=log_file(i+22);   % Tgt.OnsetTime = 16       
            log_knutson(k+1,10)=log_file(i+24);   % Tgt.RT = 10
            k=k+1;
            else
            end
            
            if strcmp(log_file(i),'Dly.RT:')==1;
                log_knutson(k,13)=log_file(i+1);   % Dly.RT = 13;
            else
            end
            
            if strcmp(log_file(i),'Dly2.RT:')==1;
                log_knutson(k,14)=log_file(i+1);   % Dly2.RT = 14;
                log_knutson(k,17)=log_file(i-1);   % Dly2.OnsetTime = 17
                if strcmp(log_file(i+6),'Fbk.OnsetTime:')==1;
                   log_knutson(k,18)=log_file(i+7);   % Fbk.OnsetTime = 18
                else
                log_knutson(k,18)=log_file(i+6);   % Fbk.OnsetTime = 18 
                end
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
    log_knutson_sum(j+1,52)={log_file(1+find(not(cellfun('isempty', idx))))}; % RTOpt.RESP: = LEVEL 
    clear idx
    idx=strfind(log_file,'StartMRI'); 
    log_knutson((length(log_knutson)),20)=log_file(1+find(not(cellfun('isempty',idx))));
    clear idx
    
    % Write header for summary of all datasets (line 1 in log_knutson_sum)
    log_knutson_sum(1,1:23) = {'ID' 'ConN_R1' 'TotN_R1' 'TotRT_R1' 'CorRT_R1' 'CorSD_R1' 'CorSE_R1' 'Percnt_R1' 'StatsOnsetTime_R1' 'File_R1' 'Date_R1' 'Time_R1' ... 
        'ConN_R2' 'TotN_R2' 'TotRT_R2' 'CorRT_R2' 'CorSD_R2' 'CorSE_R2' 'Percnt_R2' 'StatsOnsetTime_R2' 'File_R2' 'Date_R2' 'Time_R2'};
    log_knutson((length(log_knutson)),1:18) = {'RunList' 'Level' 'TgtDur' 'Total' 'Index' 'Delay' 'Delay2' 'Fix1.OnsetTime' 'Cue.OnsetTime' 'TgtRT' 'Shape' 'Risk' 'Dly.RT' 'Dly2.RT' 'Dly.Onset' 'Tgt.Onset' 'Dly2.Onset' 'Fbk.Onset'};
    overview_r1.(runlist{j})=log_knutson;
