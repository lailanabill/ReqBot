import ollama
import json
import re
import time
import requests  # Added for Kroki API
import base64    # Added for Kroki API
import zlib      # Added for Kroki API
from typing import Dict, Any, Optional

class ContextDiagramGenerator:
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
        Validate JSON structure for context diagram
        """
        required_keys = ['system_name', 'external_entities', 'data_flows']
        for key in required_keys:
            if key not in json_data:
                raise ValueError(f"Missing required key: {key}")
        
        if not json_data['external_entities'] or not json_data['data_flows']:
            raise ValueError("External entities or data flows cannot be empty")

    def extract_context_elements(self, description: str) -> Optional[Dict[str, Any]]:
        """
        Extract context diagram elements with clear, action-oriented labels
        """
        prompt = f"""You are an expert Systems Analyst tasked with identifying elements for a Context Diagram in the style of a single central system (as a circle) surrounded by external entities (as rectangles), with separate arrows for each direction of data flow and clear, action-oriented labels.

GUIDELINES FOR CONTEXT DIAGRAM EXTRACTION:
1. System Identification:
   - Identify the main system as the central process
   - Define clear system boundaries
   - The system must be the only circle in the diagram
2. External Entity Identification:
   - Identify all external entities (users, other systems, organizations) interacting with the system
   - Each entity must have meaningful interactions
   - All external entities must be represented as rectangles (no circles)
3. Data Flow Guidelines:
   - Identify data flows between external entities and the system
   - Specify direction of data flow (to/from system)
   - Use clear, action-oriented labels for data flows that describe what the flow does (e.g., "Submit Registration Data" instead of "Registration", "Provide Information & Tools" instead of "Information & Tools")
   - Represent each direction of data flow as a separate arrow (e.g., "A to System" and "System to A" should be two separate flows)
   - Ensure all significant data exchanges are captured

OUTPUT FORMAT:
{{
  "system_name": "System Name",
  "external_entities": [
    {{
      "id": "EE1",
      "name": "Entity Name",
      "description": "Entity description"
    }}
  ],
  "data_flows": [
    {{
      "id": "DF1",
      "from": "Source",
      "to": "Target",
      "description": "Clear, action-oriented data flow description"
    }}
  ]
}}

Here are 8 examples to guide you, emphasizing a single central circle, external rectangles, and clear, action-oriented labels:

EXAMPLE 1 (Inspired by the Online Community System diagram):
Description: "An Online Community System where Community Users register and access information and tools, Staff Writers provide content, Advertisers pay for ad slots, and Accountants receive financial reports."
Output:
{{
  "system_name": "Online Community System",
  "external_entities": [
    {{
      "id": "EE1",
      "name": "Community Users",
      "description": "Users who register and access information and tools"
    }},
    {{
      "id": "EE2",
      "name": "Staff Writers",
      "description": "Writers providing content for the community"
    }},
    {{
      "id": "EE3",
      "name": "Advertisers",
      "description": "Entities paying for ad slots"
    }},
    {{
      "id": "EE4",
      "name": "Accountants",
      "description": "Staff receiving financial reports"
    }}
  ],
  "data_flows": [
    {{
      "id": "DF1",
      "from": "Community Users",
      "to": "System",
      "description": "Submit Registration Data"
    }},
    {{
      "id": "DF2",
      "from": "System",
      "to": "Community Users",
      "description": "Provide Information & Tools"
    }},
    {{
      "id": "DF3",
      "from": "Staff Writers",
      "to": "System",
      "description": "Submit Content"
    }},
    {{
      "id": "DF4",
      "from": "System",
      "to": "Staff Writers",
      "description": "Send Compensation Details"
    }},
    {{
      "id": "DF5",
      "from": "Advertisers",
      "to": "System",
      "description": "Make Payments for Ads"
    }},
    {{
      "id": "DF6",
      "from": "System",
      "to": "Advertisers",
      "description": "Allocate Ad Slots"
    }},
    {{
      "id": "DF7",
      "from": "System",
      "to": "Accountants",
      "description": "Send Financial Reports"
    }},
    {{
      "id": "DF8",
      "from": "Accountants",
      "to": "System",
      "description": "Provide Financial Data"
    }}
  ]
}}

EXAMPLE 2:
Description: "A Library Management System allows patrons to borrow books and librarians to manage inventory. It connects to an Email Service for notifications."
Output:
{{
  "system_name": "Library Management System",
  "external_entities": [
    {{
      "id": "EE1",
      "name": "Patron",
      "description": "Users who borrow books"
    }},
    {{
      "id": "EE2",
      "name": "Librarian",
      "description": "Staff managing book inventory"
    }},
    {{
      "id": "EE3",
      "name": "Email Service",
      "description": "External service for sending notifications"
    }}
  ],
  "data_flows": [
    {{
      "id": "DF1",
      "from": "Patron",
      "to": "System",
      "description": "Submit Borrow Requests"
    }},
    {{
      "id": "DF2",
      "from": "System",
      "to": "Patron",
      "description": "Send Borrow Confirmations"
    }},
    {{
      "id": "DF3",
      "from": "Librarian",
      "to": "System",
      "description": "Update Inventory Data"
    }},
    {{
      "id": "DF4",
      "from": "System",
      "to": "Librarian",
      "description": "Provide Inventory Reports"
    }},
    {{
      "id": "DF5",
      "from": "System",
      "to": "Email Service",
      "description": "Send Notification Requests"
    }}
  ]
}}

EXAMPLE 3:
Description: "An E-commerce Platform where customers place orders and suppliers fulfill them. It integrates with a Payment Gateway."
Output:
{{
  "system_name": "E-commerce Platform",
  "external_entities": [
    {{
      "id": "EE1",
      "name": "Customer",
      "description": "Users purchasing products"
    }},
    {{
      "id": "EE2",
      "name": "Supplier",
      "description": "Entities providing products"
    }},
    {{
      "id": "EE3",
      "name": "Payment Gateway",
      "description": "External payment processing service"
    }}
  ],
  "data_flows": [
    {{
      "id": "DF1",
      "from": "Customer",
      "to": "System",
      "description": "Place Orders"
    }},
    {{
      "id": "DF2",
      "from": "System",
      "to": "Customer",
      "description": "Send Order Confirmations"
    }},
    {{
      "id": "DF3",
      "from": "System",
      "to": "Supplier",
      "description": "Send Fulfillment Requests"
    }},
    {{
      "id": "DF4",
      "from": "Supplier",
      "to": "System",
      "description": "Provide Fulfillment Updates"
    }},
    {{
      "id": "DF5",
      "from": "System",
      "to": "Payment Gateway",
      "description": "Send Payment Requests"
    }},
    {{
      "id": "DF6",
      "from": "Payment Gateway",
      "to": "System",
      "description": "Return Payment Confirmations"
    }}
  ]
}}

EXAMPLE 4:
Description: "A Hospital Management System handles patient records. Doctors update records, and patients view them. It uses an SMS Service for reminders."
Output:
{{
  "system_name": "Hospital Management System",
  "external_entities": [
    {{
      "id": "EE1",
      "name": "Doctor",
      "description": "Medical staff updating patient records"
    }},
    {{
      "id": "EE2",
      "name": "Patient",
      "description": "Individuals accessing their records"
    }},
    {{
      "id": "EE3",
      "name": "SMS Service",
      "description": "External service for sending reminders"
    }}
  ],
  "data_flows": [
    {{
      "id": "DF1",
      "from": "Doctor",
      "to": "System",
      "description": "Update Patient Records"
    }},
    {{
      "id": "DF2",
      "from": "System",
      "to": "Doctor",
      "description": "Send Update Confirmations"
    }},
    {{
      "id": "DF3",
      "from": "Patient",
      "to": "System",
      "description": "Request Record Access"
    }},
    {{
      "id": "DF4",
      "from": "System",
      "to": "Patient",
      "description": "Provide Patient Records"
    }},
    {{
      "id": "DF5",
      "from": "System",
      "to": "SMS Service",
      "description": "Send Reminder Requests"
    }}
  ]
}}

EXAMPLE 5:
Description: "A Ride-Sharing App connects drivers with passengers. It uses a GPS Service for navigation and a Payment Processor for transactions."
Output:
{{
  "system_name": "Ride-Sharing App",
  "external_entities": [
    {{
      "id": "EE1",
      "name": "Passenger",
      "description": "Users requesting rides"
    }},
    {{
      "id": "EE2",
      "name": "Driver",
      "description": "Individuals providing rides"
    }},
    {{
      "id": "EE3",
      "name": "GPS Service",
      "description": "External navigation service"
    }},
    {{
      "id": "EE4",
      "name": "Payment Processor",
      "description": "External payment service"
    }}
  ],
  "data_flows": [
    {{
      "id": "DF1",
      "from": "Passenger",
      "to": "System",
      "description": "Submit Ride Requests"
    }},
    {{
      "id": "DF2",
      "from": "System",
      "to": "Passenger",
      "description": "Send Ride Confirmations"
    }},
    {{
      "id": "DF3",
      "from": "System",
      "to": "Driver",
      "description": "Assign Ride Details"
    }},
    {{
      "id": "DF4",
      "from": "Driver",
      "to": "System",
      "description": "Provide Ride Updates"
    }},
    {{
      "id": "DF5",
      "from": "System",
      "to": "GPS Service",
      "description": "Request Location Data"
    }},
    {{
      "id": "DF6",
      "from": "GPS Service",
      "to": "System",
      "description": "Provide Location Data"
    }},
    {{
      "id": "DF7",
      "from": "System",
      "to": "Payment Processor",
      "description": "Send Payment Requests"
    }},
    {{
      "id": "DF8",
      "from": "Payment Processor",
      "to": "System",
      "description": "Return Payment Confirmations"
    }}
  ]
}}

EXAMPLE 6:
Description: "A Smart Home System controls devices. Homeowners set preferences, and it connects to a Weather API for conditions."
Output:
{{
  "system_name": "Smart Home System",
  "external_entities": [
    {{
      "id": "EE1",
      "name": "Homeowner",
      "description": "Users controlling home devices"
    }},
    {{
      "id": "EE2",
      "name": "Weather API",
      "description": "External service providing weather data"
    }}
  ],
  "data_flows": [
    {{
      "id": "DF1",
      "from": "Homeowner",
      "to": "System",
      "description": "Set Device Preferences"
    }},
    {{
      "id": "DF2",
      "from": "System",
      "to": "Homeowner",
      "description": "Provide Device Status"
    }},
    {{
      "id": "DF3",
      "from": "System",
      "to": "Weather API",
      "description": "Request Weather Data"
    }},
    {{
      "id": "DF4",
      "from": "Weather API",
      "to": "System",
      "description": "Provide Weather Data"
    }}
  ]
}}

EXAMPLE 7:
Description: "A Customer Support System handles inquiries. Customers submit tickets, and agents resolve them. It integrates with a Chatbot Service."
Output:
{{
  "system_name": "Customer Support System",
  "external_entities": [
    {{
      "id": "EE1",
      "name": "Customer",
      "description": "Users submitting support tickets"
    }},
    {{
      "id": "EE2",
      "name": "Agent",
      "description": "Staff resolving tickets"
    }},
    {{
      "id": "EE3",
      "name": "Chatbot Service",
      "description": "External automated support service"
    }}
  ],
  "data_flows": [
    {{
      "id": "DF1",
      "from": "Customer",
      "to": "System",
      "description": "Submit Support Tickets"
    }},
    {{
      "id": "DF2",
      "from": "System",
      "to": "Customer",
      "description": "Send Ticket Updates"
    }},
    {{
      "id": "DF3",
      "from": "System",
      "to": "Agent",
      "description": "Assign Tickets"
    }},
    {{
      "id": "DF4",
      "from": "Agent",
      "to": "System",
      "description": "Provide Ticket Resolutions"
    }},
    {{
      "id": "DF5",
      "from": "System",
      "to": "Chatbot Service",
      "description": "Send Inquiry Handling Requests"
    }},
    {{
      "id": "DF6",
      "from": "Chatbot Service",
      "to": "System",
      "description": "Return Inquiry Responses"
    }}
  ]
}}

EXAMPLE 8:
Description: "A Fitness Tracking App logs workouts. Users input data, and it syncs with a Health Cloud for storage and analysis."
Output:
{{
  "system_name": "Fitness Tracking App",
  "external_entities": [
    {{
      "id": "EE1",
      "name": "User",
      "description": "Individuals logging workouts"
    }},
    {{
      "id": "EE2",
      "name": "Health Cloud",
      "description": "External service for data storage and analysis"
    }}
  ],
  "data_flows": [
    {{
      "id": "DF1",
      "from": "User",
      "to": "System",
      "description": "Log Workout Data"
    }},
    {{
      "id": "DF2",
      "from": "System",
      "to": "User",
      "description": "Provide Workout Summaries"
    }},
    {{
      "id": "DF3",
      "from": "System",
      "to": "Health Cloud",
      "description": "Sync Workout Data"
    }},
    {{
      "id": "DF4",
      "from": "Health Cloud",
      "to": "System",
      "description": "Return Analysis Results"
    }}
  ]
}}

Now, analyze the following system description and extract context diagram elements:

System Description:
{description}

IMPORTANT:
- Create a diagram with the system as the only circle at the center and external entities as rectangles around it
- Use clear, action-oriented labels for data flows (e.g., "Submit Registration Data", "Provide Information & Tools")
- Represent each direction of data flow as a separate arrow (do NOT combine into bidirectional arrows)
- Return ONLY a valid JSON object
- Ensure comprehensive identification of entities and flows"""

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
                
                context_json = json.loads(cleaned_response)
                self.validate_json_structure(context_json)
                
                end_time = time.time()
                print(f"Extraction completed in {end_time - start_time:.2f} seconds")
                
                return context_json
            
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                time.sleep(2)
        
        return None

    def generate_plantuml(self, json_data: Dict[str, Any]) -> str:
        """
        Generate a PlantUML context diagram with the system as a circle
        """
        plantuml = [
            "@startuml",
            "skinparam monochrome true",
            "skinparam class {",
            "    BackgroundColor White",
            "    BorderColor Black",
            "    ArrowColor Black",
            "    FontSize 12",
            "}",
            "skinparam circle {",
            "    BackgroundColor White",
            "    BorderColor Black",
            "}",
            "skinparam ArrowThickness 1",
            "skinparam ArrowFontSize 10",
            "",
            f"circle \"{json_data['system_name']}\" as SysName",
            ""
        ]

        # Add external entities as rectangles
        entity_ids = {entity['name']: entity['id'] for entity in json_data['external_entities']}
        for entity in json_data['external_entities']:
            plantuml.append(f"rectangle \"{entity['name']}\" as {entity['id']}")

        plantuml.append("")

        # Add data flows as separate arrows
        for flow in json_data['data_flows']:
            if flow['from'] == "System":
                source = "SysName"
                target = entity_ids.get(flow['to'], flow['to'])
            else:
                source = entity_ids.get(flow['from'], flow['from'])
                target = "SysName"
            plantuml.append(f"{source} --> {target}: {flow['description']}")

        plantuml.append("@enduml")
        return '\n'.join(plantuml)

    def generate_diagram_with_kroki(self, plantuml_code: str, output_file: str = 'context_diagram.png') -> bool:
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
    # Initialize generator
    generator = ContextDiagramGenerator(model='llama3')
    
    # System description as a meeting transcript
    description = """
Meeting Transcript: University Course Registration System Discussion

Team Lead (Alex): Okay, team, today we’re discussing the University Course Registration System we’re building. It’s meant to streamline how students register for courses at the university, so let’s map out the key interactions.

Developer (Sam): Got it. What’s the main functionality of this system?

Team Lead (Alex): The system handles the entire course registration process. Students can browse available courses, register for them, and view their schedules. Faculty members need to submit their course offerings—like the syllabus and schedule—and they also want to see who’s enrolled in their classes. Registrars are in charge of managing the course catalog and approving student registrations to make sure everything’s in order.

Analyst (Jordan): So, students are registering and checking schedules, faculty are submitting course details and checking enrollments, and registrars are managing the catalog and approvals. Any external systems we need to connect to?

Team Lead (Alex): Yes, there are a few. We need a Payment System to handle tuition fees when students register for courses. There’s also an Email Notification Service to send confirmations to students once their registration is approved. And we’ll connect to the Academic Records System to update student records with their registered courses.

Designer (Priya): Sounds good! So, the system is interacting with students, faculty, registrars, and those external systems. I’ll make sure we capture all those flows clearly in the diagram.

Team Lead (Alex): Exactly. Let’s get this documented so we can visualize how everything connects.
    """
    
    # Extract context elements
    context_json = generator.extract_context_elements(description)
    
    if context_json:
        # Save JSON
        with open('context_diagram.json', 'w', encoding='utf-8') as f:
            json.dump(context_json, f, indent=2, ensure_ascii=False)
        
        # Generate PlantUML
        plantuml_code = generator.generate_plantuml(context_json)
        
        # Save PlantUML code
        with open('context_diagram.puml', 'w', encoding='utf-8') as f:
            f.write(plantuml_code)
        
        # Generate diagram using Kroki
        generator.generate_diagram_with_kroki(plantuml_code, 'context_diagram.png')
        
        # Print results
        print("Extracted Context Elements:")
        print(json.dumps(context_json, indent=2, ensure_ascii=False))
        print("\nPlantUML Diagram Code:")
        print(plantuml_code)
    else:
        print("Failed to extract context elements from description")


if __name__ == "__main__":
    main()