from flask import Blueprint, request
from services import collection_service
from utils.response import api_error

collection_bp = Blueprint("collection", __name__, url_prefix="/api")


@collection_bp.route("/user/collections", methods=["GET"])
def get_user_collections():
    user_id = request.args.get("userId", type=int)
    if not user_id:
        return api_error("用户ID不能为空", 400)
    artifacts = collection_service.get_user_collections(user_id)
    return artifacts


@collection_bp.route("/collection/groups/<int:user_id>", methods=["GET"])
def get_collection_groups(user_id):
    groups = collection_service.get_collection_groups(user_id)
    return groups


@collection_bp.route("/collection/group-detail", methods=["GET"])
def get_collection_by_group():
    user_id = request.args.get("userId", type=int)
    group_name = request.args.get("groupName", "")
    if not user_id:
        return api_error("用户ID不能为空", 400)
    artifacts = collection_service.get_collection_by_group(user_id, group_name)
    return artifacts


@collection_bp.route("/collection/add", methods=["POST"])
def add_collection():
    data = request.get_json()
    user_id = data.get("userId")
    artifact_id = data.get("artifactId")
    group_name = data.get("groupName")
    if not user_id or not artifact_id:
        return api_error("参数不完整", 400)
    result = collection_service.add_collection(user_id, artifact_id, group_name)
    if result is None:
        return api_error("已收藏过该文物", 400)
    return result.to_dict()


@collection_bp.route("/collection/remove", methods=["POST"])
def remove_collection():
    data = request.get_json()
    user_id = data.get("userId")
    artifact_id = data.get("artifactId")
    if not user_id or not artifact_id:
        return api_error("参数不完整", 400)
    result = collection_service.remove_collection(user_id, artifact_id)
    if not result:
        return api_error("取消收藏失败", 400)
    return {"success": True}


@collection_bp.route("/collection/check", methods=["GET"])
def check_collection():
    artifact_id = request.args.get("artifactId", type=int)
    user_id = request.args.get("userId", type=int)
    if not artifact_id:
        return api_error("文物ID不能为空", 400)
    is_collected = collection_service.is_collected(user_id, artifact_id)
    return {"collected": is_collected}
