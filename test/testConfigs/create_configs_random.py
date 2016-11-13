import sys
import random
fileName = sys.argv[1]
numTests = int(sys.argv[2])
testDataFile = sys.argv[3]

targetFile = open(fileName, 'w')
targetFile.truncate()

mapMinX = 1
mapMinY = 1
mapMaxX = 400
mapMaxY = 400

for i in xrange(0, numTests):
    line1 = "Test " + str(i+1) + ":"
    line2 = "File " + testDataFile
    line3 = "MapBounds " + str(mapMinX) + " " + str(mapMaxX) + " " + str(mapMinY) + " " + str(mapMaxY) + " 1 3"
    #line3 = "MapBounds 101 200 101 200 1 3"
    #line3 = "MapBounds 201 300 201 300 1 3"
    #line3 = "MapBounds 301 400 301 400 1 3"
    st_config = [random.randint(1, 400), random.randint(1, 400)]
    end_config = [random.randint(1, 400), random.randint(1, 400)]
    line4 = "Start " + str(st_config[0]) + " " + str(st_config[1])
    line5 = "End " + str(end_config[0]) + " " + str(end_config[1])

    targetFile.write(line1 + "\n")
    targetFile.write(line2 + "\n")
    targetFile.write(line3 + "\n")
    targetFile.write(line4 + "\n")
    targetFile.write(line5 + "\n")
    targetFile.write("\n")