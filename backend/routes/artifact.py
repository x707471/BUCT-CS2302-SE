from flask import Blueprint, request
from services import artifact_service
from utils.response import api_success, api_error

artifact_bp = Blueprint("artifact", __name__, url_prefix="/api/artifacts")


@artifact_bp.route("/", methods=["GET"])
def get_all_artifacts():
    page = request.args.get("page", 1, type=int)
    page_size = request.args.get("pageSize", 20, type=int)
    sort = request.args.get("sort", "default")
    artifacts = artifact_service.get_all_artifacts(page, page_size, sort)
    return [a.to_dict() for a in artifacts]


@artifact_bp.route("/<int:artifact_id>", methods=["GET"])
def get_artifact_by_id(artifact_id):
    artifact = artifact_service.get_artifact_by_id(artifact_id)
    if not artifact:
        return api_error("文物不存在", 404)
    result = artifact.to_dict()
    museum = artifact_service.get_museum_by_id(artifact.museum_id)
    if museum:
        result["museumName"] = museum.name
    likes_count = artifact_service.get_likes_count(artifact_id)
    result["likesCount"] = likes_count
    return result


@artifact_bp.route("/search", methods=["GET"])
def search_artifacts():
    keyword = request.args.get("keyword", "") or request.args.get("name", "")
    artifacts = artifact_service.search_artifacts(keyword)
    return [a.to_dict() for a in artifacts]


@artifact_bp.route("/advanced-search", methods=["POST"])
def advanced_search():
    data = request.get_json() or {}
    keyword = data.get("keyword", "")
    era = data.get("era", "")
    artifact_type = data.get("type", "")
    museum = data.get("museum", "")
    material = data.get("material", "")
    sort = data.get("sort", "default")
    page = data.get("page", 1)
    page_size = data.get("pageSize", 20)
    artifacts = artifact_service.advanced_search(keyword, era, artifact_type, museum, material, sort, page, page_size)
    return [a.to_dict() for a in artifacts]


@artifact_bp.route("/era/<era>", methods=["GET"])
def get_artifacts_by_era(era):
    artifacts = artifact_service.get_artifacts_by_era(era)
    return [a.to_dict() for a in artifacts]


@artifact_bp.route("/type/<artifact_type>", methods=["GET"])
def get_artifacts_by_type(artifact_type):
    artifacts = artifact_service.get_artifacts_by_type(artifact_type)
    return [a.to_dict() for a in artifacts]


@artifact_bp.route("/museum/<museum_name>", methods=["GET"])
def get_artifacts_by_museum(museum_name):
    artifacts = artifact_service.get_artifacts_by_museum_name(museum_name)
    return [a.to_dict() for a in artifacts]


@artifact_bp.route("/museum_id/<int:museum_id>", methods=["GET"])
def get_artifacts_by_museum_id(museum_id):
    artifacts = artifact_service.get_artifacts_by_museum(museum_id)
    return [a.to_dict() for a in artifacts]


@artifact_bp.route("/dynasty/<int:dynasty_id>", methods=["GET"])
def get_artifacts_by_dynasty(dynasty_id):
    artifacts = artifact_service.get_artifacts_by_dynasty(dynasty_id)
    return [a.to_dict() for a in artifacts]


@artifact_bp.route("/likes/<int:artifact_id>", methods=["GET"])
def get_artifact_likes(artifact_id):
    count = artifact_service.get_likes_count(artifact_id)
    return {"likes": count}


@artifact_bp.route("/hot", methods=["GET"])
def get_hot_artifacts():
    limit = request.args.get("limit", 20, type=int)
    artifacts = artifact_service.get_hot_artifacts(limit)
    return [a.to_dict() for a in artifacts]
