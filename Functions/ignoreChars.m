% Removes unimportant characters if desired
function output = ignoreChars(charArray,ignoredCharsArray)
    
    for i = 1:width(ignoredCharsArray)
        charArray = erase(charArray,ignoredCharsArray(i));
    end

    output = charArray;

    return;
end