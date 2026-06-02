import os
import numpy as np
from PIL import Image
import torch
import torchvision.models as models
import torchvision.transforms as transforms
from models import db, Artifact

BASE_DIR = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
IMAGE_DIR = os.path.join(BASE_DIR, "static", "images")
FEATURE_CACHE_PATH = os.path.join(BASE_DIR, "feature_cache")

FEATURE_DIM = 2048

_transform = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225]),
])

_model = None
_feature_matrix = None
_artifact_ids = None


def _get_model():
    global _model
    if _model is None:
        resnet = models.resnet50(weights=models.ResNet50_Weights.DEFAULT)
        _model = torch.nn.Sequential(*list(resnet.children())[:-1])
        _model.eval()
        for param in _model.parameters():
            param.requires_grad = False
    return _model


def extract_feature(image_input):
    model = _get_model()
    if isinstance(image_input, str):
        img = Image.open(image_input).convert("RGB")
    else:
        img = image_input.convert("RGB")

    tensor = _transform(img).unsqueeze(0)
    with torch.no_grad():
        feature = model(tensor)
    feature_vector = feature.squeeze().numpy()
    norm = np.linalg.norm(feature_vector)
    if norm > 0:
        feature_vector = feature_vector / norm
    return feature_vector


def _get_artifact_image_path(artifact):
    if artifact.image_path:
        full_path = os.path.join(BASE_DIR, artifact.image_path.lstrip("/"))
        if os.path.exists(full_path):
            return full_path

    if artifact.image_url:
        url = artifact.image_url
        if url.startswith("/static/"):
            full_path = os.path.join(BASE_DIR, url.lstrip("/"))
            if os.path.exists(full_path):
                return full_path

    filename = f"artifact_{artifact.id}.jpg"
    candidate = os.path.join(IMAGE_DIR, filename)
    if os.path.exists(candidate):
        return candidate

    return None


def build_feature_index():
    global _feature_matrix, _artifact_ids

    os.makedirs(FEATURE_CACHE_PATH, exist_ok=True)

    artifacts = Artifact.query.all()
    features = []
    ids = []

    for artifact in artifacts:
        img_path = _get_artifact_image_path(artifact)
        if not img_path:
            continue

        cache_file = os.path.join(FEATURE_CACHE_PATH, f"artifact_{artifact.id}.npy")
        if os.path.exists(cache_file):
            try:
                feature_vector = np.load(cache_file)
            except Exception:
                feature_vector = extract_feature(img_path)
                np.save(cache_file, feature_vector)
        else:
            feature_vector = extract_feature(img_path)
            np.save(cache_file, feature_vector)

        features.append(feature_vector)
        ids.append(artifact.id)

    if features:
        _feature_matrix = np.stack(features)
        index_cache = os.path.join(FEATURE_CACHE_PATH, "index.npz")
        np.savez(index_cache, ids=np.array(ids), features=_feature_matrix)
    else:
        _feature_matrix = np.array([]).reshape(0, FEATURE_DIM)

    _artifact_ids = ids
    return len(ids)


def load_feature_index():
    global _feature_matrix, _artifact_ids

    index_cache = os.path.join(FEATURE_CACHE_PATH, "index.npz")
    if os.path.exists(index_cache):
        try:
            data = np.load(index_cache, allow_pickle=True)
            _artifact_ids = data["ids"].tolist()
            _feature_matrix = data["features"]
            return len(_artifact_ids)
        except Exception:
            pass

    return build_feature_index()


def search_by_feature(query_feature, top_k=10, threshold=0.3):
    if _feature_matrix is None or len(_feature_matrix) == 0:
        return []

    similarities = np.dot(_feature_matrix, query_feature)

    results = []
    for i, sim in enumerate(similarities):
        if sim >= threshold:
            results.append((_artifact_ids[i], float(sim)))

    results.sort(key=lambda x: x[1], reverse=True)
    results = results[:top_k]

    artifact_results = []
    for artifact_id, similarity in results:
        artifact = Artifact.query.get(artifact_id)
        if artifact:
            artifact_dict = artifact.to_dict()
            artifact_dict["similarity"] = round(similarity, 4)
            artifact_results.append(artifact_dict)

    return artifact_results


def search_by_image(image_input, top_k=10, threshold=0.3):
    feature_vector = extract_feature(image_input)
    return search_by_feature(feature_vector, top_k, threshold)
