The application can be used to read a US license plate and determine the plate number using an OCR.
The image needs to be a jpg, and the license plate needs to be the focus of the image.

"main.mlapp" is the application that can be used to find plate numbers.

"Functions/" contains helper functions for the app to run.
"OCRModel/" contains the trained model named "newBinarized.traineddata".
"Test Plates/" has both successful and unsuccessful examples of license plates to be read.


MATLAB add-ons:

The program and OCR model were built and trained using MATLAB add-ons such as:
	Computer Vision Toolbox
	Deep Learning Toolbox
	Image Processing Toolbox
	
The app may not work properly without MATLAB and these add-ons.


Citations:

Images used for training data and "Test Plates" are from the following sources:
https://www.kaggle.com/datasets/tolgadincer/us-license-plates
https://www.ricksplates.com/uscurrent.htm#gallery
https://tagshack.com/usa-state-official-license-plates
