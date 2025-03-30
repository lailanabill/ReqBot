import ollama
import json
import re
import time
import requests
import base64
import zlib
from typing import Dict, Any, Optional, List, Union

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
