import numpy as np
import matplotlib.pyplot as plt
import os
from sklearn.datasets import fetch_openml

def load_scores(file_path):
    scores = []
    indices = []
    with open(file_path, 'r') as f:
        for line in f:
            idx, vals = line.strip().split(':')
            indices.append(int(idx))
            scores.append([int(v) for v in vals.split(',')])
    return np.array(indices), np.array(scores)

def load_labels(file_path):
    with open(file_path, 'r') as f:
        return np.array([int(line.strip(), 16) for line in f])

data_dir = 'data'
img_out_dir = 'images'
os.makedirs(img_out_dir, exist_ok=True)

exp_idx, exp_scores = load_scores(os.path.join(data_dir, "expected_scores.txt"))
hw_idx, hw_scores = load_scores(os.path.join(data_dir, "hardware_scores.txt"))
true_labels = load_labels(os.path.join(data_dir, "labels.mem"))

exp_preds = np.argmax(exp_scores, axis=1)
hw_preds = np.argmax(hw_scores, axis=1)

X, _ = fetch_openml('mnist_784', version=1, return_X_y=True, as_frame=False, parser='liac-arff')
X_test = X[:100]

for i in range(0, 100, 10):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))
    
    ax1.imshow(X_test[i].reshape(28, 28), cmap='gray')
    ax1.set_title(f"Image Index: {i}\nTrue Label: {true_labels[i]}")
    ax1.axis('off')
    
    x = np.arange(10)
    width = 0.35
    ax2.bar(x - width/2, exp_scores[i], width, label='Golden Ref', color='skyblue')
    ax2.bar(x + width/2, hw_scores[i], width, label='Hardware', color='orange', alpha=0.7)
    
    ax2.set_xlabel('Digit (Neuron Index)')
    ax2.set_ylabel('Score Value')
    ax2.set_title(f"Golden Pred: {exp_preds[i]} | HW Pred: {hw_preds[i]}")
    ax2.set_xticks(x)
    ax2.legend()
    ax2.grid(axis='y', linestyle='--', alpha=0.6)
    
    status = "MATCH" if exp_preds[i] == hw_preds[i] else "MISMATCH"
    plt.suptitle(f"Sample {i}: {status}", fontsize=16)
    
    plt.tight_layout()
    plt.savefig(os.path.join(img_out_dir, f'sample_{i}_comparison.png'))
    plt.show()

print(f"Comparison images saved in '{img_out_dir}/'")