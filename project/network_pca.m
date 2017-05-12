%% Generate list of features
clear;
clc;

egos = sort([0, 107, 1684, 1912, 3437, 348, 3980, 414, 686, 698]);
feature_index_dict = containers.Map;
index_feature_dict = containers.Map('KeyType', 'double', 'ValueType', 'any');
ego_feature_dict = containers.Map('KeyType', 'double', 'ValueType', 'any');
index = 1;

for ego=egos
   features = [];
   f = fopen(strcat('facebook/', string(ego), '.featnames'));
   this_line = fgetl(f);
   while ischar(this_line)
       feat = strsplit(this_line);
       % feat takes form [line_number, feat_name, 'feature', feature_number]
       feat = char(strcat(string(feat(2)), {' '}, string(feat(3)), {' '}, string(feat(4))));
       if ~isKey(feature_index_dict, feat)
           feature_index_dict(feat) = index;
           index_feature_dict(index) = feat;
           index = index + 1;
       end
       features = [features, feature_index_dict(feat)];
       this_line = fgetl(f);
   end
   ego_feature_dict(ego) = features;
   fclose(f);
end

%% Generate Feature Matrix
numNodes = 4039;
numFeatures = length(feature_index_dict);
featureMatrix = zeros(numNodes, numFeatures);

for ego = egos
    feature_indices = ego_feature_dict(ego);
    
    % gotta get the ego's features
    ego_feat = fopen(strcat('facebook/', string(ego), '.egofeat'));
    features = strread(fgetl(ego_feat));
    fclose(ego_feat);
    featureMatrix(ego + 1, feature_indices) = features;
    
    feat = fopen(strcat('facebook/', string(ego), '.feat'));
    this_line = fgetl(feat);
    while ischar(this_line)
        features = strread(this_line);
        neighbor_index = features(1) + 1;
        neighbor_features = features(2:end);
        featureMatrix(neighbor_index, feature_indices) = neighbor_features;
        this_line = fgetl(feat);
    end
    fclose(feat);
end

%% PCA
[coeff,score,latent] = pca(featureMatrix);

% the fact that the variances in latent are pretty different indicates to
% me that there is a way to separate the data. if it were random data, the
% variances would be equal. some components are definitely stronger than
% others

%% PCA Analysis
N = 10;
component = coeff(:, 1);
[sortedX,sortingIndices] = sort(abs(component),'descend');

maxValueIndices = sortingIndices(1:N);
maxValueWeights = component(maxValueIndices);

keyFeatures = [];
fprintf('TOP %d FEATURES\n', N);
for index = maxValueIndices'
    disp(index_feature_dict(index));
end

transformedFeatures = featureMatrix*coeff(:, 1:2);
groups = transformedFeatures(:, 2) > transformedFeatures(:, 1)*2/3;
group1 = find(groups)';
group2 = setdiff(1:numNodes, group1);

hold on;

plot(transformedFeatures(group1, 1), transformedFeatures(group1, 2), '.', 'Color', 'blue')
plot(transformedFeatures(group2, 1), transformedFeatures(group2, 2), '.', 'Color', 'red');

hold off;

%% Plot connections

f = fopen('facebook_combined.txt');
edge = fgetl(f);

numEdges = 0;
numGroupEdges = 0;
numBetweenEdges = 0;
while ischar(edge)
    connected = strread(edge);
    node1 = transformedFeatures(connected(1) + 1, :);
    node2 = transformedFeatures(connected(2) + 1, :);
    node1group = ismember(connected(1) + 1, group1);
    node2group = ismember(connected(2) + 1, group1);
    
    numEdges  = numEdges + 1;
    if node1group == node2group
        numGroupEdges = numGroupEdges + 1;
    else
        numBetweenEdges = numBetweenEdges + 1;
    end
    
    edge = fgetl(f);
end
fclose(f);

fprintf('percentage of inter-group edges: %d\n', numGroupEdges/numEdges);
