from flask import Blueprint, request
from services import user_service

user_bp = Blueprint("user", __name__, url_prefix="/api/user")


@user_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")
    email = data.get("email")
    phone = data.get("phone")
    nickname = data.get("nickname")
    if not username or not password:
        from utils.response import api_error
        return api_error("用户名和密码不能为空", 400)
    return user_service.register(username, password, email, phone, nickname)


@user_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")
    if not username or not password:
        from utils.response import api_error
        return api_error("用户名和密码不能为空", 400)
    return user_service.login(username, password)


@user_bp.route("/info/<int:user_id>", methods=["GET"])
def get_user_info(user_id):
    return user_service.get_user_info(user_id)


@user_bp.route("/update", methods=["PUT"])
def update_user():
    data = request.get_json()
    user_id = data.get("userId")
    if not user_id:
        from utils.response import api_error
        return api_error("用户ID不能为空", 400)
    return user_service.update_user(
        user_id,
        username=data.get("username"),
        email=data.get("email"),
        password=data.get("password"),
        phone=data.get("phone"),
        nickname=data.get("nickname"),
        avatar_url=data.get("avatarUrl"),
    )


@user_bp.route("/delete/<int:user_id>", methods=["DELETE"])
def delete_user(user_id):
    return user_service.delete_user(user_id)
