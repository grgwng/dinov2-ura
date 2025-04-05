# DINOv2 Feature Evaluation

## Summary

The following project runs DINOv2 on an input video and evaluates the consistency of its features throughout the video. Furthermore, the depth of a target object is also measured and used to compare against the DINOv2 features.

## Inputs and Outputs

The project takes in an input video containing a target object and a foreign object used as a 'benchmark' during analysis.

The project outputs a composite video displaying the analysis, input video, foreign object, and DINOv2 output.

A Google Drive containing inputs and sample outputs is provided here:
[Google Drive](https://drive.google.com/drive/folders/1gWyju3rXsY1E6Sd-XPPhtXGD-eo_0VEX?usp=sharing)

`Inputs` contains input videos that are used (or have been used throughout the term)

`ForeignObjectInputs` contains images used as 'foreign' objects.

`Outputs` contains output videos run on some of the inputs.

## How to run

Outputs are generated using 3 steps.

### 1. Install SAM2

Install SAM2 using the instructions [here](https://github.com/facebookresearch/sam2?tab=readme-ov-file#installation). There should now be a `SAM2` directory now in the main directory.

### 2. Prepare inputs

To use SAM2 to perform masking, we need to convert our input video in a series of frames.

Run these commands to create a directory of frames (Replace names as needed)

```
mkdir scissors_images

ffmpeg -i scissors.mp4 -q:v 2 -start_number 0 scissors_images/'%05d.jpg'
```

Additionally ensure that a foreign object image (e.g. `duff.jpeg`, `pen.png`, etc) is in the main directory.

### 3. Run the notebook

Starting from the beginning, run each cell of the `2_PCA_visualization.ipynb` notebook one-by-one. The notebook is split up into sections explained below.

#### Process Video

This section processes the input video. It uses DINOv2 and Depth Pro to get features and depth estimates respectively.

Make sure to change the video path to the input video

#### Process Foreign Object

This section processes the foreign object. It only runs DINOv2. It then adds the foreign object features to the input video features so that they undergo PCA analysis together in the next section.

Make sure to change the `image_path` to the foreign object image.

#### PCA Analysis

PCA analysis is used to find the first three principal components of the features. If necessary, make sure to alter the range in cell 12 to ensure the foreground (object) is masked correctly.

Note that once PCA is completed, the foreign object is seperated from the input video features.

#### SAM2

Now we use SAM2 to generate masks of the target object. We will use the masks to determine the average values of DINOv2 features and depth estimates of the object throughout the video.

Make sure to change the `video_dir` to the input video directory of images created in step 2.
Additionally, if needed, change the `points` and `labels` to select the object in the first frame. Rerun the cell as needed.

We also perform SAM2 to mask the foreign object.
SAM2 provides 3 masks sorted by score. Choose the best one. Rerun as needed.

#### Final Animation

Now, we put everything together. We use the SAM2 masks to mask our DINOv2 features output and DepthPro depth estimations. The masked images (37 x 37) are stored in the directory `outputPNGS` to be used in the output video composition.

We then find the average DINOv2 feature color and depth estimate in the mask. The average DINOv2 feature colors is compared to the average color of the first frame to give a list of color diffs.

We also get the average feature color of the foreign object. The image is saved as the file `foreign_object_masked.png` to be used in the output video composition.

There's the optional ability to save (and load) the color diffs and depth estimates from a csv file.

You can optionally create a scatterplot to plot color diffs against the item depth in each frame.

The last cell creates an animated graph of the color diffs and item depths plotted against time. The graph also shows the depth of the object smoothed with a moving average, as well as a horizontal line representing the benchmark foreign object DINOv2 color difference from the first frame. The animation is saved as `animation.gif` to be used in the output video composition.

### 4. Create output video

Now you should have the following:

- an `animation.gif` file of the animated graph
- a `outputPNGS` directory containing the masked DINOv2 output of the video
- a `foreign_object_masked.png` file of the masked DINOV2 output of the foreign object

The final step combines the above (plus the input video and foreign object image) to create a composite output video.

Simply run the command. (Replace with your own input video and foreign object image)

```
./createVideo.sh boxes.mp4 duff.jpeg
```

This will create a composite output video called `result.mp4`.
