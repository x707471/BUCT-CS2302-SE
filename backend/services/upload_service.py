from models import db, UserUpload


def add_upload(user_id, artifact_id=None, media_type="image", file_url="", file_path="", caption="", description=""):
    upload = UserUpload(
        user_id=user_id,
        artifact_id=artifact_id,
        media_type=media_type,
        file_url=file_url,
        file_path=file_path,
        caption=caption,
        status="pending",
    )
    db.session.add(upload)
    db.session.commit()
    return upload


def get_user_uploads(user_id):
    return UserUpload.query.filter_by(user_id=user_id).order_by(UserUpload.created_at.desc()).all()


def get_artifact_uploads(artifact_id, status="approved"):
    query = UserUpload.query.filter_by(artifact_id=artifact_id)
    if status:
        query = query.filter_by(status=status)
    return query.order_by(UserUpload.created_at.desc()).all()
