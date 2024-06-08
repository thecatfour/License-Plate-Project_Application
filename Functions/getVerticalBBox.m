function output = getVerticalBBox(processImage,cannyThreshold,cropThresholdDividend)
%   Takes in a grayscale license plate and returns a bbox
%   for the possible location of the number/word
    
    % Since license plates usually have large characters for the
    % actual number, we can use edge detection to find possible
    % locations for the real words rather than the random words
    % and decorations
    edges = edge(processImage,"canny",cannyThreshold);

    edgeFrequency = zeros(1, height(processImage));
    edgeSum = 0;

    % Adds up the edge pixels into an array
    % Higher numbers mean more edge pixels in that row
    for r = 1:height(edges)
        for c = 1:width(edges)
            edgeFrequency(r) = edgeFrequency(r) + edges(r,c);
            edgeSum = edgeSum + edges(r,c);
        end
    end

    bboxTop = 1;
    bboxBot = height(edges);
    largestRow = 0;
    tempTop = 0;
    tempBot = 0;
    threshold = floor(edgeSum/cropThresholdDividend);

    % Uses the amount of edges to estimate the location of the 
    % plate number
    for r = 1:width(edgeFrequency)
        currentFrequency = edgeFrequency(r);

        % Finds a potential range of rows
        if tempTop == -1 && currentFrequency >= threshold 
            tempTop = r;
        elseif currentFrequency < threshold
            tempBot = r;
        end

        % If the range is the largest, save it
        if tempTop ~= -1 && tempBot ~= -1
            if tempBot - tempTop > largestRow
                bboxTop = tempTop;
                bboxBot = tempBot;
                largestRow = bboxBot - bboxTop;
                tempTop = -1;
                tempBot = -1;
            end
        end

    end

    if bboxTop - 5 > 1
        bboxTop = bboxTop - 5;
    end

    if bboxBot + 5 < width(processImage)
        bboxBot = bboxBot + 5;
    end

    % If no good crop was found, just use the whole image
    if bboxTop > bboxBot
        bboxTop = 1;
        bboxBot = height(edges);
    end

    output = [1,bboxTop,width(processImage),bboxBot-bboxTop];

    return;
end

