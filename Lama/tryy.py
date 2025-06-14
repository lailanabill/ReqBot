# import os
# import requests

# all_urls={

# 'image_urls':{
#     "class_url": "https://storage.googleapis.com/diagrams-data/images/class_diagram_5.png",
#     "context_url": "https://storage.googleapis.com/diagrams-data/images/context_diagram_5.png",
#     "usecase_url": "https://storage.googleapis.com/diagrams-data/images/use_case_diagram_5.png",
#     "database_url": "https://storage.googleapis.com/diagrams-data/images/database_diagram_5.png",
#     "sequence_url": "https://storage.googleapis.com/diagrams-data/images/sequence_diagram_5.png",
# },
# 'json_urls':{
#     "class_url": "https://storage.googleapis.com/diagrams-data/jsons/class_diagram_5.json",
#     "context_url": "https://storage.googleapis.com/diagrams-data/jsons/context_diagram_5.json",
#     "usecase_url": "https://storage.googleapis.com/diagrams-data/jsons/use_case_diagram_5.json",
#     "database_url": "https://storage.googleapis.com/diagrams-data/jsons/database_diagram_5.json",
#     "sequence_url": "https://storage.googleapis.com/diagrams-data/jsons/sequence_diagram_5.json",
# },
# 'uml_urls':{
#     "class_url": "https://storage.googleapis.com/diagrams-data/umls/class_diagram_5.puml",
#     "context_url": "https://storage.googleapis.com/diagrams-data/umls/context_diagram_5.puml",
#     "usecase_url": "https://storage.googleapis.com/diagrams-data/umls/use_case_diagram_5.puml",
#     "database_url": "https://storage.googleapis.com/diagrams-data/umls/database_diagram_5.puml",
#     "sequence_url": "https://storage.googleapis.com/diagrams-data/umls/sequence_diagram_5.puml",
# }
# }

# ext_map = {
#     "image_urls": ("F:/collage/year 4/grad/github grad/ReqBot/reqbotui/assets/images/", "png"),
#     "json_urls": ("F:/collage/year 4/grad/github grad/ReqBot/reqbotui/assets/jsons", "json"),
#     "uml_urls": ("F:/collage/year 4/grad/github grad/ReqBot/reqbotui/assets/umls", "puml")
# }



# for dict_name, url_dict in all_urls.items():
#     folder, ext = ext_map[dict_name]
#     os.makedirs(folder, exist_ok=True)
    
#     for diagram_type, url in url_dict.items():
#         filename = os.path.join(folder, f"{diagram_type}_5.{ext}")
#         try:
#             r = requests.get(url)
#             if r.status_code == 200:
#                 with open(filename, "wb") as f:
#                     f.write(r.content)
#             else:
#                 print(f"Failed ({r.status_code}):")
#         except Exception as e:
#             print(f"Error downloading {e}")



import subprocess

meeting_text ="""
SPEAKER_02: We are building an appointment booking system.
SPEAKER_02: What features do we need?
SPEAKER_00: Users should be able to create an account, view available slots, and book appointments.
SPEAKER_00: A user can browse, search, book tickets for events, and the event organizer can create and manage event listing.
SPEAKER_02: Can they cancel or reschedule?
SPEAKER_00: Yes, and they should get email or SMS notifications for confirmations and reminders.
SPEAKER_01: What are non-functional requirements?
SPEAKER_00: It should be reliable, fast, and secure for handling personal data.
SPEAKER_00: But we also want to get to the previous appointments and be in customer service.
SPEAKER_00: Perfect.
"""
prompt = (
            
            f""""
            You are an expert technical software analyst, meeting assistant, and summarizer.

Your task is to generate a detailed, context-aware summary of the following software development meeting.

The summary must:

- Preserve speaker roles and their specific contributions (use names and roles clearly).
- Include all key decisions made, problems raised, solutions proposed, technical updates, and assigned actions.
- Maintain the logical flow of the meeting.
- Group related topics by theme (e.g., Task Management, Notifications, UX, Performance, Sprint Planning).
- Include backend, frontend, QA, UX, and project management updates, including technical improvements such as refactoring, modularization, and error handling.
- Highlight both hard and soft aspects: implementation details, design standards (e.g., UI/UX modals), documentation plans, Jira updates, and sprint goals or deadlines.
- Avoid summarizing away details that may be useful for downstream software requirement extraction.

Style Guidelines:

- Use bullet points or nested lists grouped by topic for clarity.
- Keep the summary factual — do not rephrase into requirement-style or interpretations.
- Do not omit important context such as technical constraints, timing (e.g., deadlines), component interactions, or rationale for decisions.
- Write only the summary, no introductory or closing text.
- Do not group into sections.

Meeting Transcript:
{meeting_text}

            """
        )

response = subprocess.run(
    ["ollama", "run", "llama3", "temperature ", "0.7" ,"keep-alive","0"],
    input=prompt.encode(),
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
)
output = response.stdout.decode()

print(output)