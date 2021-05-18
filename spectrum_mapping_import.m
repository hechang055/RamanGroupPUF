function [shift,axis,spectrum] = spectrum_mapping_import(address)
%��address�ж�ȡaxis���ݣ�shift���ݺ��ۺϵ�spectrum
    totalspectrum = importdata(address,'\t',1);
    shift=str2double(totalspectrum.textdata);
    axis_number=sum(isnan(shift));
    shift(1:axis_number)=[];
    if axis_number==2
        axis = transpose(totalspectrum.data(:,[2,1]));
        spectrum = transpose(totalspectrum.data(:,3:end));
    else
        axis = transpose(totalspectrum.data(:,[3,2,1]));
        spectrum = transpose(totalspectrum.data(:,4:end));
    end
end