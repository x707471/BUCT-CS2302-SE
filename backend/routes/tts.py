import asyncio
import os
import hashlib
from flask import Blueprint, send_file, request
from models import Artifact, Museum, Dynasty
from utils.response import api_error

tts_bp = Blueprint("tts", __name__, url_prefix="/api/artifacts")

AUDIO_CACHE_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "audio_cache")
os.makedirs(AUDIO_CACHE_DIR, exist_ok=True)


def build_artifact_text(artifact, dynasty=None, museum=None):
    parts = []
    if artifact.title_zh:
        parts.append(artifact.title_zh)
    if dynasty:
        parts.append(f"年代：{dynasty.name_zh}")
    elif artifact.time_period:
        parts.append(f"年代：{artifact.time_period}")
    if artifact.type:
        parts.append(f"类型：{artifact.type}")
    if artifact.material:
        parts.append(f"材质：{artifact.material}")
    if museum:
        parts.append(f"所属博物馆：{museum.name}")
    elif artifact.museum_id:
        parts.append("馆藏文物")
    if artifact.dimensions:
        parts.append(f"尺寸：{artifact.dimensions}")
    if artifact.description:
        parts.append(artifact.description)
    return "。".join(parts)


async def generate_audio(text, output_path, voice="zh-CN-XiaoxiaoNeural"):
    import edge_tts
    communicate = edge_tts.Communicate(text, voice)
    await communicate.save(output_path)


@tts_bp.route("/<int:artifact_id>/audio", methods=["GET"])
def get_artifact_audio(artifact_id):
    artifact = Artifact.query.get(artifact_id)
    if not artifact:
        return api_error("文物不存在", 404)

    dynasty = Dynasty.query.get(artifact.dynasty_id) if artifact.dynasty_id else None
    museum = Museum.query.get(artifact.museum_id) if artifact.museum_id else None

    text = build_artifact_text(artifact, dynasty, museum)
    if not text.strip():
        return api_error("该文物暂无文字介绍", 404)

    voice = request.args.get("voice", "zh-CN-XiaoxiaoNeural")
    text_hash = hashlib.md5(f"{text}_{voice}".encode("utf-8")).hexdigest()
    audio_path = os.path.join(AUDIO_CACHE_DIR, f"{text_hash}.mp3")

    if not os.path.exists(audio_path) or os.path.getsize(audio_path) == 0:
        try:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            loop.run_until_complete(generate_audio(text, audio_path, voice))
            loop.close()
        except Exception as e:
            if os.path.exists(audio_path):
                os.remove(audio_path)
            return api_error(f"音频生成失败: {str(e)}", 500)

        if os.path.getsize(audio_path) == 0:
            os.remove(audio_path)
            return api_error("音频生成失败：生成的音频文件为空", 500)

    return send_file(audio_path, mimetype="audio/mpeg", as_attachment=False)
