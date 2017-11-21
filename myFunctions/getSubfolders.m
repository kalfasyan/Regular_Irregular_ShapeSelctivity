function [ mydirs ] = getSubfolders( path )

files = dir(path);
dirFlags = [files.isdir];
subFolders = files(dirFlags);
subFolders = struct2cell(subFolders);
mydirs = [];
for i=3:length(subFolders)
    mydirs{i-2} = subFolders{1,i};
end
