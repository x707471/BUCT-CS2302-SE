from flask import Blueprint, request
from services import browse_history_service
from utils.response import api_error

browse_history_bp = Blueprint("browse_history", __name__, url_prefix="/api/browse-history")


@browse_history_bp.route("/", methods=["GET"])
def get_browse_history():
    user_id = request.args.get("userId", type=int)
    if not user_id:
        return api_error("用户ID不能为空", 400)
    result = browse_history_service.get_user_browse_history(user_id)
    return result


@browse_history_bp.route("/add", methods=["POST"])
def add_browse_history():
    data = request.get_json()
    user_id = data.get("userId")
    artifact_id = data.get("artifactId")
    if not user_id or not artifact_id:
        return api_error("参数不完整", 400)
    result = browse_history_service.add_browse_history(user_id, artifact_id)
    return result.to_dict()


@browse_history_bp.route("/<int:history_id>", methods=["DELETE", "POST"])
def delete_browse_history(history_id):
    user_id = request.args.get("userId", type=int)
    if not user_id:
        return api_error("用户ID不能为空", 400)
    result = browse_history_service.delete_browse_history(history_id, user_id)
    if not result:
        return api_error("浏览记录不存在", 404)
    return {"success": True}


@browse_history_bp.route("/clear", methods=["DELETE", "POST"])
def clear_browse_history():
    user_id = request.args.get("userId", type=int)
    if not user_id:
        return api_error("用户ID不能为空", 400)
    browse_history_service.clear_browse_history(user_id)
    return {"success": True}
