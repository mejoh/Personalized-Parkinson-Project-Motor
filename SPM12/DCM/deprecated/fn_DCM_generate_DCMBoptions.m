function DCMB_models = fn_DCM_generate_DCMBoptions(conf)
% https://www.reddit.com/r/matlab/comments/sbvid/how_can_i_generate_all_3x3_binary_matrices/

MATRIX_SIZE = size(conf.DCMpar.fixconnect,1);

NumBits = MATRIX_SIZE^2;
MaxNumericRepr = (2^NumBits)-1;

DCMB_options = cell(MaxNumericRepr + 1, 1);

for i = 0:MaxNumericRepr
    MatrixDigits = dec2bin(i, NumBits);
    MatrixDigits = reshape(MatrixDigits, [NumBits 1]);
    MatrixDigits = str2num(MatrixDigits);
    
    DCMB_options{i+1} = reshape(MatrixDigits, [MATRIX_SIZE MATRIX_SIZE]);
    DCMB_names{i+1} = reshape(MatrixDigits, [MATRIX_SIZE MATRIX_SIZE]);
    
    if isempty(find(DCMB_options{i+1})')
       name = 'none'; 
    else
        name = sprintf('%.0f_' , find(DCMB_options{i+1})');
        name = name(1:end-1);
    end
    DCMB_names{i+1} = name;
    
    if any(DCMB_options{i+1}(conf.DCMpar.fixconnect==0)) %remove models with 1 on impossible connections (no intrinsic connection)
        DCMB_options{i+1} = [];
        DCMB_names{i+1} = [];
    end
    
    
end
DCMB_models.options = DCMB_options(~cellfun('isempty',DCMB_options));
DCMB_models.names = DCMB_names(~cellfun('isempty',DCMB_names))';

if ~(2^numel(find(conf.DCMpar.fixconnect)) == length(uniquecell(DCMB_models.options)))
    error('Number of generetad DCM.B matrices does not match possible unique DCM.b matrices')
end

end






