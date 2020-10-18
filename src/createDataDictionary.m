% (C) Copyright 2020 CPP_BIDS developers

function createDataDictionary(cfg, logFile)
    % createDataDictionary(cfg, logFile)
    %
    % creates the data dictionary to be associated with a _events.tsv file
    % will create empty field that you can then fill in manually in the JSON
    % file

    fileName = strrep(logFile(1).filename, '.tsv', '.json');
    fullFilename = getFullFilename(fileName, cfg);

    jsonContent = setJsonContent(fullFilename, logFile);

    opts.Indent = '    ';
    bids.util.jsonencode(fullFilename, jsonContent, opts);

end

function jsonContent = setJsonContent(fullFilename, logFile)

    % transfer content of extra fields to json content
    namesExtraColumns = returnNamesExtraColumns(logFile);

    % default content for events file that will be overriddent if we are dealing
    % with a stim file
    jsonContent = struct( ...
                         'onset', struct( ...
                                         'Description', 'time elapsed since experiment start', ...
                                         'Units', 's'), ...
                         'trial_type', struct( ...
                                              'Description', 'types of trial', ...
                                              'Levels', ''), ...
                         'duration', struct( ...
                                            'Description', 'duration of the event or the block', ...
                                            'Units', 's') ...
                        );

    if contains(fullFilename, '_stim')

        jsonContent = struct( ...
                             'SamplingFrequency', nan, ...
                             'StartTime',  nan, ...
                             'Columns', []);

    end

    for iExtraColumn = 1:numel(namesExtraColumns)

        nbCol = returnNbColumns(logFile, namesExtraColumns{iExtraColumn});

        for iCol = 1:nbCol

            headerName = returnHeaderName(namesExtraColumns{iExtraColumn}, nbCol, iCol);

            if contains(fullFilename, '_stim')

                jsonContent.Columns{end + 1} = headerName;

            end

            jsonContent.(headerName) = ...
                logFile(1).extraColumns.(namesExtraColumns{iExtraColumn}).bids;

        end

    end

end
