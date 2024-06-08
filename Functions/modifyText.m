function output = modifyText(ocrText)
    text = ocrText.Text;

    for char = 1:width(text)
        if isnan(ocrText.CharacterConfidences(char,1))
            text(char) = " ";
        elseif (ocrText.CharacterConfidences(char,1) < 0.5)
            text(char) = "?";
        end
    end

    output = text;
end