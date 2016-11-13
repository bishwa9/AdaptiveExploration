import sys
import random
import numpy as np

fileName = sys.argv[1]
numTests = int(sys.argv[2])
testDataFile = sys.argv[3]

targetFile = open(fileName, 'w')
targetFile.truncate()

mapMinX = 1
mapMinY = 1
mapMaxX = 400
mapMaxY = 400

qBounds = [[mapMinX, mapMaxX/2.0, mapMinY, mapMaxY/2.0],
           [mapMaxX/2.0+1, mapMaxX, mapMinY, mapMaxY/2.0],
           [mapMinX, mapMaxX/2.0, mapMaxY/2.0+1, mapMaxY],
           [mapMaxX/2.0+1, mapMaxX, mapMaxY/2.0+1, mapMaxY]]

for i in xrange(0, numTests):
    line1 = "Test " + str(i+1) + ":"
    line2 = "File " + testDataFile
    line3 = "MapBounds " + str(mapMinX) + " " + str(mapMaxX) + " " + str(mapMinY) + " " + str(mapMaxY) + " 1 3"

    # choose a certain quadrant
    listQuadrants = [0, 1, 2, 3]
    p_quadrants = [1/4.]*4
    p_other_quadrants = [1/3.]*3
    quadrant1_ = np.random.multinomial(1, p_quadrants)
    quadrant1 = [i for i, e in enumerate(quadrant1_) if e != 0]
    quadrant2_ = np.random.multinomial(1, p_other_quadrants)
    quadrant2 = [i for i, e in enumerate(quadrant2_) if e != 0]
    q1 = listQuadrants[quadrant1[0]]
    listQuadrants.remove(q1)
    q2 = listQuadrants[quadrant2[0]]

    # calculate boundaries of the chosen quadrants
    q1_bounds = qBounds[q1]
    q2_bounds = qBounds[q2]

    st_config = [random.randint(q1_bounds[0], q1_bounds[1]), random.randint(q1_bounds[2], q1_bounds[3])]
    end_config = [random.randint(q2_bounds[0], q2_bounds[1]), random.randint(q2_bounds[2], q2_bounds[3])]
    line4 = "Start " + str(st_config[0]) + " " + str(st_config[1])
    line5 = "End " + str(end_config[0]) + " " + str(end_config[1])

    targetFile.write(line1 + "\n")
    targetFile.write(line2 + "\n")
    targetFile.write(line3 + "\n")
    targetFile.write(line4 + "\n")
    targetFile.write(line5 + "\n")
    targetFile.write("\n")