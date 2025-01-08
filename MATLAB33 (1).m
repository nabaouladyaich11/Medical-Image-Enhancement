function medical_image_processing_gui()
    % Create a dialog box for the user to decide whether to proceed
    choice = questdlg('Welcome to the Medical Radiology Images Processing Tool! This program allows you to select a radiology image and apply various enhancement techniques, including filtering, histogram equalization, and segmentation. First, choose or upload an image. Next, select your desired processing techniques, and finally, view and compare the processed results. Would you like to proceed?', ...
        'Medical Image Processing', ...
        'Yes', 'Cancel', 'Yes');
    
    % Handle the user's choice
    switch choice
        case 'Yes'
            runProgram();  % Proceed to the main program
        case 'Cancel'
            return;  % Exit the program
    end
end

function runProgram()
    % Create the main figure window
    fig = figure('Name', 'Medical Image Selection', 'Position', [100 100 800 600], 'Color', [0.5, 0.7, 1]);  % Light blue background

    % Display 5 sample images for selection in a 1x5 grid
    for i = 1:5
        subplot(1,5,i);  % Create a row of 5 images
        imgPath = fullfile('MATLAB33', ['image', num2str(i), '.jpg']);  % Path to the image
        imgHandle = imshow(imread(imgPath));  % Display the image and get the image handle
        title(['Image ', num2str(i)], 'Color', 'white');  % Set title text to white
        
        % Set a callback directly on the image handle
        set(imgHandle, 'ButtonDownFcn', @(src, event)processImageSelection(i));
    end

    % Add a button below the images to upload an image from the user's device
    uicontrol('Style', 'pushbutton', 'String', 'Upload Image', ...
        'Position', [350 50 100 90], 'BackgroundColor', [0, 0, 0.5], ...
        'ForegroundColor', 'white', ...
        'Callback', @(src, event)uploadImageFromDevice());
end

% Function to handle image selection from the pre-loaded images
function processImageSelection(imageIndex)
    disp(['Selected Image: ', num2str(imageIndex)]);
    
    % Load the selected image
    selectedImage = imread(['image', num2str(imageIndex), '.jpg']);
    
    % Continue with the operation selection process
    proceedWithSelectedImage(selectedImage);
end

% Function to handle image upload from the user's device
function uploadImageFromDevice()
[file, path] = uigetfile({'.jpg;.jpeg;*.png', 'Image Files (.jpg, *.jpeg, *.png)'}, 'Select an Image');  % Open file dialog   
    if isequal(file, 0)
        disp('User canceled image upload.');  % If no file is selected, cancel
    else
        selectedImage = imread(fullfile(path, file));  % Read the selected image
        disp(['User selected: ', fullfile(path, file)]);
        
        % Continue with the operation selection process
        proceedWithSelectedImage(selectedImage);
    end
end

% Function to handle the selected image (from either pre-loaded or uploaded)
function proceedWithSelectedImage(selectedImage)
    % Create a figure divided into input and output sections
    fig = figure('Name', 'Select Operations', 'Position', [300, 300, 800, 400], 'Color', [0.5, 0.7, 1]);  % Light blue background
    
    % Input section for selected image and operations checkboxes
    inputPanel = uipanel('Title', 'Input', 'Position', [0.05 0.05 0.4 0.9], 'BackgroundColor', [0.5, 0.7, 1], 'ForegroundColor', 'white');  % Light blue background
    axInput = axes('Parent', inputPanel, 'Position', [0.1 0.5 0.8 0.4]);  % Display selected image
    imshow(selectedImage, 'Parent', axInput);
    title(axInput, 'Selected Image', 'Color', 'white');  % Set title text to white
    
    % Checkboxes for selecting the operations
    cb1 = uicontrol('Parent', inputPanel, 'Style', 'checkbox', 'String', 'Gaussian Filter', ...
        'Position', [100 150 150 20], 'Value', 0, 'BackgroundColor', [0, 0, 0.5], 'ForegroundColor', 'white');
    cb2 = uicontrol('Parent', inputPanel, 'Style', 'checkbox', 'String', 'Histogram Equalization', ...
        'Position', [100 120 150 20], 'Value', 0, 'BackgroundColor', [0, 0, 0.5], 'ForegroundColor', 'white');
    cb3 = uicontrol('Parent', inputPanel, 'Style', 'checkbox', 'String', 'Sharpening', ...
        'Position', [100 90 150 20], 'Value', 0, 'BackgroundColor', [0, 0, 0.5], 'ForegroundColor', 'white');
           
    % Output section for processed image
    outputPanel = uipanel('Title', 'Output', 'Position', [0.55 0.05 0.4 0.9], 'BackgroundColor', [0.5, 0.7, 1], 'ForegroundColor', 'white');  % Light blue background
    axOutput = axes('Parent', outputPanel, 'Position', [0.1 0.5 0.8 0.4]);

    % Button to process the image with selected operations
    uicontrol('Style', 'pushbutton', 'String', 'Process', ...
        'Position', [150 40 100 30], 'BackgroundColor', [0, 0, 0.5], ...  % Dark blue background for button
        'ForegroundColor', 'white', ...  % White text
        'Callback', @(src, event)updateProcessedImage(selectedImage, cb1, cb2, cb3, axOutput));
    
    % Confirm button to finalize selection and proceed
    uicontrol('Style', 'pushbutton', 'String', 'Confirm', ...
        'Position', [550 40 100 30], 'BackgroundColor', [0, 0, 0.5], ...  % Dark blue background for button
        'ForegroundColor', 'white', ...  % White text
        'Callback', @(src, event)confirmProcessing(selectedImage, cb1, cb2, cb3));
end

% Function to update the processed image in the output section
function updateProcessedImage(selectedImage, cb1, cb2, cb3, axOutput)
    % Process the image with selected techniques
    processedImage = applyOperations(selectedImage, cb1, cb2, cb3);
    % Display the processed image in the output section
    imshow(processedImage, 'Parent', axOutput);
    title(axOutput, 'Processed Image', 'Color', 'white');  % Set title text to white
end

% Function to process the image with selected techniques
function processedImage = applyOperations(image, cb1, cb2, cb3)
    % Step 1: Noise Reduction (Gaussian Filtering) if selected
    if cb1.Value == 1
        disp('Applying Gaussian Filter...');
        image = imgaussfilt(image, 2);  % Gaussian filter with size 2 (SIGMA) 
    end

    % Step 2: Histogram Equalization if selected
    if cb2.Value == 1
        disp('Applying Histogram Equalization...');
        if size(image, 3) == 3  % If it's RGB
            % Apply histeq to each channel
            image = cat(3, histeq(image(:, :, 1)), histeq(image(:, :, 2)), histeq(image(:, :, 3)));
        else
            image = histeq(image);  % Grayscale image
        end
    end

    % Step 3: Sharpening if selected
    if cb3.Value == 1
        disp('Applying Sharpening...');
        image = imsharpen(image, 'Radius', 2, 'Amount', 1);
    end
    
    processedImage = image;
end

% Function to confirm processing and continue with other operations
% Function to confirm processing and continue with other operations
function confirmProcessing(selectedImage, cb1, cb2, cb3)
    % Process the image with selected techniques
    processedImage = applyOperations(selectedImage, cb1, cb2, cb3);
    
    % Step 4: Edge Detection using Canny
    disp('Performing Edge Detection...');
    edgeDetectedImage = edge(im2gray(processedImage), 'Canny');
    
    % Step 5: Invert the Image (Negative Transformation)
    disp('Inverting Image...');
    invertedImage = imcomplement(processedImage);

    % Step 6: Active Contour (Snake) Segmentation
    disp('Performing Active Contour Segmentation...');
    grayImage = im2gray(invertedImage); % Convert to grayscale ( ONLY WORKS ON GRAY IMAGES)
    
    % Pre-process with a binary threshold to initialize mask
    binaryMask = imbinarize(grayImage, 'adaptive', 'Sensitivity', 0.5);
    
    % Initialize the contour with the binary mask
    iterations = 300;  % Number of iterations for the active contour
    activeContourMask = activecontour(grayImage, binaryMask, iterations, 'edge');

    % Overlay the contour on the original image
    segmentedActiveContourImage = imoverlay(grayImage, activeContourMask, [1 0 0]);  % Red contour
    
    % Display the results in subplots
    figure('Color', [0.5, 0.7, 1]);  % Light blue background
    subplot(2, 3, 1); imshow(selectedImage); title('Original Image', 'Color', 'white');
    subplot(2, 3, 2); imshow(processedImage); title('Processed Image', 'Color', 'white');
    subplot(2, 3, 3); imshow(edgeDetectedImage); title('Edge Detection', 'Color', 'white');
    subplot(2, 3, 4); imshow(invertedImage); title('Inverted Image', 'Color', 'white');
    subplot(2, 3, 5); imshow(segmentedActiveContourImage); title('Segmented Image (Active Contour)', 'Color', 'white');
    sgtitle('Results of Processes', 'Color', 'white');  % Set sgtitle text to white

    % Ask user if they want to see histograms
    choice_hist = questdlg('Do you want to see the histograms of the original and processed images?', ...
        'View Histograms', 'Yes', 'No', 'No');
    
    switch choice_hist
        case 'Yes'
            displayHistograms(selectedImage, processedImage, invertedImage, segmentedActiveContourImage, cb1, cb2, cb3);  % Display histograms
    end

    % Ask user if they want to restart or exit
    choice = questdlg('Do you want to process another image or exit?', ...
        'Continue or Exit', 'Restart', 'Exit', 'Restart');
    
    switch choice
        case 'Restart'
            runProgram();  % Restart the program
        case 'Exit'
            close all;  % Close all windows and exit
    end
end

% Function to display histograms of the original and processed images
function displayHistograms(originalImage, processedImage, invertedImage, segmentedImage, cb1, cb2, cb3)
    figure('Name', 'Image Histograms', 'Color', [0.5, 0.7, 1]);  % Light blue background
    
    % Convert to grayscale if the images are RGB
    if size(originalImage, 3) == 3
        originalImageGray = rgb2gray(originalImage);
    else
        originalImageGray = originalImage;
    end
    
    if size(processedImage, 3) == 3
        processedImageGray = rgb2gray(processedImage);
    else
        processedImageGray = processedImage;
    end

    if size(invertedImage, 3) == 3
        invertedImageGray = rgb2gray(invertedImage);
    else
        invertedImageGray = invertedImage;
    end

    if size(segmentedImage, 3) == 3
        segmentedImageGray = rgb2gray(segmentedImage);
    else
        segmentedImageGray = segmentedImage;
    end

    % Display the histogram of the original image
    subplot(3, 3, 1);
    imhist(originalImageGray);
    title('Original Image Histogram', 'Color', 'white');  % Set title text to white
    
    % Display the histogram of the processed image
    subplot(3, 3, 2);
    imhist(processedImageGray);
    title('Processed Image Histogram', 'Color', 'white');  % Set title text to white

    % Conditionally display histograms for each selected operation
    if cb1.Value == 1
        subplot(3, 3, 4);
        imhist(imgaussfilt(originalImageGray, 2));
        title('Gaussian Filter Histogram', 'Color', 'white');  % Set title text to white
    end
    if cb2.Value == 1
        subplot(3, 3, 5);
        imhist(histeq(originalImageGray));
        title('Histogram Equalization', 'Color', 'white');  % Set title text to white
    end
    if cb3.Value == 1
        subplot(3, 3, 6);
        imhist(imsharpen(originalImageGray, 'Radius', 2, 'Amount', 1));
        title('Sharpening Histogram', 'Color', 'white');  % Set title text to white
    end
    
    % Display the histogram of the inverted image
    subplot(3, 3, 7);
    imhist(invertedImageGray);
    title('Inverted Image Histogram', 'Color', 'white');  % Set title text to white

    % Display the histogram of the segmented image
    subplot(3, 3, 8);
    imhist(segmentedImageGray);
    title('Segmented Image Histogram', 'Color', 'white');  % Set title text to white

    sgtitle('Histogram Results', 'Color', 'white');  % Set sgtitle text to white
end