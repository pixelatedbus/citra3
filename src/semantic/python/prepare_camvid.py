# turns the raw CamVid frames into 360x480 images + 11-class label maps, split 60/20/20 at random
import os
import random
import numpy as np
from PIL import Image
from camvid_classes import CLASS_NAMES, IGNORE, read_colours, colour_lookup

# project folder, three levels up from src/semantic/python/
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
RAW_DIR = os.path.join(ROOT, 'data', 'camvid', 'CamVid')
OUT_DIR = os.path.join(ROOT, 'data', 'camvid', 'prepared')
WIDTH, HEIGHT = 480, 360
SEED = 0
SPLIT = {'train': 0.6, 'val': 0.2}   # the rest is test


def list_frames():
    # returns: list of (image path, label path) for all frames in the raw download
    frames = []
    for part in ['train', 'val', 'test']:
        for name in sorted(os.listdir(os.path.join(RAW_DIR, part))):
            label_name = name.replace('.png', '_L.png')
            frames.append((os.path.join(RAW_DIR, part, name),
                           os.path.join(RAW_DIR, part + '_labels', label_name)))
    return frames


def convert_label(path, lookup):
    # path: str, colour label PNG
    # lookup: uint8 array of 256^3, from colour_lookup
    # returns: uint8 array H x W, class id 0..10 or IGNORE
    rgb = np.array(Image.open(path).convert('RGB')).astype(np.int64)
    codes = rgb[:, :, 0] * 65536 + rgb[:, :, 1] * 256 + rgb[:, :, 2]
    return lookup[codes]


def main():
    lookup = colour_lookup(read_colours(os.path.join(RAW_DIR, 'class_dict.csv')))
    frames = list_frames()
    random.Random(SEED).shuffle(frames)

    n = len(frames)
    n_train = round(SPLIT['train'] * n)
    n_val = round(SPLIT['val'] * n)
    parts = {'train': frames[:n_train],
             'val': frames[n_train:n_train + n_val],
             'test': frames[n_train + n_val:]}

    counts = np.zeros(256, dtype=np.int64)
    for part, items in parts.items():
        os.makedirs(os.path.join(OUT_DIR, part, 'images'), exist_ok=True)
        os.makedirs(os.path.join(OUT_DIR, part, 'labels'), exist_ok=True)
        for image_path, label_path in items:
            name = os.path.basename(image_path)
            image = Image.open(image_path).convert('RGB').resize((WIDTH, HEIGHT), Image.BILINEAR)
            # nearest neighbour so no in-between class ids are invented
            label = Image.fromarray(convert_label(label_path, lookup)).resize((WIDTH, HEIGHT), Image.NEAREST)
            image.save(os.path.join(OUT_DIR, part, 'images', name))
            label.save(os.path.join(OUT_DIR, part, 'labels', name))
            counts += np.bincount(np.array(label).ravel(), minlength=256)
        print(f'{part}: {len(items)} frames')

    total = counts.sum()
    for class_id, name in enumerate(CLASS_NAMES):
        print(f'{name:12s} {100 * counts[class_id] / total:6.2f} %')
    print(f'{"ignored":12s} {100 * counts[IGNORE] / total:6.2f} %')


if __name__ == '__main__':
    main()
