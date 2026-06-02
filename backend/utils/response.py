from flask import jsonify


def api_success(data=None, message="操作成功", code=200):
    response = {
        "code": code,
        "message": message,
        "data": data,
    }
    return jsonify(response), code


def api_error(message="操作失败", code=400, data=None):
    response = {
        "code": code,
        "message": message,
        "data": data,
    }
    return jsonify(response), code
