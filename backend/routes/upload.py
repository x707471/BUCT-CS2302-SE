import os
import uuid
from flask import Blueprint, request, jsonify
from services import upload_service
from utils.response import api_error

upload_bp = Blueprint("upload", __name__, url_prefix="/api/uploads")

UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.dirname(__file__)), "static", "uploads")
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif", "mp4", "mp3", "wav"}


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


@upload_bp.route("/add", methods=["POST"])
def add_upload():
    user_id = request.form.get("userId", type=int)
    artifact_id = request.form.get("artifactId", type=int)
    media_type = request.form.get("mediaType", "image")
    caption = request.form.get("caption", "")
    description = request.form.get("description", "")

    if not user_id:
        return api_error("用户ID不能为空", 400)

    file = request.files.get("file")
    if not file:
        return api_error("请选择文件", 400)

    if not allowed_file(file.filename):
        return api_error("不支持的文件格式", 400)

    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    ext = file.filename.rsplit(".", 1)[1].lower()
    filename = f"{uuid.uuid4().hex}.{ext}"
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)

    file_url = f"/static/uploads/{filename}"
    result = upload_service.add_upload(user_id, artifact_id, media_type, file_url, filepath, caption, description)
    return result.to_dict()


@upload_bp.route("/user/<int:user_id>", methods=["GET"])
def get_user_uploads(user_id):
    uploads = upload_service.get_user_uploads(user_id)
    return [u.to_dict() for u in uploads]


@upload_bp.route("/artifact/<int:artifact_id>", methods=["GET"])
def get_artifact_uploads(artifact_id):
    status = request.args.get("status", "approved")
    uploads = upload_service.get_artifact_uploads(artifact_id, status)
    return [u.to_dict() for u in uploads]
