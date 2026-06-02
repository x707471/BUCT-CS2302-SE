from flask import Blueprint, request
from services import comment_service
from utils.response import api_success, api_error

comment_bp = Blueprint("comment", __name__, url_prefix="/api/comments")


@comment_bp.route("/", methods=["GET"])
def get_comments():
    artifact_id = request.args.get("artifactId", type=int)
    user_id = request.args.get("userId", type=int)
    if artifact_id:
        if user_id:
            comments = comment_service.get_comments_with_user_pending(artifact_id, user_id)
        else:
            comments = comment_service.get_comments_by_artifact_id(artifact_id)
        return [c.to_dict() for c in comments]
    comments = comment_service.get_all_comments()
    return [c.to_dict() for c in comments]


@comment_bp.route("/", methods=["POST"])
def add_comment():
    data = request.get_json()
    user_id = data.get("userId")
    artifact_id = data.get("artifactId")
    content = data.get("content")
    parent_id = data.get("parentId")
    if not user_id or not artifact_id or not content:
        return api_error("参数不完整", 400)
    comment = comment_service.add_comment(user_id, artifact_id, content)
    if parent_id:
        comment.parent_id = parent_id
        from models import db
        db.session.commit()
    return comment.to_dict(), 201


@comment_bp.route("/<int:comment_id>/status", methods=["PUT"])
def update_review_status(comment_id):
    status = request.args.get("status")
    if not status:
        return api_error("状态不能为空", 400)
    result = comment_service.update_review_status(comment_id, status)
    if not result:
        return api_error("评论不存在", 404)
    return api_success(True, "评论状态更新成功")


@comment_bp.route("/<int:comment_id>", methods=["DELETE"])
def delete_comment(comment_id):
    result = comment_service.delete_comment(comment_id)
    if not result:
        return api_error("评论不存在", 404)
    return "", 204


@comment_bp.route("/<int:comment_id>", methods=["PUT"])
def update_comment(comment_id):
    data = request.get_json()
    content = data.get("content")
    if not content or not content.strip():
        return api_error("评论内容不能为空", 400)
    comment = comment_service.update_comment_content(comment_id, content.strip())
    if not comment:
        return api_error("评论不存在", 404)
    return comment.to_dict()


@comment_bp.route("/user/<int:user_id>", methods=["GET"])
def get_user_comments(user_id):
    result = comment_service.get_user_comments_with_artifact_info(user_id)
    return result
