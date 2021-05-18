function [filename, path]=txt_import_refer(import_type)
%[filename, path]=txt_import_refer(import_type)
%   import_type : 
%               0: import reference;
%               1: import mapping;
switch import_type
    case 0
        statement='Select the references';
    case 1
        statement='Select the mapping';
end
[filename, path] = uigetfile('*.txt',statement,'MultiSelect', 'on');
end