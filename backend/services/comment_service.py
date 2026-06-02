from models import db, UserComment, Artifact
from utils.response import api_success, api_error


def get_comments_by_artifact_id(artifact_id):
    return UserComment.query.filter_by(artifact_id=artifact_id, status="approved").order_by(
        UserComment.created_at.desc()
    ).all()


def get_comments_with_user_pending(artifact_id, user_id):
    approved = UserComment.query.filter_by(artifact_id=artifact_id, status="approved").order_by(
        UserComment.created_at.desc()
    ).all()
    pending = UserComment.query.filter_by(artifact_id=artifact_id, user_id=user_id, status="pending").order_by(
        UserComment.created_at.desc()
    ).all()
    return pending + approved


def get_all_comments():
    return UserComment.query.order_by(UserComment.created_at.desc()).all()


def add_comment(user_id, artifact_id, content):
    comment = UserComment(user_id=user_id, artifact_id=artifact_id, content=content)
    db.session.add(comment)
    db.session.commit()
    return comment


def update_review_status(comment_id, status):
    comment = UserComment.query.get(comment_id)
    if not comment:
        return False
    comment.status = status
    from datetime import datetime
    comment.audit_time = datetime.now()
    db.session.commit()
    return True


def delete_comment(comment_id):
    comment = UserComment.query.get(comment_id)
    if not comment:
        return False
    db.session.delete(comment)
    db.session.commit()
    return True


def update_comment_content(comment_id, content):
    comment = UserComment.query.get(comment_id)
    if not comment:
        return None
    comment.content = content
    db.session.commit()
    return comment


def get_user_comments_with_artifact_info(user_id):
    comments = UserComment.query.filter_by(user_id=user_id).order_by(UserComment.created_at.desc()).all()
    result = []
    for comment in comments:
        artifact = Artifact.query.get(comment.artifact_id)
        result.append({
            "id": comment.id,
            "userId": comment.user_id,
            "artifactId": comment.artifact_id,
            "content": comment.content,
            "status": comment.status,
            "createdAt": comment.created_at.strftime("%Y-%m-%d %H:%M:%S") if comment.created_at else None,
            "artifactName": artifact.title_zh if artifact else None,
            "artifactImageUrl": artifact.image_url if artifact else None,
        })
    return result
