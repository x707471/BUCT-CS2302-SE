from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class Museum(db.Model):
    __tablename__ = "museums"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(200), nullable=False)
    short_name = db.Column(db.String(100))
    country = db.Column(db.String(100), nullable=False)
    city = db.Column(db.String(100))
    website = db.Column(db.String(255))
    collection_url = db.Column(db.String(255))
    latitude = db.Column(db.Numeric(10, 7))
    longitude = db.Column(db.Numeric(10, 7))
    created_at = db.Column(db.DateTime, default=datetime.now)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)

    artifacts = db.relationship("Artifact", backref="museum", lazy="dynamic")

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "shortName": self.short_name,
            "country": self.country,
            "city": self.city,
            "website": self.website,
            "collectionUrl": self.collection_url,
            "latitude": float(self.latitude) if self.latitude else None,
            "longitude": float(self.longitude) if self.longitude else None,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
            "updatedAt": self.updated_at.strftime("%Y-%m-%d %H:%M:%S") if self.updated_at else None,
        }


class Dynasty(db.Model):
    __tablename__ = "dynasties"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name_zh = db.Column(db.String(50), nullable=False)
    name_en = db.Column(db.String(100))
    start_year = db.Column(db.Integer)
    end_year = db.Column(db.Integer)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now)

    artifacts = db.relationship("Artifact", backref="dynasty", lazy="dynamic")
    artists = db.relationship("Artist", backref="dynasty", lazy="dynamic")

    def to_dict(self):
        return {
            "id": self.id,
            "nameZh": self.name_zh,
            "nameEn": self.name_en,
            "startYear": self.start_year,
            "endYear": self.end_year,
            "description": self.description,
        }


class Artist(db.Model):
    __tablename__ = "artists"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name_zh = db.Column(db.String(100))
    name_en = db.Column(db.String(200))
    birth_year = db.Column(db.Integer)
    death_year = db.Column(db.Integer)
    dynasty_id = db.Column(db.Integer, db.ForeignKey("dynasties.id"))
    biography = db.Column(db.Text)
    baidu_url = db.Column(db.String(255))
    wiki_url = db.Column(db.String(255))
    created_at = db.Column(db.DateTime, default=datetime.now)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)

    def to_dict(self):
        return {
            "id": self.id,
            "nameZh": self.name_zh,
            "nameEn": self.name_en,
            "birthYear": self.birth_year,
            "deathYear": self.death_year,
            "dynastyId": self.dynasty_id,
            "biography": self.biography,
            "baiduUrl": self.baidu_url,
            "wikiUrl": self.wiki_url,
        }


class Location(db.Model):
    __tablename__ = "locations"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name_zh = db.Column(db.String(100), nullable=False)
    name_en = db.Column(db.String(200))
    parent_id = db.Column(db.Integer, db.ForeignKey("locations.id"))
    type = db.Column(db.String(20))
    created_at = db.Column(db.DateTime, default=datetime.now)

    parent = db.relationship("Location", remote_side=[id], backref="children")

    def to_dict(self):
        return {
            "id": self.id,
            "nameZh": self.name_zh,
            "nameEn": self.name_en,
            "parentId": self.parent_id,
            "type": self.type,
        }


class Artifact(db.Model):
    __tablename__ = "artifacts"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    object_id = db.Column(db.String(100), nullable=False)
    title_zh = db.Column(db.String(500))
    title_en = db.Column(db.String(500), nullable=False)
    time_period = db.Column(db.String(200))
    dynasty_id = db.Column(db.Integer, db.ForeignKey("dynasties.id"))
    type = db.Column(db.String(100))
    material = db.Column(db.String(200))
    description = db.Column(db.Text)
    dimensions = db.Column(db.String(200))
    museum_id = db.Column(db.Integer, db.ForeignKey("museums.id"), nullable=False)
    location_id = db.Column(db.Integer, db.ForeignKey("locations.id"))
    detail_url = db.Column(db.String(500))
    image_url = db.Column(db.String(500))
    image_path = db.Column(db.String(500))
    credit_line = db.Column(db.String(300))
    accession_number = db.Column(db.String(100))
    crawl_date = db.Column(db.Date)
    image_validated = db.Column(db.Integer)
    last_updated = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    created_at = db.Column(db.DateTime, default=datetime.now)
    provenance = db.Column(db.Text)
    current_status = db.Column(db.String(100))

    location = db.relationship("Location", backref="artifacts")
    images = db.relationship("ArtifactImage", backref="artifact", lazy="dynamic")
    favorites = db.relationship("UserFavorite", backref="artifact", lazy="dynamic")
    likes = db.relationship("ArtifactLike", backref="artifact", lazy="dynamic")
    comments = db.relationship("UserComment", backref="artifact", lazy="dynamic")
    browse_histories = db.relationship("UserBrowseHistory", backref="artifact", lazy="dynamic")

    def to_dict(self):
        return {
            "id": self.id,
            "objectId": self.object_id,
            "titleZh": self.title_zh,
            "titleEn": self.title_en,
            "timePeriod": self.time_period,
            "dynastyId": self.dynasty_id,
            "type": self.type,
            "material": self.material,
            "description": self.description,
            "dimensions": self.dimensions,
            "museumId": self.museum_id,
            "museumName": self.museum.name if self.museum else None,
            "locationId": self.location_id,
            "detailUrl": self.detail_url,
            "imageUrl": self.image_url,
            "imagePath": self.image_path,
            "creditLine": self.credit_line,
            "accessionNumber": self.accession_number,
            "crawlDate": self.crawl_date.strftime("%Y-%m-%d") if self.crawl_date else None,
            "imageValidated": self.image_validated,
            "lastUpdated": self.last_updated.strftime("%Y-%m-%d %H:%M:%S") if self.last_updated else None,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
            "provenance": self.provenance,
            "currentStatus": self.current_status,
        }


class ArtifactImage(db.Model):
    __tablename__ = "artifact_images"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    artifact_id = db.Column(db.Integer, db.ForeignKey("artifacts.id"), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    image_path = db.Column(db.String(500))
    is_primary = db.Column(db.Integer)
    sort_order = db.Column(db.Integer)

    def to_dict(self):
        return {
            "id": self.id,
            "artifactId": self.artifact_id,
            "imageUrl": self.image_url,
            "imagePath": self.image_path,
            "isPrimary": self.is_primary,
            "sortOrder": self.sort_order,
        }


class ArtifactArtist(db.Model):
    __tablename__ = "artifact_artist"

    artifact_id = db.Column(db.Integer, db.ForeignKey("artifacts.id"), primary_key=True, nullable=False)
    artist_id = db.Column(db.Integer, db.ForeignKey("artists.id"), primary_key=True, nullable=False)
    relationship_type = db.Column(db.String(50))

    artist = db.relationship("Artist", backref="artifact_associations")

    def to_dict(self):
        return {
            "artifactId": self.artifact_id,
            "artistId": self.artist_id,
            "relationshipType": self.relationship_type,
        }


class ArtifactLocation(db.Model):
    __tablename__ = "artifact_location"

    artifact_id = db.Column(db.Integer, db.ForeignKey("artifacts.id"), primary_key=True, nullable=False)
    location_id = db.Column(db.Integer, db.ForeignKey("locations.id"), primary_key=True, nullable=False)
    role = db.Column(db.String(50))

    location = db.relationship("Location", backref="artifact_associations")

    def to_dict(self):
        return {
            "artifactId": self.artifact_id,
            "locationId": self.location_id,
            "role": self.role,
        }


class Role(db.Model):
    __tablename__ = "roles"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(50), nullable=False)
    display_name = db.Column(db.String(50), nullable=False)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "displayName": self.display_name,
            "description": self.description,
        }


class Permission(db.Model):
    __tablename__ = "permissions"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    display_name = db.Column(db.String(100))
    module = db.Column(db.String(50))
    created_at = db.Column(db.DateTime, default=datetime.now)

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "displayName": self.display_name,
            "module": self.module,
        }


class RolePermission(db.Model):
    __tablename__ = "role_permissions"

    role_id = db.Column(db.Integer, db.ForeignKey("roles.id"), primary_key=True, nullable=False)
    permission_id = db.Column(db.Integer, db.ForeignKey("permissions.id"), primary_key=True, nullable=False)

    role = db.relationship("Role", backref="role_permissions")
    permission = db.relationship("Permission", backref="role_permissions")


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), nullable=False, unique=True)
    password_hash = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(100))
    phone = db.Column(db.String(20))
    avatar_url = db.Column(db.String(500))
    nickname = db.Column(db.String(50))
    status = db.Column(db.String(20), default="active")
    ban_reason = db.Column(db.Text)
    registered_at = db.Column(db.DateTime, default=datetime.now)
    last_login = db.Column(db.DateTime)
    last_ip = db.Column(db.String(45))
    source = db.Column(db.String(20))
    comment_disabled = db.Column(db.Integer, default=0)
    upload_disabled = db.Column(db.Integer, default=0)
    user_type = db.Column(db.String(20))
    institution = db.Column(db.String(200))
    created_at = db.Column(db.DateTime, default=datetime.now)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)

    favorites = db.relationship("UserFavorite", backref="user", lazy="dynamic", foreign_keys="UserFavorite.user_id")
    artifact_likes = db.relationship("ArtifactLike", backref="user", lazy="dynamic", foreign_keys="ArtifactLike.user_id")
    comments = db.relationship("UserComment", backref="user", lazy="dynamic", foreign_keys="UserComment.user_id")
    browse_histories = db.relationship("UserBrowseHistory", backref="user", lazy="dynamic", foreign_keys="UserBrowseHistory.user_id")
    uploads = db.relationship("UserUpload", backref="user", lazy="dynamic", foreign_keys="UserUpload.user_id")
    posts = db.relationship("UserPost", backref="user", lazy="dynamic", foreign_keys="UserPost.user_id")
    user_roles = db.relationship("UserRole", backref="user", lazy="dynamic", foreign_keys="UserRole.user_id")

    def to_dict(self):
        return {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "phone": self.phone,
            "avatarUrl": self.avatar_url,
            "nickname": self.nickname,
            "status": self.status,
            "registeredAt": self.registered_at.strftime("%Y-%m-%d %H:%M:%S") if self.registered_at else None,
            "lastLogin": self.last_login.strftime("%Y-%m-%d %H:%M:%S") if self.last_login else None,
            "source": self.source,
            "userType": self.user_type,
            "institution": self.institution,
        }


class UserRole(db.Model):
    __tablename__ = "user_roles"

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True, nullable=False)
    role_id = db.Column(db.Integer, db.ForeignKey("roles.id"), primary_key=True, nullable=False)
    granted_by = db.Column(db.Integer, db.ForeignKey("users.id"))
    granted_at = db.Column(db.DateTime, default=datetime.now)

    role = db.relationship("Role", backref="user_roles")
    grantor = db.relationship("User", foreign_keys=[granted_by])


class UserFavorite(db.Model):
    __tablename__ = "user_favorites"

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True, nullable=False)
    artifact_id = db.Column(db.Integer, db.ForeignKey("artifacts.id"), primary_key=True, nullable=False)
    group_name = db.Column(db.String(50))
    created_at = db.Column(db.DateTime, default=datetime.now)

    def to_dict(self):
        return {
            "userId": self.user_id,
            "artifactId": self.artifact_id,
            "groupName": self.group_name,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
        }


class UserBrowseHistory(db.Model):
    __tablename__ = "user_browse_history"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    artifact_id = db.Column(db.Integer, db.ForeignKey("artifacts.id"), nullable=False)
    browse_time = db.Column(db.DateTime, default=datetime.now)

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "artifactId": self.artifact_id,
            "browseTime": self.browse_time.strftime("%Y-%m-%d %H:%M:%S") if self.browse_time else None,
        }


class ArtifactLike(db.Model):
    __tablename__ = "artifact_likes"

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True, nullable=False)
    artifact_id = db.Column(db.Integer, db.ForeignKey("artifacts.id"), primary_key=True, nullable=False)
    liked_at = db.Column(db.DateTime, default=datetime.now)

    def to_dict(self):
        return {
            "userId": self.user_id,
            "artifactId": self.artifact_id,
            "likedAt": self.liked_at.strftime("%Y-%m-%d %H:%M:%S") if self.liked_at else None,
        }


class UserComment(db.Model):
    __tablename__ = "user_comments"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    artifact_id = db.Column(db.Integer, db.ForeignKey("artifacts.id"), nullable=False)
    parent_id = db.Column(db.Integer, db.ForeignKey("user_comments.id"))
    content = db.Column(db.Text, nullable=False)
    like_count = db.Column(db.Integer, default=0)
    status = db.Column(db.String(20), default="pending")
    audit_by = db.Column(db.Integer, db.ForeignKey("users.id"))
    audit_time = db.Column(db.DateTime)
    reject_reason = db.Column(db.String(200))
    created_at = db.Column(db.DateTime, default=datetime.now)

    replies = db.relationship("UserComment", backref=db.backref("parent", remote_side=[id]), lazy="dynamic")
    auditor = db.relationship("User", foreign_keys=[audit_by])

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "artifactId": self.artifact_id,
            "parentId": self.parent_id,
            "content": self.content,
            "likeCount": self.like_count,
            "status": self.status,
            "auditBy": self.audit_by,
            "auditTime": self.audit_time.strftime("%Y-%m-%d %H:%M:%S") if self.audit_time else None,
            "rejectReason": self.reject_reason,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
        }


class CommentLike(db.Model):
    __tablename__ = "comment_likes"

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True, nullable=False)
    comment_id = db.Column(db.Integer, db.ForeignKey("user_comments.id"), primary_key=True, nullable=False)
    liked_at = db.Column(db.DateTime, default=datetime.now)

    user = db.relationship("User", backref="comment_likes")
    comment = db.relationship("UserComment", backref="comment_likes")


class UserUpload(db.Model):
    __tablename__ = "user_uploads"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    artifact_id = db.Column(db.Integer, db.ForeignKey("artifacts.id"))
    media_type = db.Column(db.String(20), nullable=False)
    file_url = db.Column(db.String(500), nullable=False)
    file_path = db.Column(db.String(500))
    caption = db.Column(db.String(500))
    location_taken = db.Column(db.String(200))
    status = db.Column(db.String(20), default="pending")
    audit_by = db.Column(db.Integer, db.ForeignKey("users.id"))
    audit_time = db.Column(db.DateTime)
    reject_reason = db.Column(db.String(200))
    like_count = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.now)

    artifact = db.relationship("Artifact", backref="uploads")
    auditor = db.relationship("User", foreign_keys=[audit_by])

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "artifactId": self.artifact_id,
            "mediaType": self.media_type,
            "fileUrl": self.file_url,
            "caption": self.caption,
            "locationTaken": self.location_taken,
            "status": self.status,
            "likeCount": self.like_count,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
        }


class UserPost(db.Model):
    __tablename__ = "user_posts"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    content = db.Column(db.Text, nullable=False)
    artifact_id = db.Column(db.Integer, db.ForeignKey("artifacts.id"))
    museum_id = db.Column(db.Integer, db.ForeignKey("museums.id"))
    image_urls = db.Column(db.Text)
    like_count = db.Column(db.Integer, default=0)
    comment_count = db.Column(db.Integer, default=0)
    status = db.Column(db.String(20), default="pending")
    audit_by = db.Column(db.Integer, db.ForeignKey("users.id"))
    audit_time = db.Column(db.DateTime)
    reject_reason = db.Column(db.String(200))
    created_at = db.Column(db.DateTime, default=datetime.now)

    artifact = db.relationship("Artifact", backref="posts")
    museum_ref = db.relationship("Museum", backref="posts")
    auditor = db.relationship("User", foreign_keys=[audit_by])

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "content": self.content,
            "artifactId": self.artifact_id,
            "museumId": self.museum_id,
            "imageUrls": self.image_urls,
            "likeCount": self.like_count,
            "commentCount": self.comment_count,
            "status": self.status,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
        }


class PostLike(db.Model):
    __tablename__ = "post_likes"

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True, nullable=False)
    post_id = db.Column(db.Integer, db.ForeignKey("user_posts.id"), primary_key=True, nullable=False)
    liked_at = db.Column(db.DateTime, default=datetime.now)

    user = db.relationship("User", backref="post_likes")
    post = db.relationship("UserPost", backref="post_likes")


class UserFollow(db.Model):
    __tablename__ = "user_follows"

    follower_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True, nullable=False)
    followee_id = db.Column(db.Integer, db.ForeignKey("users.id"), primary_key=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.now)

    follower = db.relationship("User", foreign_keys=[follower_id], backref="following")
    followee = db.relationship("User", foreign_keys=[followee_id], backref="followers")


class SensitiveWord(db.Model):
    __tablename__ = "sensitive_words"

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    word = db.Column(db.String(100), nullable=False)
    category = db.Column(db.String(50))
    status = db.Column(db.Integer, default=1)
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)

    def to_dict(self):
        return {
            "id": self.id,
            "word": self.word,
            "category": self.category,
            "status": self.status,
        }


class CrawlTask(db.Model):
    __tablename__ = "crawl_tasks"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    museum_id = db.Column(db.Integer, db.ForeignKey("museums.id"), nullable=False)
    start_time = db.Column(db.DateTime, nullable=False)
    end_time = db.Column(db.DateTime)
    status = db.Column(db.String(20))
    items_crawled = db.Column(db.Integer)
    items_new = db.Column(db.Integer)
    items_updated = db.Column(db.Integer)
    error_message = db.Column(db.Text)

    museum = db.relationship("Museum", backref="crawl_tasks")

    def to_dict(self):
        return {
            "id": self.id,
            "museumId": self.museum_id,
            "startTime": self.start_time.strftime("%Y-%m-%d %H:%M:%S") if self.start_time else None,
            "endTime": self.end_time.strftime("%Y-%m-%d %H:%M:%S") if self.end_time else None,
            "status": self.status,
            "itemsCrawled": self.items_crawled,
            "itemsNew": self.items_new,
            "itemsUpdated": self.items_updated,
        }


class OperationLog(db.Model):
    __tablename__ = "operation_logs"

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    operation_type = db.Column(db.String(50), nullable=False)
    target_type = db.Column(db.String(50))
    target_id = db.Column(db.String(100))
    old_value = db.Column(db.Text)
    new_value = db.Column(db.Text)
    ip = db.Column(db.String(45))
    user_agent = db.Column(db.String(300))
    created_at = db.Column(db.DateTime, default=datetime.now)

    user = db.relationship("User", backref="operation_logs")

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "operationType": self.operation_type,
            "targetType": self.target_type,
            "targetId": self.target_id,
            "ip": self.ip,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
        }


class SystemLog(db.Model):
    __tablename__ = "system_logs"

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    log_level = db.Column(db.String(10), nullable=False)
    module = db.Column(db.String(100))
    message = db.Column(db.Text)
    detail = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now)

    def to_dict(self):
        return {
            "id": self.id,
            "logLevel": self.log_level,
            "module": self.module,
            "message": self.message,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
        }


class SecurityLog(db.Model):
    __tablename__ = "security_logs"

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"))
    event_type = db.Column(db.String(50), nullable=False)
    ip = db.Column(db.String(45))
    detail = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now)

    user = db.relationship("User", backref="security_logs")

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "eventType": self.event_type,
            "ip": self.ip,
            "detail": self.detail,
        }


class BackupRecord(db.Model):
    __tablename__ = "backup_records"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    backup_type = db.Column(db.String(20), nullable=False)
    file_name = db.Column(db.String(200), nullable=False)
    file_size = db.Column(db.BigInteger)
    file_path = db.Column(db.String(500), nullable=False)
    status = db.Column(db.String(20))
    operator_id = db.Column(db.Integer, db.ForeignKey("users.id"))
    started_at = db.Column(db.DateTime, nullable=False)
    finished_at = db.Column(db.DateTime)
    md5_hash = db.Column(db.String(64))

    operator = db.relationship("User", backref="backup_records")

    def to_dict(self):
        return {
            "id": self.id,
            "backupType": self.backup_type,
            "fileName": self.file_name,
            "fileSize": self.file_size,
            "status": self.status,
            "startedAt": self.started_at.strftime("%Y-%m-%d %H:%M:%S") if self.started_at else None,
            "finishedAt": self.finished_at.strftime("%Y-%m-%d %H:%M:%S") if self.finished_at else None,
        }


class SystemConfig(db.Model):
    __tablename__ = "system_configs"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    config_key = db.Column(db.String(100), nullable=False)
    config_value = db.Column(db.Text, nullable=False)
    description = db.Column(db.String(200))
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    updated_by = db.Column(db.Integer, db.ForeignKey("users.id"))

    updater = db.relationship("User", backref="system_configs")

    def to_dict(self):
        return {
            "id": self.id,
            "configKey": self.config_key,
            "configValue": self.config_value,
            "description": self.description,
        }


class Notification(db.Model):
    __tablename__ = "notifications"

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    type = db.Column(db.String(50), nullable=False)
    title = db.Column(db.String(200))
    content = db.Column(db.Text)
    is_read = db.Column(db.Boolean, default=False)
    extra_data = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now)

    user = db.relationship("User", backref="notifications")

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "type": self.type,
            "title": self.title,
            "content": self.content,
            "isRead": self.is_read,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
        }


class AuditRecord(db.Model):
    __tablename__ = "audit_records"

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    content_id = db.Column(db.String(100))
    content_type = db.Column(db.String(50), nullable=False)
    content = db.Column(db.Text, nullable=False)
    submitter_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    auto_audit_result = db.Column(db.String(20), default="pending")
    manual_audit_result = db.Column(db.String(20), default="pending")
    auditor_id = db.Column(db.Integer, db.ForeignKey("users.id"))
    audit_time = db.Column(db.DateTime)
    reject_reason = db.Column(db.String(500))
    source_type = db.Column(db.String(50))
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)

    submitter = db.relationship("User", foreign_keys=[submitter_id], backref="submitted_audits")
    auditor = db.relationship("User", foreign_keys=[auditor_id])

    def to_dict(self):
        return {
            "id": self.id,
            "contentId": self.content_id,
            "contentType": self.content_type,
            "submitterId": self.submitter_id,
            "autoAuditResult": self.auto_audit_result,
            "manualAuditResult": self.manual_audit_result,
            "auditorId": self.auditor_id,
            "rejectReason": self.reject_reason,
        }


class PenaltyRecord(db.Model):
    __tablename__ = "penalty_records"

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    penalty_type = db.Column(db.String(50), nullable=False)
    reason = db.Column(db.Text, nullable=False)
    operator_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    penalty_time = db.Column(db.DateTime, nullable=False)
    expire_time = db.Column(db.DateTime)
    status = db.Column(db.Integer, default=1)
    remark = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)

    user = db.relationship("User", foreign_keys=[user_id], backref="penalties")
    operator = db.relationship("User", foreign_keys=[operator_id])

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "penaltyType": self.penalty_type,
            "reason": self.reason,
            "operatorId": self.operator_id,
            "penaltyTime": self.penalty_time.strftime("%Y-%m-%d %H:%M:%S") if self.penalty_time else None,
            "expireTime": self.expire_time.strftime("%Y-%m-%d %H:%M:%S") if self.expire_time else None,
            "status": self.status,
        }


class AppealRecord(db.Model):
    __tablename__ = "appeal_records"

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    penalty_id = db.Column(db.BigInteger, db.ForeignKey("penalty_records.id"), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    appeal_reason = db.Column(db.Text, nullable=False)
    evidence = db.Column(db.Text)
    status = db.Column(db.String(20), default="pending")
    handler_id = db.Column(db.Integer, db.ForeignKey("users.id"))
    handle_time = db.Column(db.DateTime)
    handle_result = db.Column(db.String(20))
    handle_remark = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)

    penalty = db.relationship("PenaltyRecord", backref="appeals")
    user = db.relationship("User", foreign_keys=[user_id], backref="appeals")
    handler = db.relationship("User", foreign_keys=[handler_id])

    def to_dict(self):
        return {
            "id": self.id,
            "penaltyId": self.penalty_id,
            "userId": self.user_id,
            "appealReason": self.appeal_reason,
            "status": self.status,
            "handlerId": self.handler_id,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
        }


class ViolationType(db.Model):
    __tablename__ = "violation_types"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    type_code = db.Column(db.String(50), nullable=False, unique=True)
    type_name = db.Column(db.String(100), nullable=False)
    severity_level = db.Column(db.Integer, nullable=False)
    default_penalty = db.Column(db.String(50))
    description = db.Column(db.Text)
    status = db.Column(db.Integer, default=1)
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)

    def to_dict(self):
        return {
            "id": self.id,
            "typeCode": self.type_code,
            "typeName": self.type_name,
            "severityLevel": self.severity_level,
            "defaultPenalty": self.default_penalty,
            "description": self.description,
            "status": self.status,
        }


class UserBehavior(db.Model):
    __tablename__ = "user_behaviors"

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    behavior_type = db.Column(db.String(50), nullable=False)
    target_type = db.Column(db.String(50))
    target_id = db.Column(db.String(100))
    target_desc = db.Column(db.String(500))
    ip = db.Column(db.String(45))
    device = db.Column(db.String(200))
    detail = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)

    user = db.relationship("User", backref="behaviors")

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "behaviorType": self.behavior_type,
            "targetType": self.target_type,
            "targetId": self.target_id,
            "targetDesc": self.target_desc,
            "createdAt": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None,
        }
