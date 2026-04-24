
import os
import sys
import io
import requests

# Add backend to path
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from document_service import DocumentService

def test_generation_with_signatures():
    template_type = 'social_case_study'
    service_unit = 'Social Service'
    
    # Use a dummy signature URL (Google's logo as a placeholder)
    dummy_sig_url = "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"
    
    data = {
        'resident_name': 'TEST RESIDENT WITH SIGNATURE',
        'case_number': '2024-001',
        'social_worker': 'TEST WORKER',
        'date': '2024-04-14',
        'prepared_by_signature_url': dummy_sig_url,
        'center_head_signature_url': dummy_sig_url
    }
    
    print(f"Testing generation for {template_type} with signatures...")
    try:
        path = DocumentService.generate(template_type, service_unit, data, output_format='pdf')
        print(f"Success! Path: {path}")
        if path.endswith('.docx'):
            print("WARNING: Returned DOCX instead of PDF (Fallback occurred)")
        else:
            print(f"Created PDF: {os.path.getsize(path)} bytes")
    except Exception as e:
        print(f"FAILED: {e}")

if __name__ == "__main__":
    test_generation_with_signatures()
