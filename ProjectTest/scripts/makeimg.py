import numpy as np
from scipy import misc
import sys
import re

if __name__ == "__main__":
	if len(sys.argv) != 3:
		print("Usage: python3 makeimg.py [input filename] [output image name]")

	with open(sys.argv[1], "r") as filehandle:
		fileList = filehandle.readlines()

	dataGrid = [re.findall(r'(0|1)', line) for line in fileList[:-1]]

	byteGrid = [[(int(bit)*255) ^ 255 for bit in row] for row in dataGrid]

	image = np.array(byteGrid, dtype=np.uint8)
	misc.imsave(sys.argv[2], image)

