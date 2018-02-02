function stringmatrix = writedownmatrix(matrix)
stringmatrix = '';
for i =1:size(matrix,1)
    for j = 1:size(matrix,2)
        stringmatrix = strcat(stringmatrix,'(', num2str(i),',',num2str(j),'):', num2str(matrix(i,j)),'\t');
    end
end
end