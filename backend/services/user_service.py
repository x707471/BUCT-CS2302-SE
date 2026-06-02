from datetime import datetime
import bcrypt
from models import db, User
from utils.response import api_success, api_error


PALM_MUSEUM_USER_TYPE = "mobile_app"


def register(username, password, email=None, phone=None, nickname=None):
    existing = User.query.filter_by(username=username, user_type=PALM_MUSEUM_USER_TYPE).first()
    if existing:
        return api_error("用户名已存在", 400)
    hashed = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    user = User(
        username=username,
        password_hash=hashed,
        email=email,
        phone=phone,
        nickname=nickname or username,
        user_type=PALM_MUSEUM_USER_TYPE,
        source="mobile_app",
    )
    db.session.add(user)
    db.session.commit()
    return api_success(user.to_dict(), "注册成功", 200)


def login(username, password):
    user = User.query.filter_by(username=username, user_type=PALM_MUSEUM_USER_TYPE).first()
    if not user:
        return api_error("用户名不存在", 404)
    try:
        if bcrypt.checkpw(password.encode("utf-8"), user.password_hash.encode("utf-8")):
            user.last_login = datetime.now()
            db.session.commit()
            return api_success(user.to_dict(), "登录成功", 200)
    except Exception:
        pass
    return api_error("密码错误", 401)


def get_user_info(user_id):
    user = User.query.get(user_id)
    if not user:
        return api_error("用户不存在", 404)
    return api_success(user.to_dict())


def update_user(user_id, username=None, email=None, password=None, phone=None, nickname=None, avatar_url=None):
    user = User.query.get(user_id)
    if not user:
        return api_error("用户不存在", 404)
    if username:
        existing = User.query.filter(User.username == username, User.user_type == PALM_MUSEUM_USER_TYPE, User.id != user_id).first()
        if existing:
            return api_error("用户名已存在", 400)
        user.username = username
    if email:
        user.email = email
    if password:
        user.password_hash = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    if phone:
        user.phone = phone
    if nickname:
        user.nickname = nickname
    if avatar_url:
        user.avatar_url = avatar_url
    db.session.commit()
    return api_success(user.to_dict(), "更新成功")


def delete_user(user_id):
    user = User.query.get(user_id)
    if not user:
        return api_error("用户不存在", 404)
    user.status = "disabled"
    db.session.commit()
    return api_success(True, "删除成功")
