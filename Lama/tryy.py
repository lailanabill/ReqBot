import os
import requests

all_urls={

'image_urls':{
    "class_url": "https://storage.googleapis.com/diagrams-data/images/class_diagram_5.png",
    "context_url": "https://storage.googleapis.com/diagrams-data/images/context_diagram_5.png",
    "usecase_url": "https://storage.googleapis.com/diagrams-data/images/use_case_diagram_5.png",
    "database_url": "https://storage.googleapis.com/diagrams-data/images/database_diagram_5.png",
    "sequence_url": "https://storage.googleapis.com/diagrams-data/images/sequence_diagram_5.png",
},
'json_urls':{
    "class_url": "https://storage.googleapis.com/diagrams-data/jsons/class_diagram_5.json",
    "context_url": "https://storage.googleapis.com/diagrams-data/jsons/context_diagram_5.json",
    "usecase_url": "https://storage.googleapis.com/diagrams-data/jsons/use_case_diagram_5.json",
    "database_url": "https://storage.googleapis.com/diagrams-data/jsons/database_diagram_5.json",
    "sequence_url": "https://storage.googleapis.com/diagrams-data/jsons/sequence_diagram_5.json",
},
'uml_urls':{
    "class_url": "https://storage.googleapis.com/diagrams-data/umls/class_diagram_5.puml",
    "context_url": "https://storage.googleapis.com/diagrams-data/umls/context_diagram_5.puml",
    "usecase_url": "https://storage.googleapis.com/diagrams-data/umls/use_case_diagram_5.puml",
    "database_url": "https://storage.googleapis.com/diagrams-data/umls/database_diagram_5.puml",
    "sequence_url": "https://storage.googleapis.com/diagrams-data/umls/sequence_diagram_5.puml",
}
}

ext_map = {
    "image_urls": ("F:/collage/year 4/grad/github grad/ReqBot/reqbotui/assets/images/", "png"),
    "json_urls": ("F:/collage/year 4/grad/github grad/ReqBot/reqbotui/assets/jsons", "json"),
    "uml_urls": ("F:/collage/year 4/grad/github grad/ReqBot/reqbotui/assets/umls", "puml")
}



for dict_name, url_dict in all_urls.items():
    folder, ext = ext_map[dict_name]
    os.makedirs(folder, exist_ok=True)
    
    for diagram_type, url in url_dict.items():
        filename = os.path.join(folder, f"{diagram_type}_5.{ext}")
        try:
            r = requests.get(url)
            if r.status_code == 200:
                with open(filename, "wb") as f:
                    f.write(r.content)
            else:
                print(f"Failed ({r.status_code}):")
        except Exception as e:
            print(f"Error downloading {e}")