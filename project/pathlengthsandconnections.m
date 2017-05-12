wd='/Users/christiancardozo/Documents/MIT/4_Year Four/Spring 2017/6.207/Project/Datasets/workdir';
fb_source='/Users/christiancardozo/Documents/MIT/4_Year Four/Spring 2017/6.207/Project/Datasets/workdir/facebook_combined.txt';
tw_source='/Users/christiancardozo/Documents/MIT/4_Year Four/Spring 2017/6.207/Project/Datasets/workdir/61890555.txt'

cd(wd)


fb_line = fopen(fb_source,'r');

% Producing Facebook data adjacency matrix
n_fb=4038+1;
A_fb=zeros(n_fb,n_fb);
tline = fgets(fb_line);
while ischar(tline)
    row=str2num(tline);
    i=1+row(1);
    j=1+row(2);
    A_fb(i,j)=1;
    A_fb(j,i)=1;
    tline = fgets(fb_line);
end
fclose(fb_line);

r=2005;
G=graph(A_fb);
adj=adjacency(G);
FB=graph(adj);

plot(FB,'MarkerSize', 6)    % Plot full Facebook dataset
plot(FB,'Layout','subspace','Dimension',3,'MarkerSize', 6)  % Plot subset of Facebook dataset

SP=distances(FB);   % Shortest path matrix
diameter=max(max(SP));  % Find diameter of Facebook
apl=mean(mean(SP));     % Find average path length of Facebook

kdcd=zeros(1,diameter);  % k-degree-connection distribution is initialized and filled
for i=1:n_fb
    for j=1:n_fb
        if j>i
            for c=1:diameter
                if SP(i,j)==c
                    kdcd(1,c)=kdcd(1,c)+1;
                end
            end
        end
    end
end

KDCD=kdcd/sum(kdcd);    % k-degree-connection distrubution is normalized and plotted
bar(KDCD)
title('K-Degree-Connection Distribution','FontSize', 16);
xlabel('K','FontSize', 16);
ylabel('Frequency','FontSize', 16);

% 
% % Producing Twitter data adjacency matrix
% tw_line = fopen(tw_source,'r');
% %n_tw=4038+1;
% A_tw=zeros(1,1);
% tline = fgets(tw_line);
% while ischar(tline)
%     row=round(str2num(tline)/2e6);
%     from=1+row(1);
%     to=1+row(2);
%     %A_tw=[A_tw;row];
%     if from>0 & to>0
%         A_tw(to,from)=1;
%     end
%     %A_f(j,i)=1;
%     tline = fgets(tw_line);
% end
% fclose(tw_line);
% 
% 
% 
% 
% 
% 
% 
% 
% 





