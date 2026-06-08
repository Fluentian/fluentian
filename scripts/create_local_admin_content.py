import json
import sys
import urllib.error
import urllib.parse
import urllib.request


BASE_URL = "http://127.0.0.1:8000/api/v1"
ADMIN_LOGINS = [
    ("superadmin@fluentian.com", "Fluentian@12345"),
    ("admin@fluentian.com", "Fluentian@12345"),
    ("admin@fluentian.com", "admin123"),
]


def request(method, path, token=None, body=None, query=None):
    url = f"{BASE_URL}{path}"
    if query:
        url = f"{url}?{urllib.parse.urlencode(query)}"
    data = None
    headers = {"Accept": "application/json"}
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    if token:
        headers["Authorization"] = f"Bearer {token}"

    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=20) as res:
            raw = res.read().decode("utf-8")
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as exc:
        details = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {path} failed: {exc.code} {details}") from exc


def login():
    last_error = None
    for email, password in ADMIN_LOGINS:
        try:
            data = request("POST", "/auth/login", body={"email": email, "password": password})
            print(f"Logged in as {email}")
            return data["access_token"]
        except Exception as exc:
            last_error = exc
    raise RuntimeError(f"Could not log in with known admin accounts: {last_error}")


def first_french_language():
    languages = request("GET", "/content/languages")
    if not languages:
        raise RuntimeError("No languages found. Seed languages before creating courses.")
    for language in languages:
        haystack = " ".join(str(language.get(key, "")) for key in ("code", "name", "native_name")).lower()
        if "fr" in haystack or "french" in haystack or "francais" in haystack or "français" in haystack:
            return language["id"]
    return languages[0]["id"]


def find_course(token, code):
    courses = request("GET", "/content/courses", token=token, query={"size": 100}).get("items", [])
    return next((course for course in courses if course["code"] == code), None)


def ensure_course(token):
    code = "FR_LOCAL_FULL_CONTENT"
    course = find_course(token, code)
    if course:
        print(f"Using existing course {code}: {course['id']}")
        return course
    course = request(
        "POST",
        "/content/courses",
        token=token,
        body={
            "target_language_id": first_french_language(),
            "code": code,
            "level_min": "A1",
            "level_max": "A2",
            "is_published": True,
        },
    )
    print(f"Created course {code}: {course['id']}")
    return course


UNITS = [
    ("core", 1, "Local Unit 1 - Foundations in Real French"),
    ("practice", 2, "Local Unit 2 - Daily Life Practice"),
    ("story", 3, "Local Unit 3 - Stories and Checkpoint Skills"),
]

LESSON_KINDS = [
    "vocabulary",
    "grammar_explainer",
    "dialogue",
    "pronunciation",
    "listening",
    "reading",
    "writing",
    "speaking",
    "cultural_bridge",
    "exam_drill",
    "roleplay_simulation",
    "vocabulary",
]


LESSON_TOPICS = [
    ("Greetings that sound natural", "Bonjour, salut, enchanté, and polite openings"),
    ("Introducing yourself clearly", "name, origin, language, and work or study"),
    ("Ethiopian-French café phrases", "ordering, paying, and responding politely"),
    ("Pronouncing nasal vowels", "bon, bien, pain, and simple listening cues"),
    ("Family and people around you", "family nouns, possessives, and short descriptions"),
    ("Daily routine in the present tense", "regular -er verbs and time expressions"),
    ("Shopping for essentials", "prices, quantities, and asking for help"),
    ("Directions around town", "left, right, near, far, and landmarks"),
    ("A short market story", "reading a narrative and finding key facts"),
    ("Writing a friendly message", "SMS greetings, invitations, and thanks"),
    ("Roleplay: meeting a host family", "questions, answers, and cultural warmth"),
    ("Checkpoint: survival French", "mixed review for real-life interactions"),
]


def block_payloads(unit_no, lesson_no, title, topic):
    intro_content = (
        f"{title}\n\nIn this lesson you use French for a real situation: {topic}. "
        "Read each phrase aloud, notice the word order, and compare it with how you would say it in Amharic or English."
    )
    return [
        (
            "rich_text",
            {
                "content": intro_content,
                "tts_enabled": True,
                "tts_language": "en-US",
                "tts_text": intro_content,
            },
        ),
        (
            "grammar_note",
            {
                "title": "Pattern to notice",
                "content": (
                    "French often places short politeness markers before or after the main phrase. "
                    "Use 's'il vous plaît' for formal requests and 's'il te plaît' with friends."
                ),
                "examples": [
                    {"fr": "Je voudrais un café, s'il vous plaît.", "en": "I would like a coffee, please."},
                    {"fr": "Tu peux répéter, s'il te plaît ?", "en": "Can you repeat, please?"},
                ],
                "tts_enabled": True,
                "tts_language": "fr-FR",
                "tts_text": "Je voudrais un café, s'il vous plaît. Tu peux répéter, s'il te plaît ?",
            },
        ),
        (
            "sentence_pair",
            {
                "source": "I am learning French because I want to speak with confidence.",
                "target": "J'apprends le français parce que je veux parler avec confiance.",
                "notes": "Parce que introduces the reason. Je veux + infinitive is useful for goals.",
                "tts_enabled": True,
                "tts_language": "fr-FR",
                "tts_text": "J'apprends le français parce que je veux parler avec confiance.",
            },
        ),
        (
            "ai_hint",
            {
                "hint": (
                    f"When practicing Unit {unit_no}, Lesson {lesson_no}, answer first in simple French. "
                    "Then ask the tutor to make it more natural and repeat the final version three times."
                ),
                "prompt": "Give me one easier version and one natural native-sounding version.",
                "tts_enabled": False,
            },
        ),
    ]


def question_payloads(unit_no, lesson_no, title):
    base = f"U{unit_no}L{lesson_no}"
    return [
        (
            "mcq_single",
            {"question": f"{base}: Which French phrase means 'Good evening'?", "options": ["Bonsoir", "Bonjour", "Merci", "Pain"]},
            {"correct_answer": "Bonsoir"},
        ),
        (
            "mcq_multi",
            {
                "question": f"{base}: Select the polite request phrases.",
                "options": ["S'il vous plaît", "Je voudrais", "Salut", "À gauche"],
            },
            {"correct_answer": "S'il vous plaît", "correct_answers": ["S'il vous plaît", "Je voudrais"]},
        ),
        (
            "fill_blank",
            {
                "question": f"{base}: Complete: Je ___ éthiopien / éthiopienne.",
                "blank": "suis",
                "options": ["suis", "es", "sommes", "êtes"],
            },
            {"correct_answer": "suis", "accepted_answers": ["suis"]},
        ),
        (
            "translation",
            {
                "question": f"{base}: Translate to French: Thank you very much for your help.",
                "lesson_title": title,
                "options": ["Merci", "beaucoup", "pour", "votre", "aide"],
                "chips": ["Merci", "beaucoup", "pour", "votre", "aide"],
            },
            {"correct_answer": "Merci beaucoup pour votre aide.", "accepted_answers": ["Merci beaucoup pour votre aide"]},
        ),
    ]


def ensure_units_lessons_content(token, course):
    existing_units = request("GET", f"/content/courses/{course['id']}/units", token=token)
    units_by_no = {unit["unit_no"]: unit for unit in existing_units}
    created = {"units": 0, "lessons": 0, "blocks": 0, "questions": 0}

    topic_index = 0
    for unit_kind, unit_no, unit_title in UNITS:
        unit = units_by_no.get(unit_no)
        if not unit:
            unit = request(
                "POST",
                f"/content/courses/{course['id']}/units",
                token=token,
                body={"unit_kind": unit_kind, "unit_no": unit_no, "title": unit_title},
            )
            created["units"] += 1
            print(f"Created unit {unit_no}: {unit_title}")
        else:
            print(f"Using existing unit {unit_no}: {unit['title']}")

        lessons = request("GET", "/content/lessons", token=token, query={"unit_id": unit["id"], "size": 100}).get("items", [])
        lessons_by_seq = {lesson["sequence_no"]: lesson for lesson in lessons}

        for local_seq in range(1, 5):
            sequence_no = local_seq
            title, topic = LESSON_TOPICS[topic_index]
            lesson_kind = LESSON_KINDS[topic_index]
            topic_index += 1

            lesson = lessons_by_seq.get(sequence_no)
            if not lesson:
                lesson = request(
                    "POST",
                    f"/content/units/{unit['id']}/lessons",
                    token=token,
                    body={
                        "lesson_kind": lesson_kind,
                        "sequence_no": sequence_no,
                        "title": title,
                        "estimated_minutes": 8 + local_seq,
                        "xp_reward": 15 + (local_seq * 5),
                        "is_published": True,
                    },
                )
                created["lessons"] += 1
                print(f"Created lesson U{unit_no}L{local_seq}: {title}")
            else:
                lesson = request(
                    "PATCH",
                    f"/content/lessons/{lesson['id']}",
                    token=token,
                    body={
                        "lesson_kind": lesson_kind,
                        "title": title,
                        "estimated_minutes": 8 + local_seq,
                        "xp_reward": 15 + (local_seq * 5),
                        "is_published": True,
                    },
                )
                print(f"Updated lesson U{unit_no}L{local_seq}: {title}")

            detail = request("GET", f"/content/lessons/{lesson['id']}", token=token)
            blocks_by_sequence = {
                block["sequence_no"]: block for block in detail.get("blocks", [])
            }
            for sequence, (kind, payload) in enumerate(block_payloads(unit_no, local_seq, title, topic), start=1):
                existing_block = blocks_by_sequence.get(sequence)
                if existing_block:
                    request(
                        "PATCH",
                        f"/content/blocks/{existing_block['id']}",
                        token=token,
                        body={
                            "block_kind": kind,
                            "sequence_no": sequence,
                            "block_payload": payload,
                        },
                    )
                else:
                    request(
                        "POST",
                        f"/content/lessons/{lesson['id']}/blocks",
                        token=token,
                        body={
                            "lesson_id": lesson["id"],
                            "block_kind": kind,
                            "sequence_no": sequence,
                            "block_payload": payload,
                        },
                    )
                    created["blocks"] += 1

            detail = request("GET", f"/content/lessons/{lesson['id']}", token=token)
            questions_by_sequence = {
                question["sequence_no"]: question for question in detail.get("questions", [])
            }
            for sequence, (kind, prompt, grading) in enumerate(question_payloads(unit_no, local_seq, title), start=1):
                existing_question = questions_by_sequence.get(sequence)
                if existing_question:
                    request(
                        "PATCH",
                        f"/content/questions/{existing_question['id']}",
                        token=token,
                        body={
                            "question_kind": kind,
                            "sequence_no": sequence,
                            "prompt_payload": prompt,
                            "grading_payload": grading,
                        },
                    )
                else:
                    request(
                        "POST",
                        f"/content/lessons/{lesson['id']}/questions",
                        token=token,
                        body={
                            "lesson_id": lesson["id"],
                            "question_kind": kind,
                            "sequence_no": sequence,
                            "prompt_payload": prompt,
                            "grading_payload": grading,
                        },
                    )
                    created["questions"] += 1

    return created


def main():
    token = login()
    course = ensure_course(token)
    created = ensure_units_lessons_content(token, course)
    print("\nDone.")
    print(json.dumps({"course_id": course["id"], "course_code": course["code"], **created}, indent=2))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
