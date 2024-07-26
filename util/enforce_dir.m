function testexist = enforce_dir(dirPath)
% simple helper function for checking if a directory exists and creating it
% if it doesn't
% 2024/02/13 Ed Bello

testexist = exist(dirPath, 'dir');
if ~testexist
    warning(['User-specified directory ' dirPath ' does not yet exist, creating now...']);
    mkdir(dirPath);
    
end

end

