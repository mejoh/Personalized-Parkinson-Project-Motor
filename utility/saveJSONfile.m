function saveJSONfile(data, jsonFileName)

% This file has been copied and adapted from: 
% https://se.mathworks.com/matlabcentral/fileexchange/50965-structure-to-json

% saves the values in the structure 'data' to a file in JSON format.
%
% Example:
%     data.name = 'chair';
%     data.color = 'pink';
%     data.metrics.height = 0.3;
%     data.metrics.width = 1.3;
%     saveJSONfile(data, 'out.json');
%
% Output 'out.json':
% {
% 	"name" : "chair",
% 	"color" : "pink",
% 	"metrics" : {
% 		"height" : 0.3,
% 		"width" : 1.3
% 		}
% 	}
%
    fid = fopen(jsonFileName,'w');
    writeElement(fid, data,'');
    fprintf(fid,'\n');
    fclose(fid);
end

function writeElement(fid, data,tabs)
    namesOfFields = fieldnames(data);
    numFields = length(namesOfFields);
    %tabs = sprintf('%s\t',tabs);
    tabs = sprintf('%s    ',tabs);
    fprintf(fid,'{\n%s',tabs);
   
    for i = 1:numFields - 1
        currentField = namesOfFields{i};
        currentElementValue = eval(sprintf('data.%s',currentField));
        writeSingleElement(fid, currentField,currentElementValue,tabs);
        fprintf(fid,',\n%s',tabs);
    end
    if isempty(i)
        i=1;
    else
      i=i+1;
    end
      
    
    currentField = namesOfFields{i};
    currentElementValue = eval(sprintf('data.%s',currentField));
    writeSingleElement(fid, currentField,currentElementValue,tabs);
    fprintf(fid,'\n%s}',tabs);
end

function writeSingleElement(fid, currentField,currentElementValue,tabs)
    
        % if this is an array and not a string then iterate on every
        % element, if this is a single element write it
        if length(currentElementValue) > 1 && ~ischar(currentElementValue)
            fprintf(fid,' "%s": [\n%s',currentField,tabs);
            for m = 1:length(currentElementValue)-1
                writeElement(fid, currentElementValue(m),tabs);
                fprintf(fid,',\n%s',tabs);
            end
            if isempty(m)
                m=1;
            else
              m=m+1;
            end
            
            writeElement(fid, currentElementValue(m),tabs);
          
            fprintf(fid,'\n%s]\n%s',tabs,tabs);
        elseif isstruct(currentElementValue)
            fprintf(fid,'"%s": ',currentField);
            writeElement(fid, currentElementValue,tabs);
        elseif isnumeric(currentElementValue)
            fprintf(fid,'"%s": %g' , currentField,currentElementValue);
        elseif isempty(currentElementValue)
            fprintf(fid,'"%s": null' , currentField,currentElementValue);
        else %ischar or something else ...
            fprintf(fid,'"%s": "%s"' , currentField,currentElementValue);
        end
end