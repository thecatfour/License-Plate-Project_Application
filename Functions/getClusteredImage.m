function output = getClusteredImage(processImage, clusters)
% Uses k means to cluster the process image to help distinguish
% the license plate number
  
    % k means
    [h, w, d] = size(processImage);
    imgVector = double(reshape(processImage, h*w, d));
    rng(1000);
    [idx, C] = kmeans(imgVector, clusters);
    clusteredImg = reshape(idx,h,w);
    
    % the cluster with the characters should be the lowest intensity
    lowestIntensity = 255;
    lowestIndex = 0;

    for i = 1:clusters
        if lowestIntensity > C(i)
            lowestIntensity = C(i);
            lowestIndex = i;
        end
    end

    % uses helper function to get one part of the clustered image
    cluster = getCluster(clusteredImg,lowestIndex);
    sumOf1s = 0;

    % determines if the image needs to be inverted
    for r = 1:height(cluster)
        for c = 1:height(cluster)
            if cluster(r,c) == 1
                sumOf1s = sumOf1s + 1;
            end
        end
    end

    % if there are more 1s than 0s, the license plate numbers are
    % probably 0s, so we need to invert it for processing
    if sumOf1s > r*c/2
        cluster = ~cluster;
    end

    SE = strel("disk", 2);
    cluster = imopen(cluster,SE);
    cluster = imclose(cluster,SE);
    cluster = bwmorph(cluster,"thin",1);

    output = cluster;

    return;
end

function output = getCluster(clusteredImage, clusterID)
output = logical(clusteredImage);

    for r = 1:height(output)
        for c = 1:width(output)
            if clusteredImage(r,c) == clusterID
                output(r,c) = 1;
            else
                output(r,c) = 0;
            end
        end
    end
end