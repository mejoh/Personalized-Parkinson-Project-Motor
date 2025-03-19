function fn_DCM_generatemodels(conf)
% https://www.reddit.com/r/matlab/comments/sbvid/how_can_i_generate_all_3x3_binary_matrices/



MATRIX_SIZE = 4;

NumBits = MATRIX_SIZE^2;
MaxNumericRepr = (2^NumBits)-1;

BinaryMatrices = cell(MaxNumericRepr + 1, 1);

for i = 0:MaxNumericRepr
    MatrixDigits = dec2bin(i, NumBits);
    MatrixDigits = reshape(MatrixDigits, [NumBits 1]);
    MatrixDigits = str2num(MatrixDigits);

    BinaryMatrices{i+1} = reshape(MatrixDigits, [MATRIX_SIZE MATRIX_SIZE]);
end
length(uniquecell(BinaryMatrices));








