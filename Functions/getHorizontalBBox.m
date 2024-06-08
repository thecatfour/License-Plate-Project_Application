function output = getHorizontalBBox(processImage)
%   Function takes in an image and determines where potential horizontal
%   crops could be.

    %processImage = medfilt2(processImage,[5 5]);
    
    processImage = binarizeImage(processImage);

    SE = strel("disk", 3);
    processImage = imopen(processImage,SE);

    pixelQuantity = zeros(1, width(processImage));
    edgeSum = 0;

    % Adds up the edge pixels into an array
    % Higher numbers mean more edge pixels in that row
    for r = 1:height(processImage)
        for c = 1:width(processImage)
            pixelQuantity(1,c) = pixelQuantity(1,c) + processImage(r,c);
            edgeSum = edgeSum + processImage(r,c);
        end
    end

    % These are used to distingush from useful characters from possible
    % noise text or images
    objectThreshold = ceil(height(processImage) * 0.4);
    minObjectThreshold = ceil(height(processImage) * 0.05);
    minObjectWidth = ceil(getAverageObjectWidth(processImage,pixelQuantity,objectThreshold,minObjectThreshold) * 0.5);

    bboxLeft = 1;
    bboxRight = width(processImage);
    objectWidth = 0;
    isObject = false;

    % Some characters, such as 1 or I, are not wide but are tall, so it may
    % be necessary to have an additional counter to help those characters
    % reach the threshold. However, the far left and right may have
    % remnants of the license plate border, so start the variable at a
    % lower value to try ignore those borders.
    veryHigh = -10;

    % Go through image column by column from the left. If it finds a
    % character that is tall enough and wide enough, the loop considers
    % that the first character in the plate number and moves on.
    for c = 1:width(processImage)
        if pixelQuantity(1,c) < minObjectThreshold
            if veryHigh < 0
                veryHigh = veryHigh + 1;
            else
                veryHigh = 0;
            end
            bboxLeft = c;
            isObject = false;
            objectWidth = 0;
        elseif pixelQuantity(1,c) >= objectThreshold
            isObject = true;
            objectWidth = objectWidth + 1;
            veryHigh = veryHigh + 1;
        else
            objectWidth = objectWidth + 1;
        end

        if isObject && (objectWidth + veryHigh >= minObjectWidth)
            break;
        end
    end

    % Potentially add a larger buffer for the leftmost character
    if bboxLeft - 5 > 1
        bboxLeft = bboxLeft - 5;
    end

    objectWidth = 0;
    isObject = false;
    veryHigh = -10;

    % Repeats the algorithm but from the right
    for c = width(processImage):-1:1
        if pixelQuantity(1,c) < minObjectThreshold
            if veryHigh < 0
                veryHigh = veryHigh + 1;
            else
                veryHigh = 0;
            end
            bboxRight = c;
            isObject = false;
            objectWidth = 0;
        elseif pixelQuantity(1,c) >= objectThreshold
            isObject = true;
            objectWidth = objectWidth + 1;
            veryHigh = veryHigh + 1;
        else
            objectWidth = objectWidth + 1;
        end

        if isObject && (objectWidth + veryHigh >= minObjectWidth)
            break;
        end
    end

    if bboxRight + 5 < width(processImage)
        bboxRight = bboxRight + 5;
    end

    % If no good crop was found, just use the whole image
    if bboxLeft > bboxRight
        bboxLeft = 1;
        bboxRight = width(processImage);
    end

    output = [bboxLeft,1,bboxRight-bboxLeft,height(processImage)];

    return;
    
end

function output = getAverageObjectWidth(processImage,pixelQuantity, objectThreshold, minObjectThreshold)
    
    isObject = false;
    objectWidth = 0;

    totalWidth = 0;
    totalObjects = 0;

    for c = 1:width(processImage)
        if pixelQuantity(1,c) < minObjectThreshold
            if isObject
                totalObjects = totalObjects + 1;
                totalWidth = totalWidth + objectWidth; 
            end
            isObject = false;
            objectWidth = 0;
        elseif pixelQuantity(1,c) >= objectThreshold
            isObject = true;
            objectWidth = objectWidth + 1;
        else
            objectWidth = objectWidth + 1;
        end
    end

    if totalObjects > 0
        output = floor(totalWidth/totalObjects);
        return;
    end

    output = 1;

end

function output = binarizeImage(processImage)
    processImage = imbinarize(processImage);
    sumOf1s = 0;

    % determines if the image needs to be inverted
    for r = 1:height(processImage)
        for c = 1:width(processImage)
            if processImage(r,c) == 1
                sumOf1s = sumOf1s + 1;
            end
        end
    end

    % if there are more 1s than 0s, the license plate numbers are
    % probably 0s, so we need to invert it for processing
    if sumOf1s > r*c*0.45
        processImage = ~processImage;
    end

    output = processImage;
end