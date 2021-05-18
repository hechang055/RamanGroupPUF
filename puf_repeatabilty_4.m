clear;clc;close;
file = dir('D:\Doctoral study\Lijin\result_repeatability\train\*.txt');
%%
num=[];total_intensity = [];
for i = 1:length(file)
%     index_ = strfind(file(i).name,'Yuan');
    num = [num;str2num(file(i).name(5:6))];
    intensity = importdata([file(i).folder,'\',file(i).name]);
    intensity = intensity(intensity(:,3)==0,:);
    intensity = intensity(:,4);
    intensity = intensity(intensity~=intensity(1,1));
%     intensity = mapminmax(reshape(intensity,1,50*50),0,1);
    intensity = mapstd(intensity',0,1);
    total_intensity = [total_intensity;intensity];
%     total_intensity = cat(3,total_intensity,intensity);
end
%%
x0 = [-0.55,-0,0.6]';
n = length(x0);
A = zeros(n,n); b = ones(n,1);epison = 0.01;
% lb = [0.1;0.301;0.601]; ub = [0.3;0.6;0.9];
% x0 = -0.2;
lb = [-0.6;-0.19;0.401]; ub = [-0.25;0.2;0.8];
options = optimoptions('fmincon','Display','iter','Algorithm','sqp','MaxIterations',100);
%%
%% global search
problem = createOptimProblem('fmincon','objective',@f,'x0',x0,'lb',lb,'ub',ub,'nonlcon',@fcon,'options',options);
% gs=GlobalSearch;
% [x,fval] = run(gs,problem);
ms=MultiStart;
[x,fval] = run(ms,problem,200);
%%
data = map_data(total_intensity,x);
diff_same = [];diff_different = [];
for i = 1:size(total_intensity,1)
    for j = i+1:size(total_intensity,1)
        if num(i)==num(j)
            diff_same = [diff_same,(sum(data(i,:)~=data(j,:))/size(total_intensity,2))];
        else
            diff_different = [diff_different,(sum(data(i,:)~=data(j,:))/size(total_intensity,2))];
        end
    end
end
%% test
file_test = dir('D:\Doctoral study\Lijin\result_repeatability\test\*.txt');
num_test=[];total_intensity_test = [];
for i = 1:length(file_test)
%     index_test = strfind(file_test(i).name,'-');
    num_test = [num_test;str2num(file_test(i).name(5:6))];
    intensity_test = importdata([file_test(i).folder,'\',file_test(i).name]);
    intensity_test = intensity_test(:,4);
    intensity_test = intensity_test(intensity_test~=intensity_test(1,1));
%     intensity_test = mapminmax(reshape(intensity_test,1,50*50),0,1);
    intensity_test = mapstd(intensity_test',0,1);
    total_intensity_test = [total_intensity_test;intensity_test];
%     total_intensity = cat(3,total_intensity,intensity);
end
data_test = map_data(total_intensity_test,x);
diff_same_test = [];diff_different_test = [];
for i = 1:size(total_intensity_test,1)
    for j = i+1:size(total_intensity_test,1)
        if num_test(i)==num_test(j)
            diff_same_test = [diff_same_test,(sum(data_test(i,:)~=data_test(j,:))/size(total_intensity_test,2))];
        else
            diff_different_test = [diff_different_test,(sum(data_test(i,:)~=data_test(j,:))/size(total_intensity_test,2))];
        end
    end
end
%%
figure(1)
scatter(1-diff_same,ones(size(diff_same)),5,'r');
hold on
scatter(1-diff_different,ones(size(diff_different)),5,'b');
hold on
scatter(1-diff_same_test,ones(size(diff_same_test))+1,5,'k');
hold on
scatter(1-diff_different_test,ones(size(diff_different_test))+1,5,'y');
hold off
%%
figure(2)
hist(1-diff_same,ones(size(diff_same)),'r');
hold on
hist(1-diff_different,ones(size(diff_different)),'b');
hold on
hist(1-diff_same_test,ones(size(diff_same_test))+1,'k');
hold on
hist(1-diff_different_test,ones(size(diff_different_test))+1,'y');
hold off
%%
% figure(2)
% imagesc(reshape(data(80,:),50,50))
index = [1,2,3,4,5,6,7,8,9];
result = zeros(9,9);
for i = 1:9
    for j = 1:9
        result(i,j) = sum(data_test(index(i),:)==data_test(index(j),:))/size(total_intensity_test,2);
    end
end
%%
function result_map = map_data(map_intensity, x0)
x0 = sort(x0);
map_temp = map_intensity;
map_intensity(map_temp <= x0(1)) = 0;
for i = 1:length(x0)
    map_intensity(map_temp > x0(i)) = i;
end
result_map = map_intensity;
end

function diff = f(x0)
total_intensity = evalin('base', 'total_intensity');
num = evalin('base','num');
data = map_data(total_intensity,x0);
diff = 0;
for i = 1:size(total_intensity,1)
    for j = i+1:size(total_intensity,1)
        if num(i)==num(j)
            diff = diff+((sum(data(i,:)~=data(j,:))/size(total_intensity,2)))/size(num,1);
        else
            diff = diff-((sum(data(i,:)~=data(j,:))/size(total_intensity,2)))/(size(num,1)*(size(num,1)-3)/2);
        end
    end
end
end

function [c,ceq] = fcon(x0)
epison = evalin('base', 'epison');
x1 = [x0(2:end);1]+epison;
c = x0-x1;
ceq = [];
end
%%
