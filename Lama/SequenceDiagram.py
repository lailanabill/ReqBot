import ollama
import json
import re
import time
import requests
import base64
import zlib
from typing import Dict, Any, Optional

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

EXAMPLE OUTPUT FORMAT:
{{
  "actors": [
    {{"name": "Customer"}},
    {{"name": "System"}},
    {{"name": "Restaurant"}},
    {{"name": "Delivery Person"}}
  ],
  "interactions": [
    {{"from": "Customer", "to": "System", "message": "Browse Menu"}},
    {{"from": "System", "to": "Customer", "message": "Display Menu"}},
    {{"from": "Customer", "to": "System", "message": "Place Order"}},
    {{"from": "System", "to": "Customer", "message": "Confirm Order"}},
    {{"from": "System", "to": "Restaurant", "message": "Notify New Order"}},
    {{"from": "Restaurant", "to": "System", "message": "Confirm Order"}},
    {{"from": "System", "to": "Delivery Person", "message": "Order Ready for Pickup"}},
    {{"from": "Delivery Person", "to": "System", "message": "Update Status"}},
    {{"from": "System", "to": "Customer", "message": "Order Delivered"}}
  ]
}}

Now, analyze the following conversation transcript and generate a sequence diagram:

Conversation Transcript:
{transcript}

IMPORTANT: 
- Analyze the transcript thoroughly
- Return ONLY a valid JSON object with actors and interactions
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
        Validate JSON structure for sequence diagram generation
        """
        required_keys = ['interactions', 'actors']
        for key in required_keys:
            if key not in json_data:
                raise ValueError(f"Missing required key: {key}")
        
        if not json_data['actors'] or not json_data['interactions']:
            raise ValueError("Actors or Interactions cannot be empty")

        for interaction in json_data['interactions']:
            if 'from' not in interaction or 'to' not in interaction or 'message' not in interaction:
                raise ValueError("Each interaction must have 'from', 'to', and 'message' keys")

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
        for actor_name, actor_id in actors.items():
            plantuml.append(f"actor {actor_id} as \"{actor_name}\"")

        plantuml.append("participant System")

        # Process interactions
        for interaction in json_data['interactions']:
            from_actor = actors[interaction['from']]
            to_actor = "System" if interaction['to'] == "System" else actors[interaction['to']]
            message = interaction['message']
            plantuml.append(f"{from_actor} -> {to_actor}: {message}")

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
    # Initialize generator
    generator = SequenceDiagramGenerator()
    
    # New Transcript for Testing
    transcript = """
    Online Food Ordering System

    The system allows customers to browse the menu, place orders, and track delivery status. 
    Key interactions include:

    1. Customer views the menu and selects items to order.
    2. Customer places an order and receives confirmation.
    3. The system notifies the restaurant of the new order.
    4. The restaurant confirms the order and prepares the food.
    5. The delivery person picks up the order and updates the status.
    6. Customer tracks the order status until delivery is complete.

    Actors:
    - Customer: Browses menu, places orders, and tracks delivery.
    - Restaurant: Receives and prepares orders.
    - Delivery Person: Delivers orders and updates status.
    """

    # Extract interactions from transcript
    interactions_json = generator.extract_interactions_from_transcript(transcript)
    
    # Save and display results
    if interactions_json:
        # Save JSON
        with open('interactions.json', 'w', encoding='utf-8') as f:
            json.dump(interactions_json, f, indent=2, ensure_ascii=False)
        
        # Generate PlantUML
        plantuml_code = generator.generate_plantuml(interactions_json)
        
        # Save PlantUML code
        with open('sequence_diagram.puml', 'w', encoding='utf-8') as f:
            f.write(plantuml_code)
        
        # Generate diagram using Kroki
        generator.generate_diagram_with_kroki(plantuml_code, 'sequence_diagram.png')
        
        # Print results
        print("Extracted Interactions:")
        print(json.dumps(interactions_json, indent=2, ensure_ascii=False))
        print("\nPlantUML Diagram Code:")
        print(plantuml_code)
    else:
        print("Failed to extract interactions from transcript")

if __name__ == "__main__":
    main()
    