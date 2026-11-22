# fine-tunes the pretrained DeepLabV3 on the CamVid train split, keeps the best model on the val split
import os
import sys
import time
import numpy as np
import torch
from camvid_classes import CLASS_NAMES, IGNORE
from deeplab import build_model, to_input, load_split, predict, confusion, scores

# project folder, three levels up from src/semantic/python/
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
DATA_DIR = os.path.join(ROOT, 'data', 'camvid', 'prepared')
MODEL_DIR = os.path.join(ROOT, 'models')
MODEL_FILE = os.path.join(MODEL_DIR, 'camvid_deeplabv3_mobilenet.pt')
LOG_FILE = os.path.join(MODEL_DIR, 'train_log.csv')

EPOCHS = 60
BATCH = 8
CROP = 320            # random square crop in pixels, the frames are 360 x 480
LEARNING_RATE = 5e-4
SEED = 0


def class_weights(labels, num_classes):
    # labels: uint8 array N x H x W
    # num_classes: int
    # returns: float array num_classes, median frequency balancing:
    # freq(c) = pixels of c / pixels of the images that contain c, weight(c) = median(freq) / freq(c)
    pixels = np.zeros(num_classes)
    image_pixels = np.zeros(num_classes)
    for label in labels:
        count = np.bincount(label.ravel(), minlength=256)[:num_classes]
        pixels += count
        image_pixels += (count > 0) * label.size
    freq = pixels / image_pixels
    return np.median(freq) / freq


def random_batch(images, labels, index, device):
    # images: uint8 N x H x W x 3, labels: uint8 N x H x W
    # index: int array, which frames go into this batch
    # returns: input tensor B x 3 x CROP x CROP, target tensor B x CROP x CROP (long)
    rows, cols = labels.shape[1], labels.shape[2]
    top = np.random.randint(0, rows - CROP + 1)
    left = np.random.randint(0, cols - CROP + 1)
    x = images[index, top:top + CROP, left:left + CROP]
    y = labels[index, top:top + CROP, left:left + CROP]
    # half of the batches are mirrored left-right
    if np.random.rand() < 0.5:
        x = x[:, :, ::-1]
        y = y[:, :, ::-1]
    x = to_input(np.ascontiguousarray(x), device)
    y = torch.from_numpy(np.ascontiguousarray(y)).to(device).long()
    return x, y


def evaluate(model, images, labels, device):
    # returns: global accuracy, mean IoU on the given frames
    model.eval()
    conf = np.zeros((len(CLASS_NAMES), len(CLASS_NAMES)), dtype=np.int64)
    for start in range(0, len(images), BATCH):
        pred = predict(model, images[start:start + BATCH], device)
        conf += confusion(pred, labels[start:start + BATCH], len(CLASS_NAMES))
    accuracy, _, _, miou = scores(conf)
    return accuracy, miou


def main():
    epochs = int(sys.argv[1]) if len(sys.argv) > 1 else EPOCHS
    np.random.seed(SEED)
    torch.manual_seed(SEED)
    device = torch.device('cuda')
    os.makedirs(MODEL_DIR, exist_ok=True)

    train_images, train_labels, _ = load_split(os.path.join(DATA_DIR, 'train'))
    val_images, val_labels, _ = load_split(os.path.join(DATA_DIR, 'val'))
    weights = class_weights(train_labels, len(CLASS_NAMES))
    print('class weights:', ' '.join(f'{n}={w:.2f}' for n, w in zip(CLASS_NAMES, weights)))

    model = build_model(len(CLASS_NAMES), pretrained=True).to(device)
    loss_fn = torch.nn.CrossEntropyLoss(weight=torch.tensor(weights, dtype=torch.float32, device=device),
                                        ignore_index=IGNORE)
    optimizer = torch.optim.AdamW(model.parameters(), lr=LEARNING_RATE)
    schedule = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, epochs)
    scaler = torch.amp.GradScaler('cuda')

    best = -1
    with open(LOG_FILE, 'w') as log:
        log.write('epoch,train_loss,val_accuracy,val_miou,seconds\n')
        for epoch in range(1, epochs + 1):
            start = time.time()
            model.train()
            order = np.random.permutation(len(train_images))
            losses = []
            for b in range(0, len(order) - BATCH + 1, BATCH):
                x, y = random_batch(train_images, train_labels, order[b:b + BATCH], device)
                # half precision for speed and memory, the scaler keeps small gradients from vanishing
                with torch.autocast('cuda', dtype=torch.float16):
                    loss = loss_fn(model(x)['out'], y)
                optimizer.zero_grad()
                scaler.scale(loss).backward()
                scaler.step(optimizer)
                scaler.update()
                losses.append(loss.item())
            schedule.step()

            accuracy, miou = evaluate(model, val_images, val_labels, device)
            seconds = time.time() - start
            log.write(f'{epoch},{np.mean(losses):.4f},{accuracy:.4f},{miou:.4f},{seconds:.1f}\n')
            log.flush()
            marker = ''
            if miou > best:
                best = miou
                torch.save(model.state_dict(), MODEL_FILE)
                marker = ' (saved)'
            print(f'epoch {epoch:3d}  loss {np.mean(losses):.3f}  val acc {accuracy:.3f}  val mIoU {miou:.3f}  {seconds:.0f} s{marker}', flush=True)


if __name__ == '__main__':
    main()
