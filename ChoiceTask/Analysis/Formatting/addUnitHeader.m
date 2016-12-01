function addUnitHeader(analysisPath)
    unitHeaderFolder = 'unitHeader';
    prependString = 'HEADER-';

    allAnalysisFiles = dir(fullfile(analysisPath,'*.pdf'));
    parts = strsplit(analysisPath,filesep);
    parentPath = strjoin(parts(1:end-1),filesep);
    allUnitHeaderFiles = dir(fullfile(parentPath,unitHeaderFolder,'*.pdf'));
    for iAnalysisFiles=1:length(allAnalysisFiles)
        % will continue to work long as filename: analysisType_unitName.pdf
        parts = strsplit(allAnalysisFiles(iAnalysisFiles).name,'_');
        unitName = strjoin(parts(2:end),'_');
        for iUnitHeaderFiles=1:length(allUnitHeaderFiles)
            curUnitHeader = allUnitHeaderFiles(iUnitHeaderFiles).name;
            % find correct file and don't include previous HEADER files
            if ~isempty(strfind(curUnitHeader,unitName)) && isempty(strfind(allAnalysisFiles(iAnalysisFiles).name,prependString))
                fileIn = fullfile(analysisPath,allAnalysisFiles(iAnalysisFiles).name);
                background = fullfile(parentPath,unitHeaderFolder,[unitHeaderFolder,'_',unitName]);
                fileOut = fullfile(analysisPath,[prependString,allAnalysisFiles(iAnalysisFiles).name]);
                runPdftk(fileIn,background,fileOut);
            end
        end
    end
end

function runPdftk(fileIn,background,fileOut)
    % !/usr/local/bin/pdftk f1.pdf background bkgd.pdf output text.pdf
    if(ismac)
        pdftkPath = '/usr/local/bin/pdftk';
    else
        error('Windows OS unsupport by savePDF');
    end
    systemString = strjoin({pdftkPath,quotes(fileIn),'background',quotes(background),'output',quotes(fileOut)},' ');
    disp(systemString);
    system(systemString,'-echo');
end

function outString = quotes(inString)
    outString = ['''',inString,''''];
end
