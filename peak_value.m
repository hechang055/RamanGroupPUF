function [peak_position,peak_intensity]=peak_value(spectrum,position_esti,range)
    shift=spectrum(:,1);
    intensity=spectrum(:,2);
    intensity(abs(shift-position_esti)>range)=-1;
    [peak_intensity,peak_index]=max(intensity);
    peak_position=shift(peak_index);
end