
fb_source = 'C:\Users\Agni Kumar\Documents\MIT 2016-17\Classes\6.207 Project\facebook_combined.txt'; 
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

% plot(FB,'MarkerSize', 6);    % Plot full Facebook dataset
% plot(FB,'Layout','subspace','Dimension',3,'MarkerSize', 6);  % Plot subset of Facebook dataset

% plotNodeDegreeDistrib(adj);
% plotNodeDegreeDistrib(adj, 'bins', 50)
plotNodeDegreeDistrib(adj, 'Bins', 100, 'plotType', 'normal')

function plotNodeDegreeDistrib(graph, varargin)
if nargin <= 5
    ip = inputParser;
    %Defaults
    bins = 50;
    plotType = 'normal';
    %Function handle to make sure the matrix is symmetric
    issymmetric = @(x) all(all(x == x.'));

    addRequired(ip, 'graph', @(x) isnumeric(x) && issymmetric(x));
    addParameter(ip, 'bins', bins, @(x) isnumeric(x) && isscalar(x));
    addParameter(ip, 'plotType', plotType, @(x) strcmp(x, 'loglog') || strcmp(x, 'normal'));
    parse(ip, graph, varargin{:});
    %Validated parameter values
    graph = ip.Results.graph;
    bins = ip.Results.bins;
    plotType = ip.Results.plotType;
else
    fprintf('Maximum number of paremeters exceeded. ');
    fprintf('This function only accepts the following parameters:\n');
    fprintf('\tgraph (required)\n');
    fprintf('\tbins (optional, default = 50)\n');
    fprintf('\tplotType (optional, default = ''loglog'')\n');
    return;
end

% Node degree distribution plotting
% Making sure that the graph unweighted!
graph(graph > 0) = 1; 
deg = sum(graph, 2); %Determine node degrees
[counts, x] = hist(deg, bins); %Compute the density of degree intervals

%Plot the node-degree distribution
if strcmp(plotType, 'loglog')
    loglog(x, counts./sum(counts), '.');
    xlabel('k');
    ylabel('P(k)');
elseif strcmp(plotType, 'normal')
    scatter(x, counts./sum(counts), 40,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5);
    title('Degree Distribution');
    xlabel('k');
    ylabel('P(k)');
end
end