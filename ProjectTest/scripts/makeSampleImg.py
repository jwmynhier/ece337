import numpy as np
from scipy import misc
import sys
import re

if __name__ == "__main__":

	asicImage = misc.imread("docs/Asic.png", mode='RGB')
	
	outString = ""

	print("{}".format(asicImage.shape))
	for row in asicImage:
		for pixel in row:
			r, g, b = pixel 
			outString += "{:x},{:x},{:x};".format(r, g, b)
		outString += "\n"

	with open("docs/sampleColorImage.txt", 'w') as filehandle:
		filehandle.write(outString)
