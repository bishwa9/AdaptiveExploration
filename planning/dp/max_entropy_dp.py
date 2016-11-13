import numpy as np
from Queue import *
from sets import *
import math
import time
import sys
from scipy import io

param_allow_diagonal = True
num_channels = 3

# valuemap = np.array(
# [[ 0.37866864,  0.23534453,  0.2393824 ,  0.06616797,  0.47312144,  0.79824719],
#  [ 0.25237441,  0.93247993,  0.01949977,  0.02434478,  0.596549  ,  0.50894735],
#  [ 0.30053822,  0.85840167,  0.26736156,  0.51304914,  0.52558344,  0.79612578],
#  [ 0.14884559,  0.1378105 ,  0.2317699 ,  0.60844411,  0.26251396,  0.25536067],
#  [ 0.62232353,  0.8214885 ,  0.82412231,  0.29204487,  0.55575365,  0.02315963],
#  [ 0.53933188,  0.39857555,  0.54721225,  0.94435264,  0.10491161,  0.71878113]], dtype=float)

start_location = np.array([0,0])

def initialize(end_pt):
  size = [100,100]
  global end_location
  end_location = end_pt
  distance = np.linalg.norm(end_location - start_location)
  global max_distance
  max_distance = 2*int(get_min_distance([0, start_location[0], start_location[1]])) #int(math.floor(2*distance))
  global dp_table, dp_paths
  dp_table = np.zeros([max_distance+1,size[0],size[1]], dtype=float)
  dp_table.fill(-99999)
  dp_paths = np.ndarray([max_distance+1,size[0],size[1]], dtype=list)

def get_min_distance(curr_point):
  dx = abs(end_location[0] - curr_point[1])
  dy = abs(end_location[1] - curr_point[2])
  if param_allow_diagonal:
    return abs(dx-dy) + 1.414*min(dx,dy)
  else:
    return dx + dy

def get_neighbours(position):
  x = position[1]
  y = position[2]
  n_pos = [ (position[0]+1, x-1, y  ),
            (position[0]+1, x  , y+1),
            (position[0]+1, x+1, y  ),
            (position[0]+1, x  , y-1)
          ]
  if param_allow_diagonal:
    n_pos = n_pos + [ (position[0]+1, x-1, y+1),
                      (position[0]+1, x+1, y+1),
                      (position[0]+1, x+1, y-1),
                      (position[0]+1, x-1, y-1)
                    ]
  filtered_neigh = []
  for pos in n_pos:
    if pos[0] >= 0 and pos[0] + get_min_distance(pos) <= max_distance and pos[1] >= 0 and pos[1] < valuemap.shape[0] and pos[2] >= 0 and pos[2] < valuemap.shape[1]:
      filtered_neigh.append(pos)
  return filtered_neigh

def get_info_gain(path, new_location = None):
  values = [[] for i in range(num_channels)]
  for p in path:
    for i in range(num_channels):
      values[i].append(float(valuemap[p[1], p[2], i]))
  if not new_location == None:
    for i in range(num_channels):
      values[i].append(float(valuemap[new_location[1], new_location[2], i]))
  for i in range(num_channels):
    t = 2*np.pi*np.var(values[i])
    if t==0.0:
      values[i] = -999999
    else:
      values[i] = math.log(t)
  var = .5*sum(values)
  # print 'v', values, 'var: ', var
  return var

# def get_info_gain(path, new_location = None):
#   values = []
#   for p in path:
#     for i in range(num_channels):
#       values.append(valuemap[p[1], p[2], i])
#   if not new_location == None:
#     for i in range(num_channels):
#       values.append(valuemap[new_location[1], new_location[2], i])
#   var = np.var(values)
#   # print 'v', values, 'var: ', var
#   return var

def populate_dp_table():
  frontier = Set([])
  layer = 0
  curr_location = (layer, start_location[0], start_location[1])
  dp_paths[curr_location[0], curr_location[1], curr_location[2]] = [curr_location]
  frontier.add(curr_location)
  while not len(frontier) == 0:
    curr_location = frontier.pop()
    neighbours = get_neighbours(curr_location)
    # print neighbours, curr_location
    curr_path = dp_paths[curr_location[0], curr_location[1], curr_location[2]]
    # print curr_path
    for neigh in neighbours:
      new_value = get_info_gain(curr_path, neigh)
      curr_value = dp_table[neigh[0], neigh[1], neigh[2]]
      if neigh not in frontier:
        frontier.add(neigh)
      if curr_value < new_value:
        # print 'Won', new_value, 'over', curr_value, '. Neigh:', neigh
        dp_table[neigh[0], neigh[1], neigh[2]] = new_value
        dp_paths[neigh[0], neigh[1], neigh[2]] = curr_path + [neigh]
    # print 'Length', len(frontier)

def get_best_end_location(start_pt):
  max_info = -999999
  best_end = []
  for i in range(valuemap.shape[0]):
    for j in range(valuemap.shape[1]):
      curr = get_info_gain([(0, start_location[0], start_location[1]), (1, i, j)])
      if curr > max_info:
        max_info = curr
        best_end = [i,j]
  print max_info
  return best_end

def main():
  global valuemap
  if len(sys.argv) > 1:
    print 'Received file name:', sys.argv[1]
    testData = io.loadmat('../testData/testData/' + sys.argv[1])
    valuemap = testData['valuemap']
  else:
    valuemap = np.random.rand(size[0],size[1],num_channels)
  end_pt = get_best_end_location(start_location)
  # end_pt = np.array([20,0])
  initialize(end_pt)
  distance = np.linalg.norm(end_location - start_location)
  max_distance = int(math.floor(2*distance))
  print 'End location chosen:', end_location
  print 'Original valuemap:', valuemap
  start = time.time()
  populate_dp_table()
  end = time.time()
  best_path = None
  best_info = -99999
  for i in range(max_distance, 0, -1):
    curr_path = dp_paths[i, end_location[0], end_location[1]]
    if not curr_path == None and get_info_gain(curr_path) > best_info:
      best_path = curr_path
      best_info = get_info_gain(curr_path)
  print 'Final Path:', best_path
  print 'Total variance on this path:', best_info
  print 'Time Taken:', end-start
  np_path = np.array(best_path)
  io.savemat('dp_path.mat', {'dp_path_x': np_path[:,1]+1, 'dp_path_y': np_path[:,2]+1})
  from IPython import embed
  embed()


if __name__ == "__main__":
  main()