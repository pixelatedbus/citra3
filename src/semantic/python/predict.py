# labels one image with the fine-tuned model, called by the MATLAB GUI
# usage: python predict.py <input image> <output label png> [<output png before fine-tuning>]
# output: same size as the input, pixel value 1..11 = class (see camvid_classes.py)
# optional third output: the downloaded model before fine-tuning, pixel value 1..21 = VOC class (1 = background)
import os
import sys
import numpy as np
import torch
from PIL import Image
from camvid_classes import CLASS_NAMES
from deeplab import build_model, build_voc_model, predict

# project folder, three levels up from src/semantic/python/
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
MODEL_FILE = os.path.join(ROOT, 'src', 'semantic', 'models', 'camvid_deeplabv3_mobilenet.pt')
WIDTH, HEIGHT = 480, 360   # size the model was trained on


def save_labels(label, size, path):
    # label: uint8 array HEIGHT x WIDTH, class ids from 0
    # size: (width, height) of the input image
    # path: str, output PNG
    # back to the input size, nearest neighbour so class ids stay whole; +1 so MATLAB gets labels from 1
    Image.fromarray(label + 1).resize(size, Image.NEAREST).save(path)


def main():
    in_path, out_path = sys.argv[1], sys.argv[2]
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    image = Image.open(in_path).convert('RGB')
    small = np.array(image.resize((WIDTH, HEIGHT), Image.BILINEAR))[np.newaxis]

    model = build_model(len(CLASS_NAMES), pretrained=False)
    model.load_state_dict(torch.load(MODEL_FILE, map_location=device))
    model.to(device).eval()
    save_labels(predict(model, small, device)[0], image.size, out_path)

    if len(sys.argv) > 3:
        before = build_voc_model().to(device).eval()
        save_labels(predict(before, small, device)[0], image.size, sys.argv[3])


if __name__ == '__main__':
    main()
