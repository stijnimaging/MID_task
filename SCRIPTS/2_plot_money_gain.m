%% Plot lines money gain RUN 1
% Note that this scripts build on the previous one.
clc
snames=fieldnames(overview_r1);
cmap = hsv(length(snames));
h=figure;
for i=1:length(snames);
        x=str2double(overview_r1.(runlist{i})(1:72,1)); % Runlist
        y=overview_r1.(runlist{i})(1:72,4);
        y=strrep(y, ',' , '.'); % Solve issue with , instead of .
        for j=1:length(y);
            if strcmp(y{j}(1),'-')==1; % negative value
               y1{j}=y{j}(2:end);
               y1{j}=['-' y1{j}];
            else
             y1{j}=y{j}(1:end);
            end
        end
        y=str2double(y1); % Money 
        disp([runlist{i} ' started with: ' num2str(y(1)) ' and won ' num2str(y(72))])
        y=(y)';
        x=x(1:end-1,:);
        x=[0;x];
      % y=smooth(y,15);
        hold on
        plot(x,y,'Color',cmap(i,:));
        text(73,y(length(y),1),(runlist{i}),'FontSize',6,'Color',cmap(i,:));
end
ylabel('Money (euro)');
xlabel('Trial (#)');

% text(40.5,7,'Block 1');
% text(100.5,7,'Block 2');
% text(160.5,7,'Block 3');
% text(220.5,7,'Block 4');
axis([1 72 -25 40]);
set(gca,'XTick',[1 8 16 24 32 40 48 56 64 72]);

saveas(h,['../MID_R1_gain_' date '.png'],'png');
hold off;
close figure 1
clear x y cmap h i
