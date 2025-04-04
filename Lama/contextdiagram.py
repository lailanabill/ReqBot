import ollama
import json
import re
import time
import requests
import base64
import zlib
from typing import Dict, Any, Optional

class ContextDiagramGenerator:
    def __init__(self, model: str = 'llama2', temperature: float = 0.2):
        self.model = model
        self.temperature = temperature
        self.max_retries = 5
        self.timeout = 60

    def clean_json_response(self, response: str) -> Optional[str]:
        try:
            response = response.strip('```json\n').strip('```')
            json_patterns = [r'\{.*\}', r'\{.+\}', r'(\{[\s\S]*\})']
            for pattern in json_patterns:
                json_match = re.search(pattern, response, re.DOTALL | re.MULTILINE)
                if json_match:
                    cleaned_response = json_match.group(0)
                    json.loads(cleaned_response)
                    return cleaned_response
            raise ValueError("No valid JSON found")
        except Exception as e:
            print(f"JSON Cleaning Error: {e}")
            return None

    def validate_json_structure(self, json_data: Dict[str, Any]) -> None:
        required_keys = ['system_name', 'external_entities', 'data_flows']
        for key in required_keys:
            if key not in json_data:
                raise ValueError(f"Missing required key: {key}")
        
        if not json_data['external_entities'] or not json_data['data_flows']:
            raise ValueError("External entities or data flows cannot be empty")

    def generate_plantuml(self, json_data: Dict[str, Any]) -> str:
        plantuml = [
            "@startuml",
            "",
            "' Style settings",
            "skinparam backgroundColor white",
            "skinparam handwritten false",
            "",
            "' Circle style for system",
            "circle \"" + json_data['system_name'] + "\" as System",
            "",
            "' External entities as simple rectangles"
        ]

        # Add external entities as simple rectangles
        for entity in json_data['external_entities']:
            plantuml.append(f"rectangle \"{entity['name']}\" as {entity['id']}")

        plantuml.append("")
        plantuml.append("' Data Flows")

        # Add data flows
        for flow in json_data['data_flows']:
            source = flow['from'] if flow['from'] != "System" else "System"
            target = flow['to'] if flow['to'] != "System" else "System"
            plantuml.append(f"{source} --> {target}: {flow['description']}")

        plantuml.append("")
        plantuml.append("@enduml")
        return '\n'.join(plantuml)

    def generate_diagram_with_kroki(self, plantuml_code: str, output_file: str = 'context_diagram.png') -> bool:
        try:
            kroki_url = "https://kroki.io/plantuml/png/"
            plantuml_encoded = base64.urlsafe_b64encode(
                zlib.compress(plantuml_code.encode('utf-8'), 9)
            ).decode('ascii')

            response = requests.get(f"{kroki_url}{plantuml_encoded}")
            
            if response.status_code == 200:
                with open(output_file, 'wb') as f:
                    f.write(response.content)
                print(f"Diagram saved as {output_file}")
                return True
            else:
                print(f"Generation failed. Status: {response.status_code}")
                return False
        except Exception as e:
            print(f"Error: {e}")
            return False

def main():
    # Test data with simplified structure
    test_data = {
        "system_name": "University Course Registration System",
        "external_entities": [
            {
                "id": "Student",
                "name": "Student",
                "description": "University students"
            },
            {
                "id": "Faculty",
                "name": "Faculty",
                "description": "Teaching staff"
            },
            {
                "id": "RegistrarOffice",
                "name": "Registrar's Office",
                "description": "Administration"
            },
            {
                "id": "PaymentGateway",
                "name": "Payment Gateway",
                "description": "Payment processing"
            },
            {
                "id": "EmailService",
                "name": "Email Service",
                "description": "Notifications"
            },
            {
                "id": "AcademicDB",
                "name": "Academic Database",
                "description": "Records storage"
            }
        ],
        "data_flows": [
            {
                "id": "DF1",
                "from": "Student",
                "to": "System",
                "description": "Course Selections"
            },
            {
                "id": "DF2",
                "from": "System",
                "to": "Student",
                "description": "Schedule Information"
            },
            {
                "id": "DF3",
                "from": "Faculty",
                "to": "System",
                "description": "Course Materials"
            },
            {
                "id": "DF4",
                "from": "System",
                "to": "Faculty",
                "description": "Enrollment Data"
            },
            {
                "id": "DF5",
                "from": "System",
                "to": "RegistrarOffice",
                "description": "Registration Records"
            },
            {
                "id": "DF6",
                "from": "System",
                "to": "PaymentGateway",
                "description": "Tuition Fees"
            },
            {
                "id": "DF7",
                "from": "PaymentGateway",
                "to": "System",
                "description": "Payment Confirmation"
            },
            {
                "id": "DF8",
                "from": "System",
                "to": "EmailService",
                "description": "Registration Confirmations"
            },
            {
                "id": "DF9",
                "from": "System",
                "to": "AcademicDB",
                "description": "Student Records"
            },
            {
                "id": "DF10",
                "from": "AcademicDB",
                "to": "System",
                "description": "Student Information"
            }
        ]
    }

    # Alternative test data for a simpler diagram
    simple_test_data = {
        "system_name": "Course Registration System",
        "external_entities": [
            {"id": "Student", "name": "Student", "description": ""},
            {"id": "Faculty", "name": "Faculty", "description": ""},
            {"id": "Admin", "name": "Admin", "description": ""}
        ],
        "data_flows": [
            {"id": "DF1", "from": "Student", "to": "System", "description": "Registration Data"},
            {"id": "DF2", "from": "System", "to": "Student", "description": "Schedule Data"},
            {"id": "DF3", "from": "Faculty", "to": "System", "description": "Course Data"},
            {"id": "DF4", "from": "System", "to": "Admin", "description": "Reports"}
        ]
    }

    generator = ContextDiagramGenerator()
    
    # Generate PlantUML code (use test_data or simple_test_data)
    plantuml_code = generator.generate_plantuml(test_data)
    
    # Save PlantUML code
    with open('context_diagram.puml', 'w', encoding='utf-8') as f:
        f.write(plantuml_code)
    
    # Generate diagram
    success = generator.generate_diagram_with_kroki(plantuml_code)
    
    if success:
        print("Diagram generated successfully!")
    else:
        print("Failed to generate diagram")
    
    print("\nPlantUML Code:")
    print(plantuml_code)

if __name__ == "__main__":
    main()