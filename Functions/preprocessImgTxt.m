function output = preprocessImgTxt(processImage,cannyThreshold,cropThresholdDividend)
    % Preprocesses a license plate image to make it easier to read
    
    processImage = im2gray(processImage);
    processImage = im2uint8(processImage);

    % Make sure image is not too large
    processImage = imresize(processImage,[200 350]);

    % Try reduce some noise
    sigma = 5.0;
    filterSize = 5;
    gfilt = fspecial("gaussian",filterSize,sigma);

    filteredImage = im2double(processImage);

    filteredImage = conv2(filteredImage,gfilt,"same");

    filteredImage = im2uint8(filteredImage);

    filteredImage = medfilt2(filteredImage, [5 5]);

    % First try to crop the image vertically
    bbox = getVerticalBBox(filteredImage,cannyThreshold,cropThresholdDividend);
    cropped = imcrop(processImage,bbox);

    % If the image was not properly cropped, try using kmeans instead of
    % just canny
    if height(cropped) > height(filteredImage) * 0.6
        clustered = getClusteredImage(filteredImage,3);
        bbox = getVerticalBBox(clustered,cannyThreshold,cropThresholdDividend);
        cropped = imcrop(processImage,bbox);
    end

    filteredImage = imcrop(filteredImage,bbox);

    % Now try to crop the image horizontally
    bbox = getHorizontalBBox(filteredImage);
    cropped = imcrop(cropped,bbox);

    % Now apply other image enhancements

    cropped = medfilt2(cropped, [3 3]);

    % -------------cannyOnly Model---------------- %

    %cropped = edge(cropped,"canny",cannyThreshold);

    % -------------imBinarize Model--------------- %

    cropped = imbinarize(cropped);

    cropped = swapBinarization(cropped);

    % -------------output------------------------- %

    output = cropped;
end



function output = swapBinarization(processImage)
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
    if sumOf1s > r*c*0.4
        processImage = ~processImage;
    end

    output = processImage;
end