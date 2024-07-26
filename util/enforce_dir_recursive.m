function testexist = enforce_dir_recursive(dirPath)
% simple helper function for checking if a directory exists and creating it
% if it doesn't
% NOTE: I have not tests this one
% 2024/02/13 Ed Bello

testexist = exist(dirPath, 'dir');
if ~testexist
    % first check if the preceding directory in the path exists, if not
    % create THAT one first...
    [filepath,~,~] = fileparts(dirPath);
    if ~exist(filepath, 'dir')
        enforce_dir_recursive(filepath);
        
    end
    
    
    % THEN create the last one in the path...
    warning(['User-specified directory ' dirPath ' does not yet exist, creating now...']);
    mkdir(dirPath);
    
end

end
