import numpy as np
import os
from sklearn.datasets import fetch_openml
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler

data_dir = 'data'
test_dir = os.path.join(data_dir, "test_images_100")
os.makedirs(data_dir, exist_ok=True)
os.makedirs(test_dir, exist_ok=True)

X, y = fetch_openml('mnist_784', version=1, return_X_y=True, as_frame=False, parser='liac-arff')
scaler = StandardScaler()
X_train = X[:10000]
y_train = y[:10000]
X_scaled = scaler.fit_transform(X_train)

clf = LogisticRegression(max_iter=500, solver='saga', tol=0.1)
clf.fit(X_scaled, y_train)

SCALE = 4096 
SHIFT = 12
all_weights = clf.coef_
weights_fp = np.round(np.clip(all_weights, -7.9, 7.9) * SCALE).astype(np.int32)

with open(os.path.join(data_dir, "weights.mem"), "w") as f:
    count = 0
    for neuron_idx in range(10):
        for w in all_weights[neuron_idx]:
            q = int(round(np.clip(w, -7.9, 7.9) * SCALE))
            if q < 0: q = (1 << 16) + q 
            f.write(f"{q & 0xFFFF:04x}\n")
            count += 1
    for _ in range(8192 - count):
        f.write("0000\n")

expected_scores = []
with open(os.path.join(data_dir, "labels.mem"), "w") as f_labels:
    for idx in range(100):
        img_scaled = X_scaled[idx]
        f_labels.write(f"{int(y_train[idx]):x}\n")
        
        with open(os.path.join(test_dir, f"image_{idx}.mem"), "w") as f_img:
            for v in img_scaled:
                q = int(round(np.clip(v, -7.9, 7.9) * SCALE))
                if q < 0: q = (1 << 16) + q
                f_img.write(f"{q & 0xFFFF:04x}\n")
        
        img_fp = np.round(np.clip(img_scaled, -7.9, 7.9) * SCALE).astype(np.int32)
        row_scores = []
        for i in range(10):
            products = (img_fp.astype(np.int64) * weights_fp[i].astype(np.int64)) >> SHIFT
            score = np.sum(products)
            row_scores.append(int(score))
        expected_scores.append(row_scores)

with open(os.path.join(data_dir, "expected_scores.txt"), "w") as f_scores:
    for idx, scores in enumerate(expected_scores):
        scores_str = ",".join(map(str, scores))
        f_scores.write(f"{idx}:{scores_str}\n")