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
