function [ CMmax, CMright, statsMax, statsRight ] = fuzzyAA( ref, class, w )
% Convert linguistic labels (1-5 scale) for set of sample points to two
% confusion matrices (based on Gopal & Woodcock 1994, PE&RS):
%   1) matrix based on best label
%   2) matrix based on any acceptable label (score >=3)

% Calculates accuracy assessment stats (OA, PA, UA) and standard errors
% based on Olofsson et al. 2014, RSE

% Inputs:
%   1) Array with reference labels for each class (for a total of p
%   classes) at each point (for a total of n points) - n x p array
%   2) Column vector (of length n) with class labels assigned to each
%   point, with class labels ranging from 1-p
%   3) Row vector (of length p) with proportions of total study area mapped
%   as each class

% Note: rows of (1) and (2) must correspond to the same point

q = size(ref, 2); % number of classes
n = size(ref, 1); % number of points

%% Error matrix and stats for MAX case
CMmax = NaN(q, q);
maxPoints = NaN(n, 1);
ni = NaN(1, q); % number of sample points for each class
for i = 1:n
    if sum(~isnan(ref(i, :)))>0; maxPoints(i) = find(ref(i, :) == max(ref(i, :))); end
end
for i = 1:q
    
    temp = [maxPoints(class==i) class(class==i)];
    temp = temp(all(~isnan(temp), 2), :);
    ni(i) = size(temp, 1);
    
    for j = 1:q
        
        CMmax(i, j) = w(i) * sum(temp(:,1)==j) / ni(i);
        
    end
    
end

statsMax.OA = sum(diag(CMmax));
statsMax.UA = NaN(1, q);
statsMax.PA = NaN(1, q);
statsMax.fc = NaN(1, q);
statsMax.OA_se = NaN;
statsMax.UA_se = NaN(1, q);
statsMax.PA_se = NaN(1, q);
statsMax.fc_se = NaN(1, q);
statsMax.n = ni; % sample points in each class
statsMax.w = w; % proportion mapped to each class

for i=1:q
        
    statsMax.UA(i) = CMmax(i, i) / sum(CMmax(i, :));
        
end
for j=1:q
        
    statsMax.PA(j) = CMmax(j, j) / sum(CMmax(:, j));
        
end
for j=1:q
        
    statsMax.fc(j) = sum(CMmax(:, j));
        
end

% Estimate standard error of overall accuracy (Eq. 5 in Olofsson et al. 2014)
temp = NaN(1, q);
for i = 1:q
    temp(i) = w(i)^2 * statsMax.UA(i) * (1 - statsMax.UA(i)) / (ni(i)-1);
end
statsMax.OA_se = sqrt(sum(temp)); clear temp;

% Estimate standard error of user's accuracy (Eq. 6 in Olofsson et al. 2014)
statsMax.UA_se = sqrt(statsMax.UA .* (1-statsMax.UA) ./ (ni - 1));

% Yikes... not sure what to make of SE estimates for PA (Eq. 7)

% Estimate standard error of proportional area for each class (Eq. 10)
for k = 1:q
    temp = NaN(1, q);
    
    for i = 1:q
        temp(i) = (w(i) * CMmax(i, k) - CMmax(i, k)^2) / (ni(i) - 1);
    end
    
    statsMax.fc_se(k) = sqrt(sum(temp)); clear temp;
end


%% Error matrix and stats for RIGHT case
CMright = NaN(q, q);
% rightPoints = NaN(n, 1);
ni = NaN(1, q); % number of sample points for each class
% for i = 1:n
%     if sum(~isnan(ref(i, :)))>0; rightPoints(i) = find(ref(i, :) == max(ref(i, :))); end
% end
for i = 1:q
    
    temp1 = ref(class==i, i); % score for class i
    temp2 = class(class==i);
    best = maxPoints(class==i);
    idx = ~isnan(temp1) & ~isnan(temp2) & ~isnan(best);
    temp1 = temp1(idx);
    best = best(idx);
    %temp2 = temp2(idx);
    
    ni(i) = size(temp1, 1);
    temp = NaN(ni(i), 1);
    temp(temp1 >= 3) = i;
    temp(temp1 < 3) = best(temp1 < 3);
    clear idx best temp1 temp2;
    
    for j = 1:q
        
        CMright(i, j) = w(i) * sum(temp(:,1)==j) / ni(i);
        
    end
    
end

statsRight.OA = sum(diag(CMright));
statsRight.UA = NaN(1, q);
statsRight.PA = NaN(1, q);
statsRight.fc = NaN(1, q);
statsRight.OA_se = NaN;
statsRight.UA_se = NaN(1, q);
statsRight.PA_se = NaN(1, q);
statsRight.fc_se = NaN(1, q);
statsRight.n = ni; % sample points in each class
statsRight.w = w; % proportion mapped to each class

for i=1:q
        
    statsRight.UA(i) = CMright(i, i) / sum(CMright(i, :));
        
end
for j=1:q
        
    statsRight.PA(j) = CMright(j, j) / sum(CMright(:, j));
        
end
for j=1:q
        
    statsRight.fc(j) = sum(CMright(:, j));
        
end


% Estimate standard error of overall accuracy (Eq. 5 in Olofsson et al. 2014)
temp = NaN(1, q);
for i = 1:q
    temp(i) = w(i)^2 * statsRight.UA(i) * (1 - statsRight.UA(i)) / (ni(i)-1);
end
statsRight.OA_se = sqrt(sum(temp)); clear temp;

% Estimate standard error of user's accuracy (Eq. 6 in Olofsson et al. 2014)
statsRight.UA_se = sqrt(statsRight.UA .* (1-statsRight.UA) ./ (ni - 1));

% Yikes... not sure what to make of SE estimates for PA (Eq. 7)

% Estimate standard error of proportional area for each class (Eq. 10)
for k = 1:q
    temp = NaN(1, q);
    
    for i = 1:q
        temp(i) = (w(i) * CMright(i, k) - CMright(i, k)^2) / (ni(i) - 1);
    end
    
    statsRight.fc_se(k) = sqrt(sum(temp)); clear temp;
end



end

