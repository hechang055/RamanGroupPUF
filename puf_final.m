clear;clc;close;
%% import data & preprocessing
[filename,path]=txt_import_refer(0);% 读取reference及对应峰位
[filename_mapping,path_mapping]=txt_import_refer(1);% 读取mapping数据
dir = filename_mapping(1:end-4);
if ~exist(dir)
    mkdir(dir);
end
search_value=input_range();
refer=[];
[shift,axis,spectrum]=spectrum_mapping_import([path_mapping,filename_mapping]);
%% read the names and peak positions of references
i=1;
while i <= length(filename)
    if length(strfind(char(filename(i)),'peakposition'))==1
        [probe_name,probepeak] = peak_import_refer([path,char(filename(i))]);
        filename(i)=[];
    else
        [shift0,temp]=spectrum_read([path,cell2mat(filename(i))]);
        temp = smooth_backcor(shift0,temp,5);
        temp_refer = interp1(shift0,temp,shift,'spline');
        refer=[refer,temp_refer'];
        i=i+1;
    end
end
% Adjust the order of Probe-Peak according to the order of file
probe_peak=cell(3,4);
for i=1:length(filename)
    file=char(filename(i));
    for j=1:length(probe_name)
        probe=char(probe_name(j));
        len=length(probe);
        if strcmp(file(1:len),probe)
            probe_peak{i,1}=probe;
            probe_peak{i,2}=probepeak(j);
            [probe_peak{i,3},probe_peak{i,4}]=peak_value([shift',refer(:,i)],probepeak(j),str2num(search_value{1}));
            break;
        else
            continue;
        end
    end
end
refer = [refer,ones(size(shift')),shift',(shift').^2];
% refer = [refer,zeros(size(shift))',zeros(size(shift))',zeros(size(shift))'];
%% smooth & backcor
[~,spec_number] = size(spectrum);
for i=1:spec_number
    spectrum(:,i) = smooth_backcor(shift,spectrum(:,i),5);
end
%% CLS
[~,n] = size(refer);
lb = zeros(n,1);
coeff = zeros(n,spec_number);
A = zeros(n,n);
b = ones(n,1);
res=[];
for i = 1:spec_number
    [coeff_temp,~,res_temp,exitflag] = lsqlin(refer,spectrum(:,i),A,b,[],[],lb,inf);
%     [coeff_temp,~,res_temp] = lsqlin(refer,spectrum(:,i),A,b);
    coeff(:,i) = coeff_temp;
    res = [res,res_temp];
end
x_axis = unique(axis(1,:));x_interval=x_axis(2)-x_axis(1);
y_axis = unique(axis(2,:));y_interval=y_axis(2)-y_axis(1);
% coeff1 = reshape(coeff(1,:).*probe_peak{1,4},[length(x_axis),length(y_axis)]);
% coeff2 = reshape(coeff(2,:).*probe_peak{2,4},[length(x_axis),length(y_axis)]);
% coeff3 = reshape(coeff(3,:).*probe_peak{3,4},[length(x_axis),length(y_axis)]);
% coeff4 = reshape(coeff(4,:),[length(x_axis),length(y_axis)]);
%% plot
% y1=spectrum(:,3);
% y2=refer*coeff(:,3);
% figure(2)
% width=500;
% height=500;
% colormap('hot');
% subplot(2,2,1)
% imagesc(x_axis([1,end]),y_axis([1,end]),coeff1)
% xticks(x_axis(1)-round(x_interval/2):x_interval:x_axis(end)+round(x_interval/2))
% yticks(y_axis(1)-round(y_interval/2):y_interval:y_axis(end)+round(y_interval/2))
% colorbar
% subplot(2,2,2)
% imagesc(x_axis([1,end]),y_axis([1,end]),coeff2)
% xticks(x_axis(1)-round(x_interval/2):x_interval:x_axis(end)+round(x_interval/2))
% yticks(y_axis(1)-round(y_interval/2):y_interval:y_axis(end)+round(y_interval/2))
% colorbar
% subplot(2,2,3)
% imagesc(x_axis([1,end]),y_axis([1,end]),coeff3)
% xticks(x_axis(1)-round(x_interval/2):x_interval:x_axis(end)+round(x_interval/2))
% yticks(y_axis(1)-round(y_interval/2):y_interval:y_axis(end)+round(y_interval/2))
% colorbar
% subplot(2,2,4)
% plot(shift,y1,shift,y2)
%% save coeff data and spectrum data
i = 1;
m = length(filename);
if ~exist([dir,'\result'])
    mkdir([dir,'\result']);
end
while i <= length(filename)
    if i==m
        break;
    elseif length(strfind(char(filename(i)),probe_peak{i,1}))==1
        axis_intensity=transpose([axis;coeff(i,:).*probe_peak{i,4}]);
        temp_spec=[axis',(refer(:,i).*coeff(i,:))'];
        temp_spec=[[0,0,0,shift];temp_spec];
        save([dir,'\result\',probe_peak{i,1},'_intensity_distribution.txt'],'axis_intensity','-ascii');
        save([dir,'\result\',probe_peak{i,1},'_spectrum.txt'],'temp_spec','-ascii');
        i = i+1;
    else
        i=i+1;
        continue;
    end
end