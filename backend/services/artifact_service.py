from models import db, Artifact, ArtifactLike, Museum, Dynasty


def get_all_artifacts(page=1, page_size=20, sort="default"):
    query = Artifact.query
    if sort == "hot":
        query = query.outerjoin(ArtifactLike, Artifact.id == ArtifactLike.artifact_id) \
            .group_by(Artifact.id) \
            .order_by(db.func.count(ArtifactLike.user_id).desc())
    elif sort == "newest":
        query = query.order_by(Artifact.created_at.desc())
    elif sort == "era":
        query = query.order_by(Artifact.time_period.asc())
    else:
        query = query.order_by(Artifact.id.asc())
    return query.paginate(page=page, per_page=page_size, error_out=False).items


def get_artifact_by_id(artifact_id):
    return Artifact.query.get(artifact_id)


def get_museum_by_id(museum_id):
    return Museum.query.get(museum_id)


def search_artifacts(keyword):
    if not keyword:
        return []
    return Artifact.query.filter(
        db.or_(
            Artifact.title_zh.like(f"%{keyword}%"),
            Artifact.title_en.like(f"%{keyword}%"),
            Artifact.time_period.like(f"%{keyword}%"),
            Artifact.type.like(f"%{keyword}%"),
            Artifact.material.like(f"%{keyword}%"),
            Artifact.description.like(f"%{keyword}%"),
        )
    ).all()


def advanced_search(keyword="", era="", artifact_type="", museum="", material="", sort="default", page=1, page_size=20):
    query = Artifact.query
    if keyword:
        query = query.filter(
            db.or_(
                Artifact.title_zh.like(f"%{keyword}%"),
                Artifact.title_en.like(f"%{keyword}%"),
                Artifact.time_period.like(f"%{keyword}%"),
                Artifact.type.like(f"%{keyword}%"),
                Artifact.material.like(f"%{keyword}%"),
                Artifact.description.like(f"%{keyword}%"),
            )
        )
    if era and era != "全部":
        query = query.filter(Artifact.time_period.like(f"%{era}%"))
    if artifact_type and artifact_type != "全部":
        query = query.filter_by(type=artifact_type)
    if museum and museum != "全部":
        museum_obj = Museum.query.filter(Museum.name.like(f"%{museum}%")).first()
        if museum_obj:
            query = query.filter_by(museum_id=museum_obj.id)
    if material and material != "全部":
        query = query.filter(Artifact.material.like(f"%{material}%"))
    if sort == "hot":
        query = query.outerjoin(ArtifactLike, Artifact.id == ArtifactLike.artifact_id) \
            .group_by(Artifact.id) \
            .order_by(db.func.count(ArtifactLike.user_id).desc())
    elif sort == "newest":
        query = query.order_by(Artifact.created_at.desc())
    elif sort == "era":
        query = query.order_by(Artifact.time_period.asc())
    else:
        query = query.order_by(Artifact.id.asc())
    return query.paginate(page=page, per_page=page_size, error_out=False).items


def get_artifacts_by_era(era):
    return Artifact.query.filter(Artifact.time_period.like(f"%{era}%")).all()


def get_artifacts_by_type(artifact_type):
    return Artifact.query.filter_by(type=artifact_type).all()


def get_artifacts_by_museum(museum_id):
    return Artifact.query.filter_by(museum_id=museum_id).all()


def get_artifacts_by_museum_name(museum_name):
    museum_obj = Museum.query.filter(Museum.name.like(f"%{museum_name}%")).first()
    if not museum_obj:
        return []
    return Artifact.query.filter_by(museum_id=museum_obj.id).all()


def get_artifacts_by_dynasty(dynasty_id):
    return Artifact.query.filter_by(dynasty_id=dynasty_id).all()


def get_likes_count(artifact_id):
    return ArtifactLike.query.filter_by(artifact_id=artifact_id).count()


def get_hot_artifacts(limit=20):
    return Artifact.query \
        .outerjoin(ArtifactLike, Artifact.id == ArtifactLike.artifact_id) \
        .group_by(Artifact.id) \
        .order_by(db.func.count(ArtifactLike.user_id).desc()) \
        .limit(limit) \
        .all()
