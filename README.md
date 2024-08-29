# Semantic_Segmentation_Picker

## Semantic segmentation-based detection algorithm for challenging cryo-electron microscopy RNP samples

**Semantic_Segmentation_Picker** is a MATLAB code based on semantic segmentation designed for the automatic detection of challenging influenza A virus ribonucleoproteins (RNPs) and their ends in single-particle cryo-electron microscopy. The approach only requires a set of manually labeled micrographs as input to train the deep neural network (usually between 100-300 micrographs). After the training step, the network can pick challenging samples like the influenza A virus ribonucleoproteins.

## Usage Guide

### Manual Labeling

The first recommended step to use **Semantic_Segmentation_Picker** is training the neural network. To this end, you should manually label between 100-300 of your micrographs. It is recommended to use downsampled micrographs for labeling, training, and automatic picking. Typically, using a sampling rate between 5-7 Å/px for the micrographs is a good choice. For manual labeling, you can use options like MATLAB's [Image Labeler tool](https://es.mathworks.com/help/vision/ref/imagelabeler-app.html) or the [Label Studio Python tool](https://labelstud.io/). After using any of these tools, you should have two folders: one with the downsampled micrographs (e.g., `IMAGES_FILTERED`) and another with the manually labeled images (e.g., `SEGMENTED`). Note that corresponding images in both folders must share the same ordering, so the i-th image should coincide in both folders. Please see an example of a manual labeling process for RNP samples [here](https://zenodo.org/records/12922653).

### Network Training

To train the network, use the script `script_matlab_training.m`. Please modify the variable `imDir1` (line 8) to point to the folder storing the downsampled micrographs and the variable `pxDir1` (line 10) to point to the folder storing the manually labeled images. If the image size is different from `[640 448] px`, please modify the `imageSize` parameter (line 45). After setting these folders and the image size correctly, run the script `script_matlab_training.m` to train the network. The network will be stored in the variable `net`, and all the results will be stored in the file `results_training.mat`.

### Evaluation of the Training

The evaluation of the model's segmentation predictions can be done using conventional metrics for assessing semantic segmentation, such as Global Accuracy, Mean Accuracy, Mean Intersection over Union, Weighted IoU, and the Boundary F1 Score for the training and validation sets. To obtain these metrics, run the script `script_matlab_evaluation.m` without any modification. This script will also show some segmentation examples for visual assessment.

### Automatic Picking of Micrographs

The script `script_matlab_starfile.m` is responsible for generating the star files with the coordinates of the RNP ends. Please modify the variables `imDir1` (line 7) to point to the folder storing the downsampled micrographs and the `downsampling` variable (line 9) with the downsampling factor applied to the images. Finally, modify line 38 with the path to the folder where you want to store the `.star` files.

## Example of use

Please download the `IMAGES` folder at [https://zenodo.org/records/12922653](https://zenodo.org/records/12922653). This folder contains two folders (`IMAGES_FILTERED` and `SEGMENTED`) with the downsampled and manually segmented images.

To train the network, change the variables `imDir1` and `pxDir1` in the script `script_matlab_training.m` and execute in the command line:

`$ matlab -nodisplay -nosplash -r "script_matlab_training; exit"`

To evaluate the training, execute in the command line:

`$ matlab -nodisplay -nosplash -r "script_matlab_evaluation; exit"`

Finally, to obtain the `.star` files, modify the `imDir1` variable and execute:

`$ matlab -nodisplay -nosplash -r "script_matlab_starfile.m; exit"`



