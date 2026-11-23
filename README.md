# Segmentasi Citra

Aplikasi GUI MATLAB untuk Tugas 3 IF4073 Pemrosesan Citra Digital (ITB, 2026/2027). Satu jendela dengan tiga
tab, masing-masing satu pendekatan segmentasi.

| Bagian | Isi |
|---|---|
| B | Segmentasi objek dari hasil deteksi tepi: Sobel, Prewitt, Roberts, Laplace, LoG (dibuat sendiri) dan Canny (bawaan MATLAB), lalu morfologi |
| C | *Split and merge*: pembagian *quadtree* dengan predikat homogenitas RGB, lalu penggabungan region bertetangga yang warnanya mirip |
| D | Segmentasi semantik: DeepLabV3-MobileNetV3 (*pretrained* COCO/VOC) yang di-*fine-tune* pada CamVid dengan 11 kelas |

## Anggota

| Nama | NIM |
|---|---|
| David Bakti Lodianto| 13523083 |
| Lutfi Hakim Yusra | 13523084 |


## Kebutuhan

- MATLAB R2026a dengan Image Processing Toolbox
- Untuk bagian D: Python 3.11 dan virtual environment `.venv/` di folder proyek, berisi `torch`, `torchvision`,
  `numpy`, `pillow` (versi di `src/semantic/python/requirements.txt`). GPU NVIDIA hanya diperlukan untuk pelatihan;
  prediksi di GUI juga jalan di CPU.

```
py -3.11 -m venv .venv
.venv\Scripts\python -m pip install torch==2.14.1 --index-url https://download.pytorch.org/whl/cu126
.venv\Scripts\python -m pip install -r src\semantic\python\requirements.txt
```

Model hasil *fine-tuning* sudah ada di `src/semantic/models/camvid_deeplabv3_mobilenet.pt`. Panel "before fine-tuning" di tab D
mengunduh bobot asli torchvision (sekitar 42 MB) satu kali saat pertama dipakai.

## Data

- **BSDS500 (bagian B dan C):** ekstrak `BSDS500_Tugas3_Test_8.zip` ke `data/` sehingga citra ada di `data/bsds500_test_8/`.
- **CamVid (bagian D):** sumber asli
  [citra](http://web4.cs.ucl.ac.uk/staff/g.brostow/MotionSegRecData/files/701_StillsRaw_full.zip) dan
  [label](http://web4.cs.ucl.ac.uk/staff/g.brostow/MotionSegRecData/data/LabeledApproved_full.zip).
  Kami memakai salinannya di Kaggle ([carlolepelaars/camvid](https://www.kaggle.com/datasets/carlolepelaars/camvid)),
  isinya 701 citra dan label yang sama ditambah `class_dict.csv`. Ekstrak ke `data/camvid/` sehingga ada
  `data/camvid/CamVid/train/`, `train_labels/`, ..., `class_dict.csv`, lalu siapkan datanya:

  ```
  .venv\Scripts\python src\semantic\python\prepare_camvid.py
  ```

  Skrip ini mengelompokkan 32 kelas menjadi 11, mengubah ukuran ke 360x480, dan membagi data secara acak
  60/20/20 (421/140/140 citra) ke `data/camvid/prepared/`. Citra uji di sana muncul di daftar tab D.

## Cara menjalankan

Dari folder proyek:

```
matlab -r "main"
```

Pilih tab, pilih citra dari daftar (atau **Browse...**), atur parameter, lalu tekan **Run**.
**Save screenshot...** menyimpan tampilan jendela beserta parameternya ke `results/`.

Melatih ulang dan menguji model bagian D (butuh GPU, sekitar 17 menit di RTX 4050):

```
.venv\Scripts\python src\semantic\python\train.py
.venv\Scripts\python src\semantic\python\evaluate.py
```

## Struktur

```
main.m                 membuka aplikasi
src/gui/               jendela dan tab B, C, D
src/edgeseg/           operator deteksi tepi dan segmentasi objek
src/splitmerge/        split and merge
src/semantic/          pemanggilan model dari MATLAB, kelas CamVid
src/semantic/python/   persiapan data, pelatihan, evaluasi, dan prediksi (PyTorch)
src/semantic/models/   model hasil fine-tuning, log pelatihan, metrik uji
src/utils/             baca citra, konvolusi, kernel Gaussian
```
