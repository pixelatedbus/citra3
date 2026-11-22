# scores the fine-tuned model on the test split and writes the numbers next to the model
import os
import numpy as np
import torch
from camvid_classes import CLASS_NAMES
from deeplab import build_model, load_split, predict, confusion, scores

# project folder, three levels up from src/semantic/python/
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
TEST_DIR = os.path.join(ROOT, 'data', 'camvid', 'prepared', 'test')
MODEL_DIR = os.path.join(ROOT, 'models')
MODEL_FILE = os.path.join(MODEL_DIR, 'camvid_deeplabv3_mobilenet.pt')
BATCH = 8


def main():
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = build_model(len(CLASS_NAMES), pretrained=False)
    model.load_state_dict(torch.load(MODEL_FILE, map_location=device))
    model.to(device).eval()

    images, labels, _ = load_split(TEST_DIR)
    conf = np.zeros((len(CLASS_NAMES), len(CLASS_NAMES)), dtype=np.int64)
    for start in range(0, len(images), BATCH):
        pred = predict(model, images[start:start + BATCH], device)
        conf += confusion(pred, labels[start:start + BATCH], len(CLASS_NAMES))
    accuracy, class_accuracy, iou, miou = scores(conf)

    with open(os.path.join(MODEL_DIR, 'test_metrics.csv'), 'w') as f:
        f.write('class,accuracy,iou\n')
        for name, acc, value in zip(CLASS_NAMES, class_accuracy, iou):
            f.write(f'{name},{acc:.4f},{value:.4f}\n')
        f.write(f'mean,{class_accuracy.mean():.4f},{miou:.4f}\n')
        f.write(f'global,{accuracy:.4f},\n')

    # rows = true class, columns = predicted class, in pixels
    with open(os.path.join(MODEL_DIR, 'test_confusion.csv'), 'w') as f:
        f.write('truth/pred,' + ','.join(CLASS_NAMES) + '\n')
        for name, row in zip(CLASS_NAMES, conf):
            f.write(name + ',' + ','.join(str(v) for v in row) + '\n')

    print(f'test frames: {len(images)}')
    for name, acc, value in zip(CLASS_NAMES, class_accuracy, iou):
        print(f'{name:12s} acc {100 * acc:5.1f} %  IoU {100 * value:5.1f} %')
    print(f'global accuracy {100 * accuracy:.1f} %, mean class accuracy {100 * class_accuracy.mean():.1f} %, mIoU {100 * miou:.1f} %')


if __name__ == '__main__':
    main()
