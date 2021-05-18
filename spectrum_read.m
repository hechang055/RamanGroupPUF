function [shift,spectrum] = spectrum_read(address)
%读取一组光谱数据，shift作为波数，spectrum为强度
    fid = fopen(address);
    spectrum = cell2mat(textscan(fid,'%f %f','Delimiter','\t'));
    shift = spectrum(:,1);
    spectrum = spectrum(:,2);
    fclose(fid);
end