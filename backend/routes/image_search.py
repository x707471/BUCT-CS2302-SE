import os
import uuid
from flask import Blueprint, request
from PIL import Image
from services import image_search_service
from utils.response import api_success, api_error

image_search_bp = Blueprint("image_search", __name__, url_prefix="/api")

UPLOAD_TEMP_DIR = os.path.join(os.path.abspath(os.path.dirname(os.path.dirname(__file__))), "temp_uploads")
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "bmp", "webp"}


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


@image_search_bp.route("/artifacts/search/image", methods=["POST"])
def search_by_image():
    print(f"[ImageSearch] request.files: {list(request.files.keys())}")
    print(f"[ImageSearch] request.form: {dict(request.form)}")
    print(f"[ImageSearch] request.content_type: {request.content_type}")
    file = request.files.get("file")
    if not file:
        print("[ImageSearch] ERROR: no file received!")
        return api_error("请上传图片文件", 400)

    if not allowed_file(file.filename):
        return api_error("不支持的图片格式，仅支持 jpg/png/jpeg/bmp/webp", 400)

    os.makedirs(UPLOAD_TEMP_DIR, exist_ok=True)
    ext = file.filename.rsplit(".", 1)[1].lower()
    temp_filename = f"search_{uuid.uuid4().hex}.{ext}"
    temp_path = os.path.join(UPLOAD_TEMP_DIR, temp_filename)

    try:
        file.save(temp_path)
        print(f"[ImageSearch] file saved to {temp_path}, size={os.path.getsize(temp_path)}")

        try:
            img = Image.open(temp_path)
            img.verify()
        except Exception:
            return api_error("上传的文件不是有效图片", 400)

        top_k = request.form.get("topK", 10, type=int)
        threshold = request.form.get("threshold", 0.3, type=float)

        print(f"[ImageSearch] searching: top_k={top_k}, threshold={threshold}")
        results = image_search_service.search_by_image(temp_path, top_k=top_k, threshold=threshold)
        print(f"[ImageSearch] found {len(results)} results")

        return api_success(results, "搜索完成")
    except Exception as e:
        print(f"[ImageSearch] ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return api_error(f"图像搜索失败: {str(e)}", 500)
    finally:
        if os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except Exception:
                pass


@image_search_bp.route("/artifacts/search/image/rebuild", methods=["POST"])
def rebuild_index():
    try:
        count = image_search_service.build_feature_index()
        return api_success({"indexedCount": count}, "特征索引重建完成")
    except Exception as e:
        return api_error(f"索引重建失败: {str(e)}", 500)


@image_search_bp.route("/health", methods=["GET"])
def health_check():
    return {"status": "ok"}
