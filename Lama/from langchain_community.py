import ollama
import json
import re
import time
import requests
import base64
import zlib
from typing import Dict, Any, Optional

class RequirementsConverter:
    def __init__(self, model: str = 'llama3', temperature: float = 0.2):
        """
        Initialize the converter with specific model and generation parameters
        """
        self.model = model
        self.temperature = temperature
        self.max_retries = 3
        self.timeout = 60

    def clean_json_response(self, response: str) -> Optional[str]:
        """
        Advanced JSON cleaning and extraction
        """
        try:
            response = response.strip('```json\n').strip('```')
            
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

    def extract_requirements_from_transcript(self, transcript: str) -> Optional[Dict[str, Any]]:
        """
        Extract requirements from a conversation transcript
        """
        prompt = f"""Analyze the following conversation transcript and return ONLY a JSON object (no markdown or explanations) with the following structure:

Conversation Transcript:
{transcript}

RESPOND ONLY WITH THIS JSON STRUCTURE (no other text):
{{
  "project_name": "Mobile App for User Login and Sign Up",
  "functional_requirements": [
    {{
      "id": "FR001",
      "description": "login",
      "priority": "High",
      "actor": "User"
    }},
    {{
      "id": "FR002",
      "description": "signup",
      "priority": "High",
      "actor": "User"
    }},
    {{
      "id": "FR003",
      "description": "view dashboard",
      "priority": "High",
      "actor": "Admin"
    }}
  ],
  "non_functional_requirements": [
    {{
      "id": "NFR001",
      "category": "Security",
      "description": "High security levels for mobile app",
      "priority": "High"
    }}
  ],
  "actors": [
    {{
      "name": "User",
      "description": "Mobile app user",
      "type": "Primary"
    }},
    {{
      "name": "Admin",
      "description": "System administrator",
      "type": "Primary"
    }}
  ]
}}

IMPORTANT: Return ONLY the JSON object above, with no additional text, markdown, or explanations."""

        start_time = time.time()
        
        for attempt in range(self.max_retries):
            try:
                response = ollama.chat(
                    model=self.model,
                    messages=[{'role': 'user', 'content': prompt}],
                    options={
                        'temperature': self.temperature,
                        'num_predict': 1500,
                        'top_k': 20,
                        'top_p': 0.9
                    }
                )
                
                raw_response = response['message']['content']
                cleaned_response = self.clean_json_response(raw_response)
                
                if not cleaned_response:
                    print(f"Attempt {attempt + 1}: Failed to clean JSON")
                    continue
                
                requirements_json = json.loads(cleaned_response)
                self.validate_json_structure(requirements_json)
                
                end_time = time.time()
                print(f"Extraction completed in {end_time - start_time:.2f} seconds")
                
                return requirements_json
            
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                time.sleep(2)
        
        return None

    def validate_json_structure(self, json_data: Dict[str, Any]) -> None:
        """
        Validate JSON structure
        """
        required_keys = ['project_name', 'functional_requirements', 'non_functional_requirements', 'actors']
        for key in required_keys:
            if key not in json_data:
                raise ValueError(f"Missing required key: {key}")
        
        if not json_data['actors'] or not json_data['functional_requirements']:
            raise ValueError("Actors or Functional Requirements cannot be empty")
        
        for req in json_data['functional_requirements']:
            if 'actor' not in req:
                raise ValueError(f"Functional requirement {req['id']} missing actor field")

    def generate_plantuml(self, json_data: Dict[str, Any]) -> str:
        """
        Generate PlantUML use case diagram from JSON with proper actor-usecase relationships
        """
        plantuml = [
            "@startuml",
            "left to right direction",
            f"title {json_data['project_name']} Requirements Diagram",
            "skinparam usecase {",
            "    BackgroundColor LightBlue",
            "    BorderColor DarkBlue",
            "}",
            ""
        ]
        
        # Add actors
        for actor in json_data['actors']:
            plantuml.append(f"actor \"{actor['name']}\" as {actor['name'].replace(' ', '_')}")
        
        plantuml.append(f"\nrectangle \"{json_data['project_name']}\" {{")
        
        # Process use cases
        use_cases = {}
        for req in json_data['functional_requirements']:
            actor_name = req['actor'].replace(' ', '_')
            description = req['description'].lower()
            
            # Use the description directly as it should already be a simple action verb
            use_cases[req['id']] = {
                'description': description,
                'actor': actor_name
            }
        
        # Add use cases
        for use_case_id, use_case in use_cases.items():
            plantuml.append(f"    usecase \"{use_case['description']}\" as {use_case_id}")
        
        # Add relationships
        for actor in json_data['actors']:
            actor_id = actor['name'].replace(' ', '_')
            for use_case_id, use_case in use_cases.items():
                if use_case['actor'] == actor_id:
                    plantuml.append(f"    {actor_id} --> {use_case_id}")
        
        plantuml.append("}")
        plantuml.append("@enduml")
        
        return '\n'.join(plantuml)

    def generate_diagram_with_kroki(self, plantuml_code: str, output_file: str = 'diagram.png') -> bool:
        """
        Generate diagram using Kroki API
        """
        try:
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

def main():
    # Initialize converter
    converter = RequirementsConverter()
    
    # Example Transcript
    transcript = """
    I want user to be able to login and sign up using mobile app, the mobile app shall have high security levels and Finally i want a dashboard for the admin
    """
    
    # Extract requirements from transcript
    requirements_json = converter.extract_requirements_from_transcript(transcript)
    
    # Save and display results
    if requirements_json:
        # Save JSON
        with open('requirements.json', 'w', encoding='utf-8') as f:
            json.dump(requirements_json, f, indent=2, ensure_ascii=False)
        
        # Generate PlantUML
        plantuml_code = converter.generate_plantuml(requirements_json)
        
        # Save PlantUML code
        with open('use_case_diagram.puml', 'w', encoding='utf-8') as f:
            f.write(plantuml_code)
        
        # Generate diagram using Kroki
        converter.generate_diagram_with_kroki(plantuml_code, 'use_case_diagram.png')
        
        # Print results
        print("Extracted Requirements:")
        print(json.dumps(requirements_json, indent=2, ensure_ascii=False))
        print("\nPlantUML Diagram Code:")
        print(plantuml_code)
    else:
        print("Failed to extract requirements from transcript")

if __name__ == "__main__":
    main()