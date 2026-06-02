from flask import Blueprint, request
from services import like_service
from utils.response import api_error

like_bp = Blueprint("like", __name__, url_prefix="/api")


@like_bp.route("/user/likes", methods=["GET"])
def get_user_likes():
    user_id = request.args.get("userId", type=int, default=1)
    artifacts = like_service.get_liked_artifacts(user_id)
    return [a.to_dict() for a in artifacts]


@like_bp.route("/like/add", methods=["POST"])
def add_like():
    data = request.get_json()
    artifact_id = data.get("artifactId")
    user_id = data.get("userId", 1)
    if not artifact_id:
        return api_error("文物ID不能为空", 400)
    result = like_service.add_like(user_id, artifact_id)
    if not result:
        return api_error("已点赞过该文物", 400)
    return {"success": True}


@like_bp.route("/like/remove", methods=["POST"])
def remove_like():
    data = request.get_json()
    artifact_id = data.get("artifactId")
    user_id = data.get("userId", 1)
    if not artifact_id:
        return api_error("文物ID不能为空", 400)
    result = like_service.remove_like(user_id, artifact_id)
    if not result:
        return api_error("取消点赞失败", 400)
    return {"success": True}


@like_bp.route("/like/check", methods=["GET"])
def check_like():
    artifact_id = request.args.get("artifactId", type=int)
    user_id = request.args.get("userId", type=int, default=1)
    if not artifact_id:
        return api_error("文物ID不能为空", 400)
    has_liked = like_service.has_liked(user_id, artifact_id)
    return {"liked": has_liked}


@like_bp.route("/artifacts/likes/<int:artifact_id>", methods=["GET"])
def get_artifact_likes(artifact_id):
    count = like_service.get_likes_count(artifact_id)
    return {"likes": count}
