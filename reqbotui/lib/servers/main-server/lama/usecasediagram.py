import os
import ollama
import json
import re
import time
import requests
import base64
import zlib
from typing import Dict, Any, Optional



from google.cloud import storage
def upload_to_gcs(bucket_name, source_file_path, destination_blob_name):
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(source_file_path)
    print(f"Uploaded to: gs://{bucket_name}/{destination_blob_name}")
    return f"https://storage.googleapis.com/{bucket_name}/{destination_blob_name}"


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

    def extract_requirements_from_transcript(self, transcript: str) -> Optional[Dict[str, Any]]:
        """
        Extract requirements from a conversation transcript with comprehensive guidelines
        """
        prompt = f"""You are an expert Systems Analyst tasked with extracting precise requirements and creating a comprehensive use case diagram. 

GUIDELINES FOR REQUIREMENTS EXTRACTION:
1. Requirement Identification Rules:
   - Be extremely precise in capturing functional and non-functional requirements
   - Ensure each requirement is atomic and clearly defined
   - Prioritize requirements based on business value and complexity
   - Identify all potential actors, including primary and secondary users

2. Use Case Diagram Principles:
   - Capture all system interactions from the user's perspective
   - Use clear, action-oriented use case names
   - Ensure use cases represent complete, meaningful interactions
   - Distinguish between system boundaries and external actors
   - Avoid implementation details in use cases
   - When multiple actors share the same use case, it should be written once with multiple actors pointing to it

3. Handling Shared Use Cases:
   - For use cases that involve multiple actors, list all actors in the "actor" field as an array
   - For example: "actor": ["Customer", "System"] indicates both actors participate in this use case
   - This allows creating more accurate diagrams where multiple actors point to a single use case

4. Handling Complex Requirements:
   - Break down complex workflows into individual use cases
   - Identify dependencies between use cases
   - Capture both happy paths and exception paths
   - Ensure coverage of all scenarios mentioned in the transcript
   - For large systems, organize use cases into logical subsystems or modules

5. Naming Conventions:
   - Use verb-noun format for use cases (e.g., "Create Account", "Process Payment")
   - Use descriptive but concise actor names
   - Maintain consistency in terminology

INCLUDE AND EXTEND RELATIONSHIP GUIDELINES:
1. Identify Use Case Dependencies:
   - Look for mandatory sub-processes (<<include>> relationships)
   - Identify optional or conditional behaviors (<<extend>> relationships)

2. Include Relationship (<<include>>):
   - Mandatory sub-processes that ALWAYS occur
   - Cannot exist independently
   - Example: "Validate Payment" always included in "Process Order"

3. Extend Relationship (<<extend>>):
   - Optional or conditional behaviors
   - Add extra functionality under specific conditions
   - Example: "Apply Discount" might extend "Make Payment"

EXAMPLE SCENARIOS:

Example 1: E-Commerce Platform
{{
  "project_name": "Online Shopping Platform",
  "functional_requirements": [
    {{
      "id": "FR001",
      "description": "Browse Products",
      "priority": "High",
      "actor": ["Customer"]
    }},
    {{
      "id": "FR002",
      "description": "Process Order",
      "priority": "High",
      "actor": ["Customer"],
      "includes": [
        {{
          "use_case_id": "FR003",
          "description": "Validate Payment"
        }}
      ],
      "extends": [
        {{
          "use_case_id": "FR004",
          "description": "Apply Discount",
          "condition": "Eligible promotional offer"
        }}
      ]
    }}
  ],
  "non_functional_requirements": [
    {{
      "id": "NFR001",
      "category": "Performance",
      "description": "Page load time under 2 seconds",
      "priority": "High"
    }}
  ],
  "actors": [
    {{
      "name": "Customer",
      "description": "Registered user making purchases",
      "type": "Primary"
    }}
  ]
}}

Example 2: Hospital Management System
{{
  "project_name": "Hospital Patient Management System",
  "functional_requirements": [
    {{
      "id": "FR001",
      "description": "Register Patient",
      "priority": "High",
      "actor": ["Receptionist", "Patient"]
    }},
    {{
      "id": "FR002",
      "description": "Schedule Appointment",
      "priority": "High",
      "actor": ["Doctor", "Receptionist"]
    }}
  ],
  "non_functional_requirements": [
    {{
      "id": "NFR001",
      "category": "Security",
      "description": "HIPAA Compliance for Patient Data",
      "priority": "Critical"
    }}
  ],
  "actors": [
    {{
      "name": "Receptionist",
      "description": "Front desk staff managing patient intake",
      "type": "Primary"
    }},
    {{
      "name": "Doctor",
      "description": "Medical professional managing patient care",
      "type": "Primary"
    }},
    {{
      "name": "Patient",
      "description": "Person receiving medical care",
      "type": "Primary"
    }}
  ]
}}

Example 3: Online Banking System
{{
  "project_name": "Comprehensive Banking Platform",
  "functional_requirements": [
    {{
      "id": "FR001",
      "description": "Transfer Funds",
      "priority": "High",
      "actor": ["Customer"],
      "includes": [
        {{
          "use_case_id": "FR002",
          "description": "Verify Account Balance"
        }},
        {{
          "use_case_id": "FR003",
          "description": "Validate Recipient Account"
        }}
      ],
      "extends": [
        {{
          "use_case_id": "FR004",
          "description": "International Transfer",
          "condition": "Transfer to foreign bank"
        }}
      ]
    }}
  ],
  "non_functional_requirements": [
    {{
      "id": "NFR001",
      "category": "Security",
      "description": "Two-Factor Authentication",
      "priority": "Critical"
    }}
  ],
  "actors": [
    {{
      "name": "Customer",
      "description": "Bank account holder",
      "type": "Primary"
    }}
  ]
}}

Example 4: Travel Booking System
{{
  "project_name": "Comprehensive Travel Booking Platform",
  "functional_requirements": [
    {{
      "id": "FR001",
      "description": "Book Flight",
      "priority": "High",
      "actor": ["Traveler"],
      "includes": [
        {{
          "use_case_id": "FR002",
          "description": "Select Seat"
        }},
        {{
          "use_case_id": "FR003",
          "description": "Passenger Information Validation"
        }}
      ],
      "extends": [
        {{
          "use_case_id": "FR004",
          "description": "Add Travel Insurance",
          "condition": "Optional insurance selection"
        }},
        {{
          "use_case_id": "FR005",
          "description": "Upgrade Seat Class",
          "condition": "Available seat upgrades"
        }}
      ]
    }}
  ],
  "non_functional_requirements": [
    {{
      "id": "NFR001",
      "category": "Performance",
      "description": "Real-time seat availability",
      "priority": "High"
    }}
  ],
  "actors": [
    {{
      "name": "Traveler",
      "description": "Person booking a flight",
      "type": "Primary"
    }}
  ]
}}

Now, analyze the following conversation transcript and extract requirements following the above guidelines:

Conversation Transcript:
{transcript}

IMPORTANT: 
- Analyze the transcript thoroughly
- Apply the guidelines meticulously
- Return ONLY a valid JSON object
- Ensure comprehensive and precise requirements extraction"""

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
                
                requirements_json = json.loads(cleaned_response)
                
                # Ensure all actor fields are arrays
                for req in requirements_json['functional_requirements']:
                    if 'actor' in req and not isinstance(req['actor'], list):
                        req['actor'] = [req['actor']]
                
                self.validate_json_structure(requirements_json)
                
                end_time = time.time()
                print(f"Extraction completed in {end_time - start_time:.2f} seconds")
                
                return requirements_json
            
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                time.sleep(2)
        
        return None

    def generate_plantuml(self, json_data: Dict[str, Any]) -> str:
     """
     Generate PlantUML use case diagram with include and extend relationships
     """
     plantuml = [
        "@startuml",
        "left to right direction",
        f"title {json_data['project_name']} Requirements Diagram",
        "skinparam usecase {",
        "    BackgroundColor LightBlue",
        "    BorderColor DarkBlue",
        "    ArrowColor DarkGray",
        "    ActorBorderColor Navy",
        "}",
        ""
     ]
    
     # Add actors
     for actor in json_data['actors']:
        plantuml.append(f"actor \"{actor['name']}\" as {actor['name'].replace(' ', '_')}")
    
     plantuml.append(f"\nrectangle \"{json_data['project_name']}\" {{")
    
     # Process use cases with include and extend relationships
     for req in json_data['functional_requirements']:
        use_case_id = req['id']
        description = req['description']
        
        # Add use case
        plantuml.append(f"    usecase \"{description}\" as {use_case_id}")
        
        # Add include relationships
        if 'includes' in req:
            for include in req['includes']:
                # Create a new use case for the included process
                included_use_case_id = include['use_case_id']
                included_description = include['description']
                plantuml.append(f"    usecase \"{included_description}\" as {included_use_case_id}")
                
                # Add include relationship
                plantuml.append(f"    {use_case_id} ..> {included_use_case_id} : <<include>>")
        
        # Add extend relationships
        if 'extends' in req:
            for extend in req['extends']:
                extended_use_case_id = extend['use_case_id']
                extended_description = extend['description']
                
                # Create a new use case for the extended process
                plantuml.append(f"    usecase \"{extended_description}\" as {extended_use_case_id}")
                
                # Add extend relationship
                plantuml.append(f"    {extended_use_case_id} ..> {use_case_id} : <<extend>>\n    note right of {extended_use_case_id} : {extend.get('condition', 'Optional behavior')}")
        
        # Add relationships for actors
        actors = req['actor'] if isinstance(req['actor'], list) else [req['actor']]
        for actor_name in actors:
            actor_id = actor_name.replace(' ', '_')
            plantuml.append(f"    {actor_id} --> {use_case_id}")
    
     plantuml.append("}")
     plantuml.append("@enduml")
    
     return '\n'.join(plantuml)

    def generate_diagram_with_kroki(self, plantuml_code: str, pid : int ,output_dir="reqbotui/assets/images/") -> bool:
        """
        Generate diagram using Kroki API
        """
        try:
            output_file=f"{output_dir}use_case_diagram_{pid}.png"
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

def UseCasDiagramDriver(desc,pid):
    # Initialize converter
    converter = RequirementsConverter()
    
    # Complex Transcript for Software Development Lifecycle Management System
    transcript = desc
    
  #   """
  #  Software Development Lifecycle Management System Requirements

  #   Our enterprise-level platform aims to streamline and optimize the entire software development process, 
  #   providing comprehensive tools for requirement gathering, development, testing, and deployment.

  #   Key Workflow Components:

  #   1. Requirement Gathering Process:
  #      - Mandatory stakeholder analysis
  #      - Optional risk assessment for complex projects
  #      - Detailed documentation and traceability
  #      - Collaborative requirement refinement

  #   2. Feature Development Workflow:
  #      - Integrated code review process
  #      - Mandatory code quality checks
  #      - Optional performance optimization
  #      - Automated code style enforcement

  #   3. Testing and Quality Assurance:
  #      - Comprehensive test case generation
  #      - Mandatory regression testing
  #      - Optional security vulnerability scanning
  #      - Performance and load testing

  #   4. Deployment Pipeline:
  #      - Automated environment configuration
  #      - Continuous integration checks
  #      - Optional rollback strategy for critical deployments
  #      - Multi-environment support (dev, staging, production)

  #   5. Project Management Features:
  #      - Sprint planning and tracking
  #      - Resource allocation
  #      - Progress monitoring
  #      - Automated reporting

  #   Actors and Their Interactions:
  #   - Product Managers initiate and guide requirement gathering
  #   - Developers execute feature development
  #   - Testers perform comprehensive quality assurance
  #   - DevOps engineers manage deployment pipelines
  #   - Scrum Masters facilitate project management

  #   Additional Constraints:
  #   - Support for agile and hybrid methodologies
  #   - Seamless integration with existing tools
  #   - Robust access control and audit logging
  #   - Real-time collaboration capabilities
  #   """
    
    # Extract requirements from transcript
    requirements_json = converter.extract_requirements_from_transcript(transcript)
    
    # Save and display results
    if requirements_json:
        # Save JSON
        # with open(f"reqbotui/assets/jsons/use_case_diagram_{pid}.json", 'w', encoding='utf-8') as f:
        #     json.dump(requirements_json, f, indent=2, ensure_ascii=False)
        
        # # Generate PlantUML
        # plantuml_code = converter.generate_plantuml(requirements_json)
        
        # # Save PlantUML code
        # with open(f"reqbotui/assets/umls/database_diagram_{pid}.puml", 'w', encoding='utf-8') as f:
        #     f.write(plantuml_code)
        
        # # Generate diagram using Kroki
        # converter.generate_diagram_with_kroki(plantuml_code,pid)
        
        # # Print results
        # print("use case done")
        os.makedirs("/tmp/jsons", exist_ok=True)
        os.makedirs("/tmp/umls", exist_ok=True)
        os.makedirs("/tmp/images", exist_ok=True)
        json_path = f"/tmp/jsons/use_case_diagram_{pid}.json"
        puml_path = f"/tmp/umls/use_case_diagram_{pid}.puml"
        img_path = f"/tmp/images/use_case_diagram_{pid}.png"
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(requirements_json, f, indent=2, ensure_ascii=False)
        plantuml_code = converter.generate_plantuml(requirements_json)
        with open(puml_path, 'w', encoding='utf-8') as f:
            f.write(plantuml_code)
        converter.generate_diagram_with_kroki(plantuml_code,pid, output_dir="/tmp/images/")


        bucket_name = "diagrams-data"  # replace with your bucket
        json_url = upload_to_gcs(bucket_name, json_path, f"jsons/use_case_diagram_{pid}.json")
        puml_url = upload_to_gcs(bucket_name, puml_path, f"umls/use_case_diagram_{pid}.puml")
        png_url = upload_to_gcs(bucket_name, img_path, f"images/use_case_diagram_{pid}.png")

        print("use_case done")
        return {
            "pid": pid,
            "json": json_url,
            "puml": puml_url,
            "image_png": png_url,
        }
        # print("Extracted Requirements:")
        # print(json.dumps(requirements_json, indent=2, ensure_ascii=False))
        # print("\nPlantUML Diagram Code:")
        # print(plantuml_code)
    else:
        print("Failed to extract requirements from transcript")


