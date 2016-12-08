import numpy as np
from scipy import misc
import sys
import re

if __name__ == "__main__":
	if len(sys.argv) != 3:
		print("Usage: python3 colorimg.py [input filename] [output image name]")

	with open(sys.argv[1], "r") as filehandle:
		fileList = filehandle.readlines()

	pixelsInRows = [re.findall(r'(.+?);', row) for row in fileList[:-1]]

	threeDList = []
	for row in pixelsInRows:
		rowList = []
		for pixel in row:
			pixelList = [int(val, 16) for val in pixel.split(',')]
			rowList.append(pixelList)
		threeDList.append(rowList)

	colorImage = np.array(threeDList, dtype=np.uint8)
	misc.imsave(sys.argv[2], colorImage)

