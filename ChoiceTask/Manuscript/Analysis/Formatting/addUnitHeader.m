function addUnitHeader(analysisConf,analyses)
    unitHeaderFolder = 'unitHeader';
    prependString = 'HEADER-';
    for iAnalysis = 1:length(analyses)
        for iSession = 1:length(analysisConf.sessionConfs)
            analysisPathTemp = fullfile(analysisConf.sessionConfs{iSession}.leventhalPaths.analysis,analyses{iAnalysis});
            if iSession == 1
                analysisPath = analysisPathTemp;
            else
                if strcmp(analysisPath,analysisPathTemp)
                    continue; % skip if script already ran
                else
                    analysisPath = analysisPathTemp;
                end
            end
            allAnalysisFiles = dir(fullfile(analysisPath,[analyses{iAnalysis},'*.pdf'])); % not headers
            parts = strsplit(analysisPath,filesep);
            % had to use a loop to work in Windows (strjoin ignores empty cells)
            parentPath = '';
            for iParts = 1:numel(parts)-1
                parentPath = [parentPath filesep parts{iParts}];
            end
            allUnitHeaderFiles = dir(fullfile(parentPath,unitHeaderFolder,'*.pdf'));
            for iAnalysisFiles=1:length(allAnalysisFiles)
                % will continue to work long as filename: analysisType_unitName.pdf
                parts = strsplit(allAnalysisFiles(iAnalysisFiles).name,'_');
                unitName = strjoin(parts(2:end),'_');
                for iUnitHeaderFiles=1:length(allUnitHeaderFiles)
                    curUnitHeader = allUnitHeaderFiles(iUnitHeaderFiles).name;
                    % find correct file and don't include previous HEADER files
                    if ~isempty(strfind(curUnitHeader,unitName))
                        fileIn = fullfile(analysisPath,allAnalysisFiles(iAnalysisFiles).name);
                        background = fullfile(parentPath,unitHeaderFolder,[unitHeaderFolder,'_',unitName]);
                        fileOut = fullfile(analysisPath,[prependString,allAnalysisFiles(iAnalysisFiles).name]);
                        runPdftk(fileIn,background,fileOut);
                    end
                end
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
