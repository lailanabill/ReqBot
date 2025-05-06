import os
import ollama
import json
import re
import time
import requests
import base64
import zlib
from typing import Dict, Any, Optional, List



from google.cloud import storage
def upload_to_gcs(bucket_name, source_file_path, destination_blob_name):
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(source_file_path)
    print(f"Uploaded to: gs://{bucket_name}/{destination_blob_name}")
    return f"https://storage.googleapis.com/{bucket_name}/{destination_blob_name}"

class SequenceDiagramGenerator:
    def __init__(self, model: str = 'llama3', temperature: float = 0.2):
        """
        Initialize the generator with specific model and generation parameters
        """
        self.model = model
        self.temperature = temperature
        self.max_retries = 3
        self.timeout = 60

    def extract_interactions_from_transcript(self, transcript: str) -> Optional[Dict[str, Any]]:
        """
        Extract interactions from a conversation transcript for sequence diagram generation
        """
        prompt = f"""You are an expert Systems Analyst tasked with generating a sequence diagram from a conversation transcript. 

GUIDELINES FOR SEQUENCE DIAGRAM GENERATION:
1. Identify all actors and system components involved in the interactions.
2. Capture interactions between actors and the system over time.
3. Use clear, action-oriented messages to represent interactions.
4. Ensure messages represent complete, meaningful interactions.
5. Avoid implementation details in interactions.
6. Distinguish between requests and responses: requests are solid arrows, responses are dotted arrows.
7. Identify the direction of information flow (who initiates, who responds).
8. Keep interaction messages concise (3-7 words) but descriptive.
9. Group related interactions into logical sequences.
10. Include all important actors even if they're only mentioned indirectly.
11. Maintain chronological order of events.
12. Identify user inputs and system outputs clearly.

EXAMPLE 1 - FOOD ORDERING SYSTEM:
Transcript:
The system allows customers to browse the menu, place orders, and track delivery status. 
Key interactions include:
1. Customer views the menu and selects items to order.
2. Customer places an order and receives confirmation.
3. The system notifies the restaurant of the new order.
4. The restaurant confirms the order and prepares the food.
5. The delivery person picks up the order and updates the status.
6. Customer tracks the order status until delivery is complete.

JSON Output:
{{
  "actors": [
    {{"name": "Customer"}},
    {{"name": "System"}},
    {{"name": "Restaurant"}},
    {{"name": "Delivery Person"}}
  ],
  "interactions": [
    {{"from": "Customer", "to": "System", "message": "Browse Menu", "type": "request"}},
    {{"from": "System", "to": "Customer", "message": "Display Menu", "type": "response"}},
    {{"from": "Customer", "to": "System", "message": "Place Order", "type": "request"}},
    {{"from": "System", "to": "Customer", "message": "Confirm Order", "type": "response"}},
    {{"from": "System", "to": "Restaurant", "message": "Notify New Order", "type": "request"}},
    {{"from": "Restaurant", "to": "System", "message": "Confirm Order", "type": "response"}},
    {{"from": "Restaurant", "to": "System", "message": "Update Order Status", "type": "notification"}},
    {{"from": "System", "to": "Delivery Person", "message": "Order Ready for Pickup", "type": "notification"}},
    {{"from": "Delivery Person", "to": "System", "message": "Update Delivery Status", "type": "notification"}},
    {{"from": "System", "to": "Customer", "message": "Provide Tracking Updates", "type": "notification"}}
  ]
}}

EXAMPLE 2 - ATM TRANSACTION:
Transcript:
A customer inserts their card into the ATM. The ATM reads the card and prompts for a PIN. The customer enters their PIN, which the ATM validates with the bank. After validation, the ATM displays available options. The customer selects "Withdraw Cash" and enters the amount. The ATM checks with the bank if sufficient funds are available. The bank confirms and authorizes the transaction. The ATM dispenses cash and asks if the customer wants a receipt. The customer selects yes, and the ATM prints a receipt. The customer takes the cash, receipt, and card.

JSON Output:
{{
  "actors": [
    {{"name": "Customer"}},
    {{"name": "ATM"}},
    {{"name": "Bank"}}
  ],
  "interactions": [
    {{"from": "Customer", "to": "ATM", "message": "Insert Card", "type": "request"}},
    {{"from": "ATM", "to": "Customer", "message": "Request PIN", "type": "request"}},
    {{"from": "Customer", "to": "ATM", "message": "Enter PIN", "type": "response"}},
    {{"from": "ATM", "to": "Bank", "message": "Validate PIN", "type": "request"}},
    {{"from": "Bank", "to": "ATM", "message": "Confirm PIN Valid", "type": "response"}},
    {{"from": "ATM", "to": "Customer", "message": "Display Options", "type": "notification"}},
    {{"from": "Customer", "to": "ATM", "message": "Select Withdraw Cash", "type": "request"}},
    {{"from": "Customer", "to": "ATM", "message": "Enter Amount", "type": "request"}},
    {{"from": "ATM", "to": "Bank", "message": "Check Funds", "type": "request"}},
    {{"from": "Bank", "to": "ATM", "message": "Authorize Transaction", "type": "response"}},
    {{"from": "ATM", "to": "Customer", "message": "Dispense Cash", "type": "response"}},
    {{"from": "ATM", "to": "Customer", "message": "Offer Receipt", "type": "request"}},
    {{"from": "Customer", "to": "ATM", "message": "Request Receipt", "type": "response"}},
    {{"from": "ATM", "to": "Customer", "message": "Print Receipt", "type": "response"}},
    {{"from": "Customer", "to": "ATM", "message": "Take Card and Cash", "type": "request"}}
  ]
}}

EXAMPLE 3 - E-COMMERCE CHECKOUT:
Transcript:
The user adds items to their shopping cart and proceeds to checkout. The system displays the order summary and payment options. The user selects credit card payment and enters their card details. The system sends the payment information to the payment gateway for processing. The payment gateway validates the card and processes the payment. Upon successful payment, the system confirms the order and sends an email confirmation to the user. The order is then forwarded to the warehouse for fulfillment.

JSON Output:
{{
  "actors": [
    {{"name": "User"}},
    {{"name": "System"}},
    {{"name": "Payment Gateway"}},
    {{"name": "Warehouse"}}
  ],
  "interactions": [
    {{"from": "User", "to": "System", "message": "Add Items to Cart", "type": "request"}},
    {{"from": "User", "to": "System", "message": "Proceed to Checkout", "type": "request"}},
    {{"from": "System", "to": "User", "message": "Display Order Summary", "type": "response"}},
    {{"from": "User", "to": "System", "message": "Select Payment Method", "type": "request"}},
    {{"from": "User", "to": "System", "message": "Enter Card Details", "type": "request"}},
    {{"from": "System", "to": "Payment Gateway", "message": "Process Payment", "type": "request"}},
    {{"from": "Payment Gateway", "to": "System", "message": "Confirm Payment", "type": "response"}},
    {{"from": "System", "to": "User", "message": "Confirm Order", "type": "notification"}},
    {{"from": "System", "to": "User", "message": "Send Email Confirmation", "type": "notification"}},
    {{"from": "System", "to": "Warehouse", "message": "Forward Order", "type": "notification"}}
  ]
}}

EXAMPLE 4 - HOTEL RESERVATION:
Transcript:
A guest calls the hotel to make a reservation. The receptionist checks room availability in the system for the requested dates. The system shows available rooms and rates. The guest selects a room type and provides personal information. The receptionist enters the information into the system and requests a deposit. The guest provides credit card details for the deposit. The system processes the payment and generates a reservation confirmation. The receptionist communicates the confirmation number to the guest and the system sends an email confirmation.

JSON Output:
{{
  "actors": [
    {{"name": "Guest"}},
    {{"name": "Receptionist"}},
    {{"name": "Reservation System"}},
    {{"name": "Payment System"}}
  ],
  "interactions": [
    {{"from": "Guest", "to": "Receptionist", "message": "Request Reservation", "type": "request"}},
    {{"from": "Receptionist", "to": "Reservation System", "message": "Check Availability", "type": "request"}},
    {{"from": "Reservation System", "to": "Receptionist", "message": "Show Available Rooms", "type": "response"}},
    {{"from": "Receptionist", "to": "Guest", "message": "Present Options", "type": "response"}},
    {{"from": "Guest", "to": "Receptionist", "message": "Select Room", "type": "request"}},
    {{"from": "Guest", "to": "Receptionist", "message": "Provide Personal Information", "type": "request"}},
    {{"from": "Receptionist", "to": "Reservation System", "message": "Enter Guest Information", "type": "request"}},
    {{"from": "Receptionist", "to": "Guest", "message": "Request Deposit", "type": "request"}},
    {{"from": "Guest", "to": "Receptionist", "message": "Provide Payment Details", "type": "response"}},
    {{"from": "Receptionist", "to": "Payment System", "message": "Process Deposit", "type": "request"}},
    {{"from": "Payment System", "to": "Reservation System", "message": "Confirm Payment", "type": "notification"}},
    {{"from": "Reservation System", "to": "Receptionist", "message": "Generate Confirmation", "type": "response"}},
    {{"from": "Receptionist", "to": "Guest", "message": "Provide Confirmation Number", "type": "response"}},
    {{"from": "Reservation System", "to": "Guest", "message": "Send Email Confirmation", "type": "notification"}}
  ]
}}

EXAMPLE 5 - PATIENT APPOINTMENT SCHEDULING:
Transcript:
A patient calls the clinic to schedule an appointment. The receptionist asks for the patient's information and checks if they are registered in the system. The patient is new, so the receptionist creates a new patient record. The receptionist then checks doctor availability in the scheduling system. The system displays available time slots. The patient selects a time, and the receptionist books the appointment. The system sends an appointment confirmation to the patient via SMS and adds the appointment to the doctor's calendar.

JSON Output:
{{
  "actors": [
    {{"name": "Patient"}},
    {{"name": "Receptionist"}},
    {{"name": "Patient Management System"}},
    {{"name": "Scheduling System"}},
    {{"name": "Doctor"}}
  ],
  "interactions": [
    {{"from": "Patient", "to": "Receptionist", "message": "Request Appointment", "type": "request"}},
    {{"from": "Receptionist", "to": "Patient", "message": "Ask for Information", "type": "request"}},
    {{"from": "Patient", "to": "Receptionist", "message": "Provide Information", "type": "response"}},
    {{"from": "Receptionist", "to": "Patient Management System", "message": "Check Patient Record", "type": "request"}},
    {{"from": "Patient Management System", "to": "Receptionist", "message": "Patient Not Found", "type": "response"}},
    {{"from": "Receptionist", "to": "Patient Management System", "message": "Create Patient Record", "type": "request"}},
    {{"from": "Patient Management System", "to": "Receptionist", "message": "Confirm Record Created", "type": "response"}},
    {{"from": "Receptionist", "to": "Scheduling System", "message": "Check Doctor Availability", "type": "request"}},
    {{"from": "Scheduling System", "to": "Receptionist", "message": "Show Available Slots", "type": "response"}},
    {{"from": "Receptionist", "to": "Patient", "message": "Offer Available Times", "type": "request"}},
    {{"from": "Patient", "to": "Receptionist", "message": "Select Appointment Time", "type": "response"}},
    {{"from": "Receptionist", "to": "Scheduling System", "message": "Book Appointment", "type": "request"}},
    {{"from": "Scheduling System", "to": "Patient", "message": "Send SMS Confirmation", "type": "notification"}},
    {{"from": "Scheduling System", "to": "Doctor", "message": "Update Calendar", "type": "notification"}}
  ]
}}

Now, analyze the following conversation transcript and generate a sequence diagram:

Conversation Transcript:
{transcript}

IMPORTANT: 
- Analyze the transcript thoroughly
- Return ONLY a valid JSON object with actors and interactions
- Each interaction must include a "type" field with one of these values: "request", "response", or "notification"
- Ensure your response can be parsed directly as JSON
- Ensure comprehensive and precise interaction extraction"""

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
                
                interactions_json = json.loads(cleaned_response)
                
                self.validate_json_structure(interactions_json)
                
                end_time = time.time()
                print(f"Extraction completed in {end_time - start_time:.2f} seconds")
                
                return interactions_json
            
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                time.sleep(2)
        
        return None

    def clean_json_response(self, response: str) -> Optional[str]:
        """
        Advanced JSON cleaning and extraction
        """
        try:
            # Remove code block markers if present
            for marker in ['```json', '```', '```JSON']:
                response = response.replace(marker, '')
            response = response.strip()
            
            json_patterns = [
                r'\{.*\}',  
                r'\{.+\}',  
                r'(\{[\s\S]*\})'  
            ]
            
            for pattern in json_patterns:
                json_match = re.search(pattern, response, re.DOTALL | re.MULTILINE)
                if json_match:
                    cleaned_response = json_match.group(0)
                    
                    # Validate JSON before returning
                    json.loads(cleaned_response)
                    return cleaned_response
            
            raise ValueError("No valid JSON found")
        
        except Exception as e:
            print(f"JSON Cleaning Error: {e}")
            print("Original Response:", response)
            return None

    def validate_json_structure(self, json_data: Dict[str, Any]) -> None:
        """
        Validate JSON structure for sequence diagram generation
        """
        required_keys = ['interactions', 'actors']
        for key in required_keys:
            if key not in json_data:
                raise ValueError(f"Missing required key: {key}")
        
        if not json_data['actors'] or not json_data['interactions']:
            raise ValueError("Actors or Interactions cannot be empty")

        for interaction in json_data['interactions']:
            required_interaction_keys = ['from', 'to', 'message', 'type']
            for key in required_interaction_keys:
                if key not in interaction:
                    raise ValueError(f"Each interaction must have '{key}' key")
            
            valid_types = ['request', 'response', 'notification']
            if interaction['type'] not in valid_types:
                raise ValueError(f"Interaction type must be one of {valid_types}")

    def generate_plantuml(self, json_data: Dict[str, Any]) -> str:
        """
        Generate PlantUML sequence diagram based on the extracted interactions
        """
        plantuml = [
            "@startuml",
            "title Sequence Diagram",
            "skinparam sequence {",
            "    BackgroundColor LightBlue",
            "    BorderColor DarkBlue",
            "    ArrowColor DarkGray",
            "    ActorBorderColor Navy",
            "}",
            ""
        ]

        # Add actors and system components
        actors = {actor['name']: actor['name'].replace(' ', '_') for actor in json_data['actors']}
        
        # Add systems if not already in actors list
        if "System" not in actors:
            actors["System"] = "System"
        
        # Define actors in PlantUML
        for actor_name, actor_id in actors.items():
            if actor_name.lower() in ["system", "server", "application", "backend"]:
                plantuml.append(f"participant {actor_id} as \"{actor_name}\"")
            else:
                plantuml.append(f"actor {actor_id} as \"{actor_name}\"")

        # Process interactions
        for interaction in json_data['interactions']:
            from_actor = actors[interaction['from']]
            to_actor = actors[interaction['to']]
            message = interaction['message']
            
            # Set arrow style based on interaction type
            arrow_style = "->"
            if interaction['type'] == 'response':
                arrow_style = "-->"  # Dotted arrow for responses
            elif interaction['type'] == 'notification':
                arrow_style = "->>"  # Open arrow for notifications
            
            plantuml.append(f"{from_actor} {arrow_style} {to_actor}: {message}")

        plantuml.append("@enduml")

        return '\n'.join(plantuml)

    def generate_diagram_with_kroki(self, plantuml_code: str,pid :int  ,output_dir : str = "reqbotui/assets/images/") -> bool:
        """
        Generate diagram using Kroki API
        """
        try:

            output_file = f"{output_dir}sequence_diagram_{pid}.png"
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

    def generate_interactive_html(self, plantuml_code: str, output_file: str = 'sequence_diagram.html') -> bool:
        """
        Generate an interactive HTML version of the sequence diagram
        """
        try:
            # Create a base64 encoded version of the PlantUML code for embedding
            plantuml_encoded = base64.urlsafe_b64encode(
                zlib.compress(plantuml_code.encode('utf-8'), 9)
            ).decode('ascii')
            
            image_url = f"https://kroki.io/plantuml/svg/{plantuml_encoded}"
            
            # Create HTML with interactive features
            html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interactive Sequence Diagram</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        h1 {{
            color: #333;
            text-align: center;
        }}
        .diagram-container {{
            overflow: auto;
            margin: 20px 0;
            border: 1px solid #ddd;
            padding: 10px;
        }}
        .diagram-container svg {{
            min-width: 100%;
            height: auto;
        }}
        .controls {{
            margin: 20px 0;
            text-align: center;
        }}
        button {{
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
        }}
        button:hover {{
            background-color: #45a049;
        }}
        .code-view {{
            background-color: #f8f8f8;
            padding: 15px;
            border-radius: 4px;
            margin-top: 20px;
            white-space: pre-wrap;
            font-family: monospace;
            display: none;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>Interactive Sequence Diagram</h1>
        
        <div class="controls">
            <button id="zoomIn">Zoom In</button>
            <button id="zoomOut">Zoom Out</button>
            <button id="resetZoom">Reset Zoom</button>
            <button id="toggleCode">Show/Hide PlantUML Code</button>
            <button id="downloadSVG">Download SVG</button>
        </div>
        
        <div class="diagram-container" id="diagramContainer">
            <object id="svgObject" type="image/svg+xml" data="{image_url}" width="100%">
                Your browser does not support SVG
            </object>
        </div>
        
        <div class="code-view" id="codeView">
{plantuml_code}
        </div>
    </div>
    
    <script>
        // Variables to track zoom level
        let currentZoom = 1;
        const zoomFactor = 0.1;
        const svgObject = document.getElementById('svgObject');
        
        // Zoom in function
        document.getElementById('zoomIn').addEventListener('click', function() {{
            currentZoom += zoomFactor;
            svgObject.style.transform = `scale(${{currentZoom}})`;
            svgObject.style.transformOrigin = 'top left';
        }});
        
        // Zoom out function
        document.getElementById('zoomOut').addEventListener('click', function() {{
            if (currentZoom > zoomFactor) {{
                currentZoom -= zoomFactor;
                svgObject.style.transform = `scale(${{currentZoom}})`;
                svgObject.style.transformOrigin = 'top left';
            }}
        }});
        
        // Reset zoom function
        document.getElementById('resetZoom').addEventListener('click', function() {{
            currentZoom = 1;
            svgObject.style.transform = 'scale(1)';
        }});
        
        // Toggle code view
        document.getElementById('toggleCode').addEventListener('click', function() {{
            const codeView = document.getElementById('codeView');
            if (codeView.style.display === 'none' || codeView.style.display === '') {{
                codeView.style.display = 'block';
            }} else {{
                codeView.style.display = 'none';
            }}
        }});
        
        // Download SVG
        document.getElementById('downloadSVG').addEventListener('click', function() {{
            window.open('{image_url}', '_blank');
        }});
    </script>
</body>
</html>
"""
            
            # Write HTML to file
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(html_content)
                
            print(f"Interactive HTML diagram generated and saved as {output_file}")
            return True
            
        except Exception as e:
            print(f"Error generating interactive HTML: {e}")
            return False

    def analyze_and_generate_diagrams(self, transcript: str,pid:int ,output_dir: str = 'reqbotui/assets/') -> bool:
        """
        Complete workflow to analyze transcript and generate all diagram formats
        """
        try:
            # Extract interactions
            interactions_json = self.extract_interactions_from_transcript(transcript)
            
            if not interactions_json:
                print("Failed to extract interactions from transcript")
                return False
                
            # Save JSON

            os.makedirs("/jsons", exist_ok=True)
            os.makedirs("/umls", exist_ok=True)
            os.makedirs("/images", exist_ok=True)
            json_path = f"/jsons/sequence_diagram_{pid}.json"
            puml_path = f"/umls/sequence_diagram_{pid}.puml"
            img_path = f"/images/sequence_diagram_{pid}.png"
            # json_file = f"{output_dir}jsons/seq_diagram_{pid}.json"
            # with open(json_file, 'w', encoding='utf-8') as f:
            #     json.dump(interactions_json, f, indent=2, ensure_ascii=False)
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(interactions_json, f, indent=2, ensure_ascii=False)
            
            
            # Generate PlantUML
            plantuml_code = self.generate_plantuml(interactions_json)
            
            
            # Save PlantUML code
            # puml_file = f"{output_dir}umls/seq_diagram_{pid}.uml"
            # puml_file = f"{output_prefix}.puml"
            # with open(puml_file, 'w', encoding='utf-8') as f:
            #     f.write(plantuml_code)
            with open(puml_path, 'w', encoding='utf-8') as f:
                f.write(plantuml_code)
            # print(f"PlantUML code saved to {puml_file}")
            
            # Generate PNG diagram
            # png_file = f"{output_dir}images/seq_diagram_{pid}.png"
            # png_file = f"{output_prefix}.png"
            png_success = self.generate_diagram_with_kroki(plantuml_code,pid ,img_path, output_dir="/images/")
            
            bucket_name = "diagrams-data"  # replace with your bucket
            upload_to_gcs(bucket_name, json_path, f"jsons/sequence_diagram_{pid}.json")
            upload_to_gcs(bucket_name, puml_path, f"umls/sequence_diagram_{pid}.puml")
            upload_to_gcs(bucket_name, img_path, f"images/sequence_diagram_{pid}.png")
            
            return png_success 
        



            
            
            
            # generator.generate_diagram_with_kroki(plantuml_code,pid, output_dir="/images/")


            

            # print("class done")
            # return {
            #     "pid": pid,
            #     "json": json_url,
            #     "puml": puml_url,
            #     "image_png": png_url,
            # }
            
        except Exception as e:
            print(f"Error in analysis and generation workflow: {e}")
            return False


def SequenceDiagramDriver(desc,pid):
    # Initialize generator
    generator = SequenceDiagramGenerator()
    
    # New Transcript for Testing - Smart Home Automation System
    transcript = desc

    # Use the complete workflow method
    success = generator.analyze_and_generate_diagrams(transcript,pid)
    
    if success:
        print("sequence done")
    else:
        print("There were issues generating some diagram formats.")
    





