import json
import urllib.request


BASE_URL = "http://127.0.0.1:8000/api/v1"


def request(method, path, token=None, body=None):
    headers = {"Accept": "application/json"}
    data = None
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(
        f"{BASE_URL}{path}",
        method=method,
        data=data,
        headers=headers,
    )
    with urllib.request.urlopen(req, timeout=20) as res:
        return json.loads(res.read().decode("utf-8"))


def main():
    auth = request(
        "POST",
        "/auth/login",
        body={"email": "student@fluentian.com", "password": "Fluentian@12345"},
    )
    token = auth["access_token"]
    courses = request("GET", "/content/courses", token=token)
    first_course = courses["items"][0]
    first_lesson = first_course["units"][0]["lessons"][0]
    detail = request("GET", f"/content/lessons/{first_lesson['id']}", token=token)
    print(first_lesson["id"], first_lesson["title"])
    print(
        json.dumps(
            [
                {
                    "kind": block["block_kind"],
                    "tts_enabled": block["block_payload"].get("tts_enabled"),
                    "tts_language": block["block_payload"].get("tts_language"),
                    "tts_text": block["block_payload"].get("tts_text"),
                    "content": block["block_payload"].get("content"),
                    "target": block["block_payload"].get("target"),
                }
                for block in detail["blocks"]
            ],
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
