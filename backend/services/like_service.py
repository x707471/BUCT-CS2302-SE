from models import db, ArtifactLike, Artifact


def get_liked_artifacts(user_id):
    likes = ArtifactLike.query.filter_by(user_id=user_id).all()
    artifacts = []
    for like in likes:
        artifact = Artifact.query.get(like.artifact_id)
        if artifact:
            artifacts.append(artifact)
    return artifacts


def add_like(user_id, artifact_id):
    existing = ArtifactLike.query.filter_by(user_id=user_id, artifact_id=artifact_id).first()
    if existing:
        return False
    like = ArtifactLike(user_id=user_id, artifact_id=artifact_id)
    db.session.add(like)
    db.session.commit()
    return True


def remove_like(user_id, artifact_id):
    like = ArtifactLike.query.filter_by(user_id=user_id, artifact_id=artifact_id).first()
    if not like:
        return False
    db.session.delete(like)
    db.session.commit()
    return True


def has_liked(user_id, artifact_id):
    return ArtifactLike.query.filter_by(user_id=user_id, artifact_id=artifact_id).first() is not None


def get_likes_count(artifact_id):
    return ArtifactLike.query.filter_by(artifact_id=artifact_id).count()
