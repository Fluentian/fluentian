import json
import time
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
    start = time.perf_counter()
    with urllib.request.urlopen(req, timeout=20) as res:
        raw = res.read().decode("utf-8")
    elapsed = time.perf_counter() - start
    return elapsed, json.loads(raw) if raw else {}


def main():
    elapsed, auth = request(
        "POST",
        "/auth/login",
        body={"email": "student@fluentian.com", "password": "Fluentian@12345"},
    )
    print(f"login: {elapsed:.3f}s")
    token = auth["access_token"]

    elapsed, courses = request("GET", "/content/courses", token=token)
    print(f"content/courses: {elapsed:.3f}s, items={len(courses.get('items', []))}")

    elapsed, stats = request("GET", "/progress/me/stats", token=token)
    print(f"progress/me/stats: {elapsed:.3f}s, xp={stats.get('xp_total')}")


if __name__ == "__main__":
    main()
