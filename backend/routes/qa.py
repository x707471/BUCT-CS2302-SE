from flask import Blueprint, request
from utils.response import api_error

qa_bp = Blueprint("qa", __name__, url_prefix="/api/qa")


@qa_bp.route("/ask", methods=["POST"])
def ask_question():
    data = request.get_json()
    question = data.get("question", "")
    artifact_id = data.get("artifactId")

    if not question:
        return api_error("问题不能为空", 400)

    answer = generate_answer(question, artifact_id)
    return {"answer": answer}


def generate_answer(question, artifact_id=None):
    from models import Artifact, Dynasty, Museum

    artifact_context = ""
    if artifact_id:
        artifact = Artifact.query.get(artifact_id)
        if artifact:
            dynasty = Dynasty.query.get(artifact.dynasty_id) if artifact.dynasty_id else None
            museum = Museum.query.get(artifact.museum_id) if artifact.museum_id else None
            artifact_context = f"当前文物：{artifact.title_zh or artifact.title_en}"
            if dynasty:
                artifact_context += f"，朝代：{dynasty.name_zh}"
            if museum:
                artifact_context += f"，馆藏：{museum.name}"
            if artifact.material:
                artifact_context += f"，材质：{artifact.material}"
            if artifact.description:
                artifact_context += f"，描述：{artifact.description[:200]}"

    keyword = question.strip()
    artifacts = Artifact.query.filter(
        Artifact.title_zh.like(f"%{keyword}%") | Artifact.description.like(f"%{keyword}%")
    ).limit(3).all()

    response_parts = []
    if artifact_context:
        response_parts.append(artifact_context)

    if artifacts:
        response_parts.append("相关文物：")
        for a in artifacts:
            response_parts.append(f"- {a.title_zh or a.title_en}（{a.time_period or '未知年代'}，{a.type or '未知类型'}）")

    if not response_parts:
        response_parts.append(f"关于「{question}」，暂未找到相关信息。请尝试其他关键词。")

    return "\n".join(response_parts)
