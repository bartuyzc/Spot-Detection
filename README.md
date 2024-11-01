The algorithm used in this project detects spots on diseased leaves. It is a low-computation algorithm that applies basic image processing techniques and utilizes the RGB color space. This method benefits from RGB channels in color images as well as the standard deviation image obtained from the grayscale version. However, due to the simplicity of the operations, the error rate may increase when analyzing images with very bright backgrounds.

Firstly, the file named 'main_code.m' was used to develop our initial algorithm and was tested solely with the image 'leaf.jpg'. Later, the file named 'dataset_code.m' was created to open the sample images in the dataset folder one by one. By adjusting the file path sections in the code, you can modify it to work with your own samples.

The PowerPoint file includes flowcharts about the algorithm, details on its progress, and information on the results obtained.
