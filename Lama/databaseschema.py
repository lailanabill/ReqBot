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
