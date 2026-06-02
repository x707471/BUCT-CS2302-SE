from datetime import datetime
from models import db, UserBrowseHistory, Artifact


def add_browse_history(user_id, artifact_id):
    existing = UserBrowseHistory.query.filter_by(
        user_id=user_id, artifact_id=artifact_id
    ).first()
    if existing:
        existing.browse_time = datetime.now()
        db.session.commit()
        return existing
    history = UserBrowseHistory(user_id=user_id, artifact_id=artifact_id)
    db.session.add(history)
    db.session.commit()
    return history


def get_user_browse_history(user_id):
    histories = (
        UserBrowseHistory.query.filter_by(user_id=user_id)
        .order_by(UserBrowseHistory.browse_time.desc())
        .all()
    )
    result = []
    for h in histories:
        artifact = Artifact.query.get(h.artifact_id)
        result.append({
            "id": h.id,
            "userId": h.user_id,
            "artifactId": h.artifact_id,
            "browseTime": h.browse_time.strftime("%Y-%m-%d %H:%M:%S") if h.browse_time else None,
            "artifact": artifact.to_dict() if artifact else None,
        })
    return result


def delete_browse_history(history_id, user_id):
    history = UserBrowseHistory.query.filter_by(id=history_id, user_id=user_id).first()
    if not history:
        return False
    db.session.delete(history)
    db.session.commit()
    return True


def clear_browse_history(user_id):
    UserBrowseHistory.query.filter_by(user_id=user_id).delete()
    db.session.commit()
    return True
