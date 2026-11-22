# the 11 classes we train on and which of the 32 CamVid classes go into each one
import numpy as np

CLASS_NAMES = ['Sky', 'Building', 'Pole', 'Road', 'Pavement', 'Tree',
               'SignSymbol', 'Fence', 'Car', 'Pedestrian', 'Bicyclist']

GROUPS = {
    'Sky': ['Sky'],
    'Building': ['Archway', 'Bridge', 'Building', 'Tunnel', 'Wall'],
    'Pole': ['Column_Pole', 'TrafficCone'],
    'Road': ['Road', 'LaneMkgsDriv', 'LaneMkgsNonDriv'],
    'Pavement': ['Sidewalk', 'ParkingBlock', 'RoadShoulder'],
    'Tree': ['Tree', 'VegetationMisc'],
    'SignSymbol': ['SignSymbol', 'Misc_Text', 'TrafficLight'],
    'Fence': ['Fence'],
    'Car': ['Car', 'SUVPickupTruck', 'Truck_Bus', 'Train', 'OtherMoving'],
    'Pedestrian': ['Pedestrian', 'Child', 'CartLuggagePram', 'Animal'],
    'Bicyclist': ['Bicyclist', 'MotorcycleScooter'],
}

# label value for Void and anything not in GROUPS, the loss skips it
IGNORE = 255


def read_colours(csv_path):
    # csv_path: str, CamVid class_dict.csv (name,r,g,b per line)
    # returns: dict, class name -> (r, g, b)
    colours = {}
    with open(csv_path) as f:
        lines = f.read().splitlines()
    for line in lines[1:]:
        parts = [p.strip() for p in line.split(',')]
        if len(parts) == 4:
            colours[parts[0]] = (int(parts[1]), int(parts[2]), int(parts[3]))
    return colours


def colour_lookup(colours):
    # colours: dict, class name -> (r, g, b), from read_colours
    # returns: uint8 array of 256^3, index r*65536 + g*256 + b -> our class id 0..10 or IGNORE
    lookup = np.full(256 ** 3, IGNORE, dtype=np.uint8)
    for class_id, name in enumerate(CLASS_NAMES):
        for camvid_name in GROUPS[name]:
            r, g, b = colours[camvid_name]
            lookup[r * 65536 + g * 256 + b] = class_id
    return lookup
