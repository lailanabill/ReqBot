import ollama
import json
import re
import time
import requests
import base64
import zlib
from typing import Dict, Any, Optional, List

class DiagramUrlGenerator:
    @staticmethod
    def generate_kroki_url(diagram_type: str, diagram_code: str, output_format: str = 'png') -> str:
        """Generate Kroki URL for diagram generation"""
        try:
            encoded_text = base64.urlsafe_b64encode(
                zlib.compress(diagram_code.encode('utf-8'))
            ).decode('ascii')
            
            kroki_url = f"https://kroki.io/{diagram_type}/{output_format}/{encoded_text}"
            return kroki_url
        except Exception as e:
            print(f"Kroki URL generation error: {e}")
            return None

class DatabaseClassDiagramGenerator:
    def __init__(self, model: str = 'llama3', temperature: float = 0.2):
        self.model = model
        self.temperature = temperature
        self.max_retries = 5
        self.timeout = 60
        self.url_generator = DiagramUrlGenerator()

    def extract_database_schema_elements(self, description: str) -> Optional[Dict[str, Any]]:
        prompt = f"""You are an expert Database Architect designing a comprehensive Class-based Database Schema.

CRITICAL REQUIREMENTS:
1. RETURN A COMPLETE, VALID JSON OBJECT
2. INCLUDE ALL TABLES AS CLASSES WITH MEANINGFUL RELATIONSHIPS
3. NO ISOLATED CLASSES
4. USE PRECISE, DESCRIPTIVE ATTRIBUTES AND METHODS

JSON STRUCTURE TEMPLATE:
{{
  "system_name": "University Course Registration Database",
  "classes": [
    {{
      "name": "Student",
      "description": "Represents a student in the system",
      "attributes": [
        {{
          "name": "studentId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "name",
          "type": "String",
          "is_nullable": false
        }}
      ],
      "methods": [
        {{
          "name": "registerForCourse",
          "parameters": [
            {{
              "name": "courseId",
              "type": "String"
            }}
          ],
          "return_type": "boolean"
        }}
      ]
    }}
  ],
  "relationships": [
    {{
      "type": "one_to_many",
      "from_class": "Student",
      "to_class": "Course",
      "description": "Student enrolls in multiple courses"
    }}
  ]
}}

System Description:
{description}"""

        for attempt in range(self.max_retries):
            try:
                response = ollama.chat(
                    model=self.model,
                    messages=[{'role': 'user', 'content': prompt}],
                    options={
                        'temperature': self.temperature,
                        'num_predict': 4000,
                        'top_k': 20,
                        'top_p': 0.9
                    }
                )
                
                raw_response = response['message']['content']
                cleaned_response = self.clean_json_response(raw_response)
                
                if cleaned_response:
                    return json.loads(cleaned_response)
                
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                time.sleep(2)
        
        return None

    def clean_json_response(self, response: str) -> Optional[str]:
        def extract_json(text):
            patterns = [
                r'\{.*"system_name".*"classes".*\}',
                r'```json(.*?)```',
                r'\{.*\}'
            ]
            
            for pattern in patterns:
                try:
                    match = re.search(pattern, text, re.DOTALL | re.MULTILINE)
                    if match:
                        json_str = match.group(1) if len(match.groups()) > 0 else match.group(0)
                        return json_str.strip()
                except Exception:
                    continue
            return None

        try:
            cleaned_json_str = extract_json(response)
            if not cleaned_json_str:
                return None

            # Remove any non-JSON content
            cleaned_json_str = re.sub(r'```.*?```', '', cleaned_json_str, flags=re.DOTALL)
            cleaned_json_str = cleaned_json_str.strip()

            # Validate JSON structure
            parsed_json = json.loads(cleaned_json_str)
            return json.dumps(parsed_json)

        except Exception as e:
            print(f"JSON cleaning error: {e}")
            return None

    def generate_plantuml(self, json_data: Dict[str, Any]) -> str:
        """Generate PlantUML class diagram code"""
        plantuml = [
            "@startuml",
            "skinparam class {",
            "    BackgroundColor White",
            "    BorderColor Black",
            "    ArrowColor Black",
            "}",
            "skinparam classAttributeIconSize 0",
            f"title {json_data.get('system_name', 'Database Schema')} Class Diagram"
        ]

        # Generate classes
        for cls in json_data.get('classes', []):
            class_def = [f"class {cls['name']} {{"]
            
            # Add description as note
            if 'description' in cls:
                class_def.extend([
                    f".. {cls['description']} ..",
                    ""
                ])
            
            # Add attributes
            for attr in cls.get('attributes', []):
                visibility = "+" if attr.get('is_primary_key') else "-"
                attr_str = f"{visibility} {attr.get('name')}: {attr.get('type')}"
                
                constraints = []
                if attr.get('is_primary_key'):
                    constraints.append("PK")
                if not attr.get('is_nullable', True):
                    constraints.append("NOT NULL")
                
                if constraints:
                    attr_str += f" {{{', '.join(constraints)}}}"
                
                class_def.append(attr_str)
            
            # Add methods
            class_def.append("")  # Empty line before methods
            for method in cls.get('methods', []):
                params = method.get('parameters', [])
                params_str = ", ".join([f"{p['name']}: {p['type']}" for p in params])
                method_str = f"+ {method['name']}({params_str}): {method.get('return_type', 'void')}"
                class_def.append(method_str)
            
            class_def.append("}")
            plantuml.extend(class_def)

        # Generate relationships
        for rel in json_data.get('relationships', []):
            if rel.get('type') == 'one_to_many':
                arrow_style = "\"1\" *-- \"*\""
            elif rel.get('type') == 'many_to_one':
                arrow_style = "\"*\" --* \"1\""
            elif rel.get('type') == 'one_to_one':
                arrow_style = "\"1\" -- \"1\""
            else:
                arrow_style = "\"*\" -- \"*\""
            
            plantuml.append(
                f"{rel.get('from_class')} {arrow_style} {rel.get('to_class')} : {rel.get('description', '')}"
            )

        plantuml.append("@enduml")
        return '\n'.join(plantuml)

    def generate_diagram(self, plantuml_code: str,  output_file: str = 'reqbotui/assets/images/database_diagram.png') -> bool:
        """Generate diagram using Kroki"""
        try:
            kroki_url = self.url_generator.generate_kroki_url('plantuml', plantuml_code, 'png')
            
            if not kroki_url:
                return False
            
            response = requests.get(kroki_url)
            
            if response.status_code == 200:
                with open(output_file, 'wb') as f:
                    f.write(response.content)
                
                with open('database_diagram.puml', 'w', encoding='utf-8') as f:
                    f.write(plantuml_code)
                
                print(f"Class diagram saved as {output_file}")
                return True
            else:
                print(f"Failed to generate diagram. Status code: {response.status_code}")
                return False
            
        except Exception as e:
            print(f"Error generating diagram: {e}")
            return False

def main():
    # Initialize generator
    generator = DatabaseClassDiagramGenerator(model='llama3')
    
    # System description
    description = """
    Meeting Transcript: University Course Registration System Discussion

    Team Lead (Alex): We need to design a comprehensive database schema for our University Course Registration System.

    Database Architect (Sam): We'll need tables for Students, Courses, Enrollments, and Faculty.

    Team Lead (Alex): Great. Students should have unique identifiers, personal information, and enrollment history.

    Analyst (Jordan): Courses need details like course code, title, department, and capacity. Faculty members will be assigned to teach specific courses.

    Designer (Priya): We'll create an Enrollments table to manage the relationship between students and courses, and ensure faculty are linked to their assigned courses.

    Team Lead (Alex): Exactly. We want to track which faculty members are teaching which courses, and how students are enrolled in those courses.
    """
    
    # Generate class diagram
    class_diagram_json = generator.extract_database_schema_elements(description)
    
    if class_diagram_json:
        # Save JSON
        with open('database_class_diagram.json', 'w', encoding='utf-8') as f:
            json.dump(class_diagram_json, f, indent=2, ensure_ascii=False)
        
        # Generate and save diagram
        plantuml_code = generator.generate_plantuml(class_diagram_json)
        generator.generate_diagram(plantuml_code)
        
        # Print results
        print("Generated Class Diagram Elements:")
        print(json.dumps(class_diagram_json, indent=2, ensure_ascii=False))
        print("\nPlantUML Class Diagram Code:")
        print(plantuml_code)
    else:
        print("Failed to generate class diagram")

if __name__ == "__main__":
    main()