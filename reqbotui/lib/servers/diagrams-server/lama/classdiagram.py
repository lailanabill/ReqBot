import os
import ollama
import json
import re
import time
import requests
import base64
import zlib
from typing import Dict, Any, Optional, List, Union



from google.cloud import storage

def upload_to_gcs(bucket_name, source_file_path, destination_blob_name):
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(source_file_path)
    print(f"Uploaded to: gs://{bucket_name}/{destination_blob_name}")
    return f"https://storage.googleapis.com/{bucket_name}/{destination_blob_name}"

class ClassDiagramGenerator:
    def __init__(self, model: str = 'llama3', temperature: float = 0.2):
        """
        Initialize the generator with specific model and generation parameters
        """
        self.model = model
        self.temperature = temperature
        self.max_retries = 5
        self.timeout = 60

    def clean_json_response(self, response: str) -> Optional[str]:
        """
        Advanced JSON cleaning and extraction
        """
        try:
            response = response.strip('json\n').strip('')
            
            json_patterns = [
                r'\{.*\}',  
                r'\{.+\}',  
                r'(\{[\s\S]*\})'  
            ]
            
            for pattern in json_patterns:
                json_match = re.search(pattern, response, re.DOTALL | re.MULTILINE)
                if json_match:
                    cleaned_response = json_match.group(0)
                    json.loads(cleaned_response)
                    return cleaned_response
            
            raise ValueError("No valid JSON found")
        
        except Exception as e:
            print(f"JSON Cleaning Error: {e}")
            print("Original Response:", response)
            return None

    def validate_json_structure(self, json_data: Dict[str, Any]) -> None:
        """
        Validate JSON structure for class diagram
        """
        required_keys = ['system_name', 'classes']
        for key in required_keys:
            if key not in json_data:
                raise ValueError(f"Missing required key: {key}")
        
        if not json_data['classes']:
            raise ValueError("Classes cannot be empty")

        for class_def in json_data['classes']:
            if 'name' not in class_def or 'attributes' not in class_def or 'methods' not in class_def:
                raise ValueError(f"Class definition missing required fields")

    def safe_get_parameters(self, method: Dict[str, Any]) -> List[Dict[str, str]]:
        """
        Safely extract parameters from method, handling different possible formats
        """
        parameters = method.get('parameters', [])
        
        # If parameters is a string, try to parse it
        if isinstance(parameters, str):
            try:
                parameters = json.loads(parameters)
            except json.JSONDecodeError:
                parameters = []
        
        # Ensure each parameter is a dictionary with name and type
        safe_parameters = []
        for param in parameters:
            if isinstance(param, dict):
                safe_param = {
                    'name': param.get('name', 'unnamed'),
                    'type': param.get('type', 'Any')
                }
                safe_parameters.append(safe_param)
            elif isinstance(param, str):
                # If it's just a string, split it into name and type
                parts = param.split(':')
                safe_param = {
                    'name': parts[0].strip() if parts else 'unnamed',
                    'type': parts[1].strip() if len(parts) > 1 else 'Any'
                }
                safe_parameters.append(safe_param)
        
        return safe_parameters

    def extract_class_diagram_elements(self, description: str) -> Optional[Dict[str, Any]]:
        """
        Extract class diagram elements with comprehensive details
        """
        prompt = f"""You are an expert Software Architect tasked with creating a comprehensive Class Diagram.

GUIDELINES FOR CLASS DIAGRAM EXTRACTION:
1. Class Identification:
   - Identify all key classes in the system
   - Define clear responsibilities for each class
   - Include meaningful attributes and methods
2. Attribute Guidelines:
   - Specify data types for all attributes
   - Include appropriate access modifiers (public, private, protected)
3. Method Guidelines:
   - Define methods with clear purposes
   - Include parameters and return types
   - Use appropriate access modifiers
4. Relationship Guidelines:
   - Identify inheritance, association, aggregation relationships
   - Specify multiplicity where applicable

EXAMPLE OUTPUT:
{{
  "system_name": "University Course Registration System",
  "classes": [
    {{
      "name": "Student",
      "attributes": [
        {{
          "name": "studentId",
          "type": "String",
          "visibility": "private"
        }},
        {{
          "name": "name",
          "type": "String",
          "visibility": "private"
        }}
      ],
      "methods": [
        {{
          "name": "registerForCourse",
          "parameters": [
            {{
              "name": "courseCode",
              "type": "String"
            }}
          ],
          "return_type": "Boolean",
          "visibility": "public"
        }}
      ]
    }},
    {{
      "name": "Course",
      "attributes": [
        {{
          "name": "courseCode",
          "type": "String",
          "visibility": "private"
        }},
        {{
          "name": "title",
          "type": "String",
          "visibility": "private"
        }}
      ],
      "methods": [
        {{
          "name": "checkPrerequisites",
          "parameters": [
            {{
              "name": "student",
              "type": "Student"
            }}
          ],
          "return_type": "Boolean",
          "visibility": "public"
        }}
      ]
    }}
  ],
  "relationships": [
    {{
      "type": "association",
      "from": "Student",
      "to": "Course",
      "multiplicity": "0..*",
      "label": "registers for"
    }}
  ]
}}

Now, analyze the following system description and extract class diagram elements:

System Description:
{description}

IMPORTANT:
- Create a comprehensive class diagram representation
- Include all significant classes with their attributes and methods
- Identify and specify relationships between classes
- Return ONLY a valid JSON object
- Ensure thorough and meaningful class design"""

        start_time = time.time()
        
        for attempt in range(self.max_retries):
            try:
                response = ollama.chat(
                    model=self.model,
                    messages=[{'role': 'user', 'content': prompt}],
                    options={
                        'temperature': self.temperature,
                        'num_predict': 3500,
                        'top_k': 20,
                        'top_p': 0.9
                    }
                )
                
                raw_response = response['message']['content']
                cleaned_response = self.clean_json_response(raw_response)
                
                if not cleaned_response:
                    print(f"Attempt {attempt + 1}: Failed to clean JSON")
                    continue
                
                class_diagram_json = json.loads(cleaned_response)
                self.validate_json_structure(class_diagram_json)
                
                end_time = time.time()
                print(f"Extraction completed in {end_time - start_time:.2f} seconds")
                
                return class_diagram_json
            
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                time.sleep(2)
        
        return None

    def generate_plantuml(self, json_data: Dict[str, Any]) -> str:
        """
        Generate PlantUML class diagram code with robust parameter handling
        """
        plantuml = [
            "@startuml",
            f"title {json_data.get('system_name', 'Class Diagram')} Class Diagram",
            "skinparam classAttributeIconSize 0",
            "skinparam monochrome true",
            "skinparam class {",
            "    BackgroundColor White",
            "    BorderColor Black",
            "    ArrowColor Black",
            "}"
        ]

        # Generate classes
        for cls in json_data.get('classes', []):
            class_def = [f"class {cls['name']} {{"]
            
            # Add attributes
            for attr in cls.get('attributes', []):
                visibility = {"private": "-", "public": "+", "protected": "#"}.get(attr.get('visibility', 'private'), '-')
                class_def.append(f"  {visibility} {attr.get('name', 'unnamed')}: {attr.get('type', 'Any')}")
            
            # Add methods
            for method in cls.get('methods', []):
                visibility = {"private": "-", "public": "+", "protected": "#"}.get(method.get('visibility', 'public'), '+')
                
                # Safely get parameters
                safe_params = self.safe_get_parameters(method)
                
                # Format parameters
                params_str = ', '.join([f"{p['name']}: {p['type']}" for p in safe_params])
                
                # Add method to class definition
                class_def.append(f"  {visibility} {method.get('name', 'unnamed_method')}({params_str}): {method.get('return_type', 'void')}")
            
            class_def.append("}")
            plantuml.extend(class_def)

        # Generate relationships
        for rel in json_data.get('relationships', []):
            relation_type = rel.get('type', 'association')
            line_styles = {
                'inheritance': '▷',
                'association': '-->',
                'aggregation': 'o--',
                'composition': '*--'
            }
            line_style = line_styles.get(relation_type, '-->')
            
            plantuml.append(f"{rel.get('from', 'UnknownClass')} {line_style} {rel.get('to', 'UnknownClass')} : {rel.get('label', '')}")

        plantuml.append("@enduml")
        return '\n'.join(plantuml)

    def generate_diagram_with_kroki(self, plantuml_code: str, pid:int ,output_dir: str = 'reqbotui/assets/images/') -> bool:
        """
        Generate diagram using Kroki API
        """
        try:
            output_file = f"{output_dir}class_diagram_{pid}.png"
            kroki_url = "https://kroki.io/plantuml/png/"
            
            plantuml_encoded = base64.urlsafe_b64encode(
                zlib.compress(plantuml_code.encode('utf-8'), 9)
            ).decode('ascii')

            response = requests.get(f"{kroki_url}{plantuml_encoded}")

            if response.status_code == 200:
                with open(output_file, 'wb') as f:
                    f.write(response.content)
                print(f"Diagram successfully generated and saved as {output_file}")
                return True
            else:
                print(f"Failed to generate diagram. Status code: {response.status_code}")
                return False

        except Exception as e:
            print(f"Error generating diagram: {e}")
            return False

def ClassDiagramDriver(desc,pid):
    # Initialize generator
    generator = ClassDiagramGenerator(model='llama3')
    
    # System description as a meeting transcript
    description =desc
    
    # Extract class diagram elements
    class_diagram_json = generator.extract_class_diagram_elements(description)
    
    if class_diagram_json:
        # Save JSON
        os.makedirs("/jsons", exist_ok=True)
        os.makedirs("/umls", exist_ok=True)
        os.makedirs("/images", exist_ok=True)
        json_path = f"/jsons/class_diagram_{pid}.json"
        puml_path = f"/umls/class_diagram_{pid}.puml"
        img_path = f"/images/class_diagram_{pid}.png"


        # with open(f"reqbotui/assets/jsons/class_diagram_{pid}.json", 'w', encoding='utf-8') as f:
            # json.dump(class_diagram_json, f, indent=2, ensure_ascii=False)
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(class_diagram_json, f, indent=2, ensure_ascii=False)



        # Generate PlantUML
        # plantuml_code = generator.generate_plantuml(class_diagram_json)
        plantuml_code = generator.generate_plantuml(class_diagram_json)
        with open(puml_path, 'w', encoding='utf-8') as f:
            f.write(plantuml_code)
        # Save PlantUML code
        # with open(f"reqbotui/assets/umls/class_diagram_{pid}.puml", 'w', encoding='utf-8') as f:
            # f.write(plantuml_code)
        
        # Generate diagram using Kroki
        generator.generate_diagram_with_kroki(plantuml_code,pid, output_dir="/images/")
        
        # Print results
        # Upload to GCS
        bucket_name = "diagrams-data"  # replace with your bucket
        json_url = upload_to_gcs(bucket_name, json_path, f"jsons/class_diagram_{pid}.json")
        puml_url = upload_to_gcs(bucket_name, puml_path, f"umls/class_diagram_{pid}.puml")
        png_url = upload_to_gcs(bucket_name, img_path, f"images/class_diagram_{pid}.png")

        print("class done")
        return {
            "pid": pid,
            "json": json_url,
            "puml": puml_url,
            "image_png": png_url,
        }
    

        # print("Extracted Class Diagram Elements:")
        # print(json.dumps(class_diagram_json, indent=2, ensure_ascii=False))
        # print("\nPlantUML Diagram Code:")
        # print(plantuml_code)
    else:
        print("Failed to extract class diagram elements from description")



