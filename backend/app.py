import sys
import os

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from flask import Flask
from flask_cors import CORS
from config import config
from models import db


def create_app(config_name="default"):
    static_folder = os.path.join(os.path.abspath(os.path.dirname(__file__)), "static")
    app = Flask(__name__, static_folder=static_folder, static_url_path="/static")
    app.config.from_object(config[config_name])

    CORS(app, resources={r"/api/*": {"origins": "*"}})

    db.init_app(app)

    from routes.user import user_bp
    from routes.artifact import artifact_bp
    from routes.collection import collection_bp
    from routes.like import like_bp
    from routes.comment import comment_bp
    from routes.browse_history import browse_history_bp
    from routes.image_search import image_search_bp
    from routes.upload import upload_bp
    from routes.qa import qa_bp
    from routes.tts import tts_bp

    app.register_blueprint(user_bp)
    app.register_blueprint(artifact_bp)
    app.register_blueprint(collection_bp)
    app.register_blueprint(like_bp)
    app.register_blueprint(comment_bp)
    app.register_blueprint(browse_history_bp)
    app.register_blueprint(image_search_bp)
    app.register_blueprint(upload_bp)
    app.register_blueprint(qa_bp)
    app.register_blueprint(tts_bp)

    with app.app_context():
        try:
            from services import image_search_service
            count = image_search_service.load_feature_index()
            print(f"[ImageSearch] 特征索引加载完成，共 {count} 条记录")
        except Exception as e:
            print(f"[ImageSearch] 特征索引加载失败: {e}")

    return app


if __name__ == "__main__":
    app = create_app("development")
    app.run(host="0.0.0.0", port=5000, debug=True)
