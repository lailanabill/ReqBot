# import ollama
# import json
# import re
# import time
# from typing import Dict, Any, Optional

# class RequirementsConverter:
#     def __init__(self, model: str = 'llama3', temperature: float = 0.2):
#         """
#         Initialize the converter with specific model and generation parameters
#         """
#         self.model = model
#         self.temperature = temperature
#         self.max_retries = 3
#         self.timeout = 60

#     def clean_json_response(self, response: str) -> Optional[str]:
#         """
#         Advanced JSON cleaning and extraction
#         """
#         try:
#             response = response.strip('json\n').strip('')
            
#             json_patterns = [
#                 r'\{.*\}',  
#                 r'\{.+\}',  
#                 r'(\{[\s\S]*\})'  
#             ]
            
#             for pattern in json_patterns:
#                 json_match = re.search(pattern, response, re.DOTALL | re.MULTILINE)
#                 if json_match:
#                     cleaned_response = json_match.group(0)
                    
#                     json.loads(cleaned_response)
#                     return cleaned_response
            
#             raise ValueError("No valid JSON found")
        
#         except Exception as e:
#             print(f"JSON Cleaning Error: {e}")
#             print("Original Response:", response)
#             return None

#     def extract_requirements_from_transcript(self, transcript: str) -> Optional[Dict[str, Any]]:
#         """
#         Extract requirements from a conversation transcript
#         """
#         prompt = f"""Analyze the following conversation transcript and extract both functional 
#         and non-functional requirements in a structured JSON format:

# Conversation Transcript:
# {transcript}

# Extraction Guidelines:
# 1. Identify the project or system being discussed
# 2. Extract functional requirements (what the system should do)
# 3. Extract non-functional requirements (quality attributes, constraints)
# 4. Identify potential actors/users
# 5. Provide a comprehensive and structured representation

# Expected JSON Structure:
# {{
#   "project_name": "Project Name",
#   "functional_requirements": [
#     {{
#       "id": "FR001",
#       "description": "Functional requirement description",
#       "priority": "High/Medium/Low"
#     }}
#   ],
#   "non_functional_requirements": [
#     {{
#       "id": "NFR001",
#       "category": "Performance/Security/Usability/etc.",
#       "description": "Non-functional requirement description",
#       "priority": "High/Medium/Low"
#     }}
#   ],
#   "actors": [
#     {{
#       "name": "Actor Name",
#       "description": "Actor role description",
#       "type": "Primary/Secondary"
#     }}
#   ]
# }}

# Provide a detailed and comprehensive analysis of the requirements."""
    
#         start_time = time.time()
        
#         for attempt in range(self.max_retries):
#             try:
#                 # Ollama chat generation
#                 response = ollama.chat(
#                     model=self.model,
#                     messages=[{'role': 'user', 'content': prompt}],
#                     options={
#                         'temperature': self.temperature,
#                         'num_predict': 1500,  # Increased token limit
#                         'top_k': 20,
#                         'top_p': 0.9
#                     }
#                 )
                
#                 # Extract and clean response
#                 raw_response = response['message']['content']
#                 cleaned_response = self.clean_json_response(raw_response)
                
#                 if not cleaned_response:
#                     print(f"Attempt {attempt + 1}: Failed to clean JSON")
#                     continue
                
#                 # Parse JSON
#                 requirements_json = json.loads(cleaned_response)
                
#                 # Validate JSON structure
#                 self.validate_json_structure(requirements_json)
                
#                 end_time = time.time()
#                 print(f"Extraction completed in {end_time - start_time:.2f} seconds")
                
#                 return requirements_json
            
#             except Exception as e:
#                 print(f"Attempt {attempt + 1} failed: {e}")
#                 time.sleep(2)  # Wait between retries
        
#         return None

#     def validate_json_structure(self, json_data: Dict[str, Any]) -> None:
#         """
#         Validate JSON structure
#         """
#         required_keys = ['project_name', 'functional_requirements', 'non_functional_requirements', 'actors']
#         for key in required_keys:
#             if key not in json_data:
#                 raise ValueError(f"Missing required key: {key}")
        
#         if not json_data['actors'] or not json_data['functional_requirements']:
#             raise ValueError("Actors or Functional Requirements cannot be empty")

#     def generate_plantuml(self, json_data: Dict[str, Any]) -> str:
#         """
#         Generate PlantUML use case diagram from JSON
#         """
#         plantuml = [
#             "@startuml",
#             "left to right direction",
#             f"title {json_data['project_name']} Requirements Diagram",
#             ""
#         ]
        
#         # Add actors
#         for actor in json_data['actors']:
#             plantuml.append(f"actor \"{actor['name']}\" as {actor['name'].replace(' ', '')}")
        
#         plantuml.append(f"\nrectangle \"{json_data['project_name']}\" {{")
        
#         # Add functional requirements as use cases
#         for req in json_data['functional_requirements']:
#             plantuml.append(f"    usecase \"{req['description']}\" as {req['id']}")
        
#         # Add relationships (simple version)
#         for actor in json_data['actors']:
#             for req in json_data['functional_requirements']:
#                 plantuml.append(f"    {actor['name'].replace(' ', '')} --> {req['id']}")
        
#         plantuml.append("}")
#         plantuml.append("@enduml")
        
#         return '\n'.join(plantuml)

# def main():
#     # Initialize converter
#     converter = RequirementsConverter()
    
#     # Example Transcript
#     transcript = """
#     I want user to be able to login and sign up using mobile app, the mobile app shall have high security levels and finally I want a dashboard for the admin
#     """
    
#     # Extract requirements from transcript
#     requirements_json = converter.extract_requirements_from_transcript(transcript)
    
#     # Save and display results
#     if requirements_json:
#         # Save JSON
#         with open('library_system_requirements.json', 'w', encoding='utf-8') as f:
#             json.dump(requirements_json, f, indent=2, ensure_ascii=False)
        
#         # Generate PlantUML
#         plantuml_code = converter.generate_plantuml(requirements_json)
#         with open('use_case_diagram.puml', 'w', encoding='utf-8') as f:
#             f.write(plantuml_code)
        
#         # Print results
#         print("Extracted Requirements:")
#         print(json.dumps(requirements_json, indent=2, ensure_ascii=False))
#         print("\nPlantUML Diagram Code:")
#         print(plantuml_code)
#     else:
#         print("Failed to extract requirements from transcript")

# if __name__ == "__main__":
#     main()