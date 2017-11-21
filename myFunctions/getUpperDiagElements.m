function [newmat] = getUpperDiagElements(mymat)

newmat = [];
mymat = triu(mymat,1);
for i=1:size(mymat,1)
    for j=1:size(mymat,2)
        if i<j
            newmat(end+1) = mymat(i,j);
        end
    end
end