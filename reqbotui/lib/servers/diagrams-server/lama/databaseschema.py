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
        prompt = f"""You are an expert Database Architect tasked with designing a comprehensive Class-based Database Schema from a system description.

GUIDELINES FOR DATABASE SCHEMA DESIGN:
1. Identify all entities in the system as classes (representing database tables).
2. Ensure each class has meaningful attributes that reflect the entity’s properties.
3. Define attributes with appropriate data types (e.g., String, Integer, Date, Boolean).
4. Mark primary keys and specify if attributes are nullable.
5. Include methods that represent key operations on the entity (e.g., CRUD operations, business logic).
6. Establish relationships between classes (e.g., one-to-many, many-to-many) with clear descriptions.
7. Avoid isolated classes; ensure all classes are connected via relationships.
8. Use precise, descriptive names for classes, attributes, methods, and relationships.
9. Ensure the schema supports the system’s functionality as described.
10. Include foreign keys in attributes where relationships exist.
11. Follow database normalization principles (e.g., avoid redundancy, ensure referential integrity).
12. Maintain consistency in naming conventions (e.g., camelCase for attributes).

JSON STRUCTURE TEMPLATE:
{{
  "system_name": "System Name",
  "classes": [
    {{
      "name": "ClassName",
      "description": "Description of the class",
      "attributes": [
        {{
          "name": "attributeName",
          "type": "DataType",
          "is_primary_key": true/false,
          "is_nullable": true/false,
          "is_foreign_key": true/false,
          "references": "RelatedClassName (optional)"
        }}
      ],
      "methods": [
        {{
          "name": "methodName",
          "parameters": [
            {{
              "name": "paramName",
              "type": "DataType"
            }}
          ],
          "return_type": "ReturnType"
        }}
      ]
    }}
  ],
  "relationships": [
    {{
      "type": "relationship_type",
      "from_class": "ClassName1",
      "to_class": "ClassName2",
      "description": "Description of the relationship"
    }}
  ]
}}

EXAMPLE 1 - ONLINE BOOKSTORE SYSTEM:
System Description:
The system manages an online bookstore where customers can browse books, place orders, and leave reviews. Books have authors, and each book belongs to a category. Customers can have multiple orders, and each order can contain multiple books. The system tracks inventory and processes payments.

JSON Output:
{{
  "system_name": "Online Bookstore Database",
  "classes": [
    {{
      "name": "Customer",
      "description": "Represents a customer in the bookstore",
      "attributes": [
        {{
          "name": "customerId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "name",
          "type": "String",
          "is_nullable": false
        }},
        {{
          "name": "email",
          "type": "String",
          "is_nullable": false
        }}
      ],
      "methods": [
        {{
          "name": "placeOrder",
          "parameters": [
            {{
              "name": "orderDetails",
              "type": "List<String>"
            }}
          ],
          "return_type": "boolean"
        }},
        {{
          "name": "writeReview",
          "parameters": [
            {{
              "name": "bookId",
              "type": "String"
            }},
            {{
              "name": "rating",
              "type": "Integer"
            }}
          ],
          "return_type": "boolean"
        }}
      ]
    }},
    {{
      "name": "Book",
      "description": "Represents a book in the bookstore",
      "attributes": [
        {{
          "name": "bookId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "title",
          "type": "String",
          "is_nullable": false
        }},
        {{
          "name": "authorId",
          "type": "String",
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Author"
        }},
        {{
          "name": "categoryId",
          "type": "String",
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Category"
        }},
        {{
          "name": "stock",
          "type": "Integer",
          "is_nullable": false
        }}
      ],
      "methods": [
        {{
          "name": "updateStock",
          "parameters": [
            {{
              "name": "quantity",
              "type": "Integer"
            }}
          ],
          "return_type": "void"
        }}
      ]
    }},
    {{
      "name": "Order",
      "description": "Represents a customer order",
      "attributes": [
        {{
          "name": "orderId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "customerId",
          "type": "String",
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Customer"
        }},
        {{
          "name": "orderDate",
          "type": "Date",
          "is_nullable": false
        }}
      ],
      "methods": [
        {{
          "name": "addBook",
          "parameters": [
            {{
              "name": "bookId",
              "type": "String"
            }}
          ],
          "return_type": "boolean"
        }}
      ]
    }},
    {{
      "name": "OrderBook",
      "description": "Junction table for Order and Book (many-to-many)",
      "attributes": [
        {{
          "name": "orderId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Order"
        }},
        {{
          "name": "bookId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Book"
        }},
        {{
          "name": "quantity",
          "type": "Integer",
          "is_nullable": false
        }}
      ],
      "methods": []
    }},
    {{
      "name": "Author",
      "description": "Represents an author of books",
      "attributes": [
        {{
          "name": "authorId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "name",
          "type": "String",
          "is_nullable": false
        }}
      ],
      "methods": []
    }},
    {{
      "name": "Category",
      "description": "Represents a book category",
      "attributes": [
        {{
          "name": "categoryId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "name",
          "type": "String",
          "is_nullable": false
        }}
      ],
      "methods": []
    }},
    {{
      "name": "Review",
      "description": "Represents a customer review of a book",
      "attributes": [
        {{
          "name": "reviewId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "customerId",
          "type": "String",
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Customer"
        }},
        {{
          "name": "bookId",
          "type": "String",
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Book"
        }},
        {{
          "name": "rating",
          "type": "Integer",
          "is_nullable": false
        }},
        {{
          "name": "comment",
          "type": "String",
          "is_nullable": true
        }}
      ],
      "methods": []
    }}
  ],
  "relationships": [
    {{
      "type": "one_to_many",
      "from_class": "Customer",
      "to_class": "Order",
      "description": "A customer can place multiple orders"
    }},
    {{
      "type": "many_to_many",
      "from_class": "Order",
      "to_class": "Book",
      "description": "An order can contain multiple books, implemented via OrderBook junction table"
    }},
    {{
      "type": "one_to_many",
      "from_class": "Author",
      "to_class": "Book",
      "description": "An author can write multiple books"
    }},
    {{
      "type": "one_to_many",
      "from_class": "Category",
      "to_class": "Book",
      "description": "A category can have multiple books"
    }},
    {{
      "type": "one_to_many",
      "from_class": "Customer",
      "to_class": "Review",
      "description": "A customer can write multiple reviews"
    }},
    {{
      "type": "one_to_many",
      "from_class": "Book",
      "to_class": "Review",
      "description": "A book can have multiple reviews"
    }}
  ]
}}

EXAMPLE 2 - HOSPITAL MANAGEMENT SYSTEM:
System Description:
The system manages a hospital where patients are assigned to doctors. Each patient can have multiple appointments, and doctors can schedule appointments. The hospital has departments, and each doctor belongs to a department. The system also tracks prescriptions issued during appointments.

JSON Output:
{{
  "system_name": "Hospital Management Database",
  "classes": [
    {{
      "name": "Patient",
      "description": "Represents a patient in the hospital",
      "attributes": [
        {{
          "name": "patientId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "name",
          "type": "String",
          "is_nullable": false
        }},
        {{
          "name": "dob",
          "type": "Date",
          "is_nullable": false
        }}
      ],
      "methods": [
        {{
          "name": "scheduleAppointment",
          "parameters": [
            {{
              "name": "doctorId",
              "type": "String"
            }},
            {{
              "name": "date",
              "type": "Date"
            }}
          ],
          "return_type": "boolean"
        }}
      ]
    }},
    {{
      "name": "Doctor",
      "description": "Represents a doctor in the hospital",
      "attributes": [
        {{
          "name": "doctorId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "name",
          "type": "String",
          "is_nullable": false
        }},
        {{
          "name": "departmentId",
          "type": "String",
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Department"
        }}
      ],
      "methods": [
        {{
          "name": "prescribeMedication",
          "parameters": [
            {{
              "name": "appointmentId",
              "type": "String"
            }},
            {{
              "name": "medication",
              "type": "String"
            }}
          ],
          "return_type": "boolean"
        }}
      ]
    }},
    {{
      "name": "Department",
      "description": "Represents a department in the hospital",
      "attributes": [
        {{
          "name": "departmentId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "name",
          "type": "String",
          "is_nullable": false
        }}
      ],
      "methods": []
    }},
    {{
      "name": "Appointment",
      "description": "Represents an appointment between a patient and a doctor",
      "attributes": [
        {{
          "name": "appointmentId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "patientId",
          "type": "String",
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Patient"
        }},
        {{
          "name": "doctorId",
          "type": "String",
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Doctor"
        }},
        {{
          "name": "date",
          "type": "Date",
          "is_nullable": false
        }}
      ],
      "methods": []
    }},
    {{
      "name": "Prescription",
      "description": "Represents a prescription issued during an appointment",
      "attributes": [
        {{
          "name": "prescriptionId",
          "type": "String",
          "is_primary_key": true,
          "is_nullable": false
        }},
        {{
          "name": "appointmentId",
          "type": "String",
          "is_nullable": false,
          "is_foreign_key": true,
          "references": "Appointment"
        }},
        {{
          "name": "medication",
          "type": "String",
          "is_nullable": false
        }}
      ],
      "methods": []
    }}
  ],
  "relationships": [
    {{
      "type": "one_to_many",
      "from_class": "Patient",
      "to_class": "Appointment",
      "description": "A patient can have multiple appointments"
    }},
    {{
      "type": "one_to_many",
      "from_class": "Doctor",
      "to_class": "Appointment",
      "description": "A doctor can have multiple appointments"
    }},
    {{
      "type": "one_to_many",
      "from_class": "Department",
      "to_class": "Doctor",
      "description": "A department can have multiple doctors"
    }},
    {{
      "type": "one_to_many",
      "from_class": "Appointment",
      "to_class": "Prescription",
      "description": "An appointment can have multiple prescriptions"
    }}
  ]
}}

Now, design a Class-based Database Schema based on the following system description:

System Description:
{description}

IMPORTANT:
- Analyze the system description thoroughly.
- Return ONLY a valid JSON object with system_name, classes, and relationships.
- Each class must include description, attributes, and methods (if applicable).
- Each attribute must include name, type, is_primary_key, is_nullable, and is_foreign_key (with references if applicable).
- Each relationship must include type, from_class, to_class, and description.
- Ensure the schema is comprehensive, normalized, and supports the system’s functionality.
"""

        for attempt in range(self.max_retries):
            try:
                response = ollama.chat(
                    model=self.model,
                    messages=[{'role': 'user', 'content': prompt}],
                    options={
                        'temperature': self.temperature,
                        'num_predict': 4000,
                        'top_k': 20,
                        'top_p': 0.9
                    }
                )
                
                raw_response = response['message']['content']
                cleaned_response = self.clean_json_response(raw_response)
                
                if cleaned_response:
                    return json.loads(cleaned_response)
                
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                time.sleep(2)
        
        return None

    def clean_json_response(self, response: str) -> Optional[str]:
        def extract_json(text):
            patterns = [
                r'\{.*"system_name".*"classes".*\}',
                r'```json(.*?)```',
                r'\{.*\}'
            ]
            
            for pattern in patterns:
                try:
                    match = re.search(pattern, text, re.DOTALL | re.MULTILINE)
                    if match:
                        json_str = match.group(1) if len(match.groups()) > 0 else match.group(0)
                        return json_str.strip()
                except Exception:
                    continue
            return None

        try:
            cleaned_json_str = extract_json(response)
            if not cleaned_json_str:
                return None

            # Remove any non-JSON content
            cleaned_json_str = re.sub(r'```.*?```', '', cleaned_json_str, flags=re.DOTALL)
            cleaned_json_str = cleaned_json_str.strip()

            # Validate JSON structure
            parsed_json = json.loads(cleaned_json_str)
            return json.dumps(parsed_json)

        except Exception as e:
            print(f"JSON cleaning error: {e}")
            return None

    def generate_plantuml(self, json_data: Dict[str, Any]) -> str:
        """Generate PlantUML class diagram code"""
        plantuml = [
            "@startuml",
            "skinparam class {",
            "    BackgroundColor White",
            "    BorderColor Black",
            "    ArrowColor Black",
            "}",
            "skinparam classAttributeIconSize 0",
            f"title {json_data.get('system_name', 'Database Schema')} Class Diagram"
        ]

        # Generate classes
        for cls in json_data.get('classes', []):
            class_def = [f"class {cls['name']} {{"]
            
            # Add description as note
            if 'description' in cls:
                class_def.extend([
                    f".. {cls['description']} ..",
                    ""
                ])
            
            # Add attributes
            for attr in cls.get('attributes', []):
                visibility = "+" if attr.get('is_primary_key') else "-"
                attr_str = f"{visibility} {attr.get('name')}: {attr.get('type')}"
                
                constraints = []
                if attr.get('is_primary_key'):
                    constraints.append("PK")
                if not attr.get('is_nullable', True):
                    constraints.append("NOT NULL")
                
                if constraints:
                    attr_str += f" {{{', '.join(constraints)}}}"
                
                class_def.append(attr_str)
            
            # Add methods
            class_def.append("")  # Empty line before methods
            for method in cls.get('methods', []):
                params = method.get('parameters', [])
                params_str = ", ".join([f"{p['name']}: {p['type']}" for p in params])
                method_str = f"+ {method['name']}({params_str}): {method.get('return_type', 'void')}"
                class_def.append(method_str)
            
            class_def.append("}")
            plantuml.extend(class_def)

        # Generate relationships
        for rel in json_data.get('relationships', []):
            if rel.get('type') == 'one_to_many':
                arrow_style = "\"1\" *-- \"*\""
            elif rel.get('type') == 'many_to_one':
                arrow_style = "\"*\" --* \"1\""
            elif rel.get('type') == 'one_to_one':
                arrow_style = "\"1\" -- \"1\""
            else:
                arrow_style = "\"*\" -- \"*\""
            
            plantuml.append(
                f"{rel.get('from_class')} {arrow_style} {rel.get('to_class')} : {rel.get('description', '')}"
            )

        plantuml.append("@enduml")
        return '\n'.join(plantuml)

    def generate_diagram(self, plantuml_code: str,  pid :int ,output_dir = "reqbotui/assets/images/") -> bool:
        """Generate diagram using Kroki"""
        try:
            output_file = f"{output_dir}database_diagram_{pid}.png"
            kroki_url = self.url_generator.generate_kroki_url('plantuml', plantuml_code, 'png')
            
            if not kroki_url:
                return False
            
            response = requests.get(kroki_url)
            
            if response.status_code == 200:
                with open(output_file, 'wb') as f:
                    f.write(response.content)
                
                with open('database_diagram.puml', 'w', encoding='utf-8') as f:
                    f.write(plantuml_code)
                
                print(f"Class diagram saved as {output_file}")
                return True
            else:
                print(f"Failed to generate diagram. Status code: {response.status_code}")
                return False
            
        except Exception as e:
            print(f"Error generating diagram: {e}")
            return False

def DbDiagramDriver(desc,pid):
    # Initialize generator
    generator = DatabaseClassDiagramGenerator(model='llama3')
    
    # System description
    description = desc
    
    # Generate class diagram
    db_diagram_json = generator.extract_database_schema_elements(description)
    
    if db_diagram_json:
        # Save JSON
        # with open(f"reqbotui/assets/jsons/database_diagram_{pid}.json", 'w', encoding='utf-8') as f:
        #     json.dump(db_diagram_json, f, indent=2, ensure_ascii=False)
        
        # # Generate and save diagram
        # plantuml_code = generator.generate_plantuml(db_diagram_json)
        # # Save PlantUML code to file
        # with open(f"reqbotui/assets/umls/datbase_diagram_{pid}.puml", 'w', encoding='utf-8') as f:
        #     f.write(plantuml_code)
        
        # generator.generate_diagram(plantuml_code,pid)
        
        # print("db done")




        os.makedirs("/jsons", exist_ok=True)
        os.makedirs("/umls", exist_ok=True)
        os.makedirs("/images", exist_ok=True)
        json_path = f"/jsons/database_diagram_{pid}.json"
        puml_path = f"/umls/database_diagram_{pid}.puml"
        img_path = f"/images/database_diagram_{pid}.png"
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(db_diagram_json, f, indent=2, ensure_ascii=False)
        plantuml_code = generator.generate_plantuml(db_diagram_json)
        with open(puml_path, 'w', encoding='utf-8') as f:
            f.write(plantuml_code)
        generator.generate_diagram(plantuml_code,pid, output_dir="/images/")


        bucket_name = "diagrams-data"  # replace with your bucket
        json_url = upload_to_gcs(bucket_name, json_path, f"jsons/database_diagram_{pid}.json")
        puml_url = upload_to_gcs(bucket_name, puml_path, f"umls/database_diagram_{pid}.puml")
        png_url = upload_to_gcs(bucket_name, img_path, f"images/database_diagram_{pid}.png")

        print("database done")
        return {
            "pid": pid,
            "json": json_url,
            "puml": puml_url,
            "image_png": png_url,
        }
        # Print results
        # print("Generated Class Diagram Elements:")
        # print(json.dumps(class_diagram_json, indent=2, ensure_ascii=False))
        # print("\nPlantUML Class Diagram Code:")
        # print(plantuml_code)
    else:
        print("Failed to generate class diagram")


