import os
import numpy as np
import torch
from PIL import Image
from torchvision.models.segmentation import deeplabv3_mobilenet_v3_large, DeepLabV3_MobileNet_V3_Large_Weights

# imagenet mean and std, the backbone was trained on images normalised this way
MEAN = torch.tensor([0.485, 0.456, 0.406]).view(1, 3, 1, 1)
STD = torch.tensor([0.229, 0.224, 0.225]).view(1, 3, 1, 1)


def build_model(num_classes, pretrained):
    # num_classes: int, number of output classes
    # pretrained: bool, True starts from the COCO (21 VOC classes) weights
    # returns: torchvision DeepLabV3 with a new last layer of num_classes outputs
    weights = DeepLabV3_MobileNet_V3_Large_Weights.DEFAULT if pretrained else None
    model = deeplabv3_mobilenet_v3_large(weights=weights, weights_backbone=None)
    model.classifier[4] = torch.nn.Conv2d(256, num_classes, kernel_size=1)
    model.aux_classifier = None
    return model


def build_voc_model():
    # returns: the downloaded DeepLabV3 as it is, before fine-tuning (21 VOC classes, 0 = background)
    weights = DeepLabV3_MobileNet_V3_Large_Weights.DEFAULT
    model = deeplabv3_mobilenet_v3_large(weights=weights, weights_backbone=None)
    model.aux_classifier = None
    return model


def to_input(images, device):
    # images: uint8 array N x H x W x 3
    # device: torch.device
    # returns: float tensor N x 3 x H x W, normalised
    x = torch.from_numpy(images).to(device).permute(0, 3, 1, 2).float() / 255
    return (x - MEAN.to(device)) / STD.to(device)


def load_split(folder):
    # folder: str, e.g. data/camvid/prepared/train (holds images/ and labels/)
    # returns: uint8 array N x H x W x 3 (images), uint8 array N x H x W (labels), list of file names
    names = sorted(os.listdir(os.path.join(folder, 'images')))
    images = np.stack([np.array(Image.open(os.path.join(folder, 'images', n)).convert('RGB')) for n in names])
    labels = np.stack([np.array(Image.open(os.path.join(folder, 'labels', n))) for n in names])
    return images, labels, names


def predict(model, images, device):
    # model: network from build_model, in eval mode
    # images: uint8 array N x H x W x 3
    # device: torch.device
    # returns: uint8 array N x H x W, class id with the highest score per pixel
    with torch.no_grad():
        scores = model(to_input(images, device))['out']
    return scores.argmax(1).byte().cpu().numpy()


def confusion(pred, truth, num_classes):
    # pred, truth: uint8 arrays of the same shape, truth may hold 255 (ignored)
    # num_classes: int
    # returns: int64 array num_classes x num_classes, rows = truth, columns = prediction
    keep = truth < num_classes
    index = truth[keep].astype(np.int64) * num_classes + pred[keep]
    return np.bincount(index, minlength=num_classes ** 2).reshape(num_classes, num_classes)


def scores(conf):
    # conf: int64 array K x K from confusion
    # returns: global pixel accuracy, per-class accuracy (K), per-class IoU (K), mean IoU
    hit = np.diag(conf).astype(np.float64)
    truth_count = conf.sum(1)
    pred_count = conf.sum(0)
    accuracy = hit.sum() / conf.sum()
    class_accuracy = hit / np.maximum(truth_count, 1)
    iou = hit / np.maximum(truth_count + pred_count - hit, 1)
    return accuracy, class_accuracy, iou, iou.mean()
