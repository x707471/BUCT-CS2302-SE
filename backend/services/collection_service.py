from models import db, UserFavorite, Artifact
from sqlalchemy import func


def get_user_collections(user_id):
    favorites = UserFavorite.query.filter_by(user_id=user_id).all()
    artifacts = []
    for f in favorites:
        artifact = Artifact.query.get(f.artifact_id)
        if artifact:
            artifact_dict = artifact.to_dict()
            artifact_dict["groupName"] = f.group_name
            artifact_dict["collectedAt"] = f.created_at.strftime("%Y-%m-%d %H:%M:%S") if f.created_at else None
            artifacts.append(artifact_dict)
    return artifacts


def get_collection_groups(user_id):
    groups = db.session.query(
        UserFavorite.group_name,
        func.count(UserFavorite.artifact_id).label("count")
    ).filter_by(user_id=user_id).group_by(UserFavorite.group_name).all()
    return [{"groupName": g.group_name or "默认分组", "count": g.count} for g in groups]


def get_collection_by_group(user_id, group_name):
    if group_name == "默认分组":
        favorites = UserFavorite.query.filter_by(user_id=user_id).filter(
            db.or_(UserFavorite.group_name == None, UserFavorite.group_name == "", UserFavorite.group_name == "默认分组")
        ).all()
    else:
        favorites = UserFavorite.query.filter_by(user_id=user_id, group_name=group_name).all()
    artifacts = []
    for f in favorites:
        artifact = Artifact.query.get(f.artifact_id)
        if artifact:
            artifact_dict = artifact.to_dict()
            artifact_dict["groupName"] = f.group_name
            artifact_dict["collectedAt"] = f.created_at.strftime("%Y-%m-%d %H:%M:%S") if f.created_at else None
            artifacts.append(artifact_dict)
    return artifacts


def add_collection(user_id, artifact_id, group_name=None):
    existing = UserFavorite.query.filter_by(
        user_id=user_id, artifact_id=artifact_id
    ).first()
    if existing:
        return None
    favorite = UserFavorite(user_id=user_id, artifact_id=artifact_id, group_name=group_name)
    db.session.add(favorite)
    db.session.commit()
    return favorite


def remove_collection(user_id, artifact_id):
    favorite = UserFavorite.query.filter_by(
        user_id=user_id, artifact_id=artifact_id
    ).first()
    if not favorite:
        return False
    db.session.delete(favorite)
    db.session.commit()
    return True


def is_collected(user_id, artifact_id):
    return (
        UserFavorite.query.filter_by(
            user_id=user_id, artifact_id=artifact_id
        ).first()
        is not None
    )
