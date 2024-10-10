import sys
import os
import zipfile
import shutil

def search_in_file(file_path, search_strings, zip_file_name):
    try:
        with open(file_path, 'r') as file:
            line_number = 0
            matches = []

            for line in file:
                line_number += 1
                for search_str in search_strings:
                    if search_str in line:
                        matches.append(f'  Line {line_number}: {line.strip()}')

            # If matches were found, print the file path and the matches
            if matches:
                print(f'File: {zip_file_name}/{file_path}')
                for match in matches:
                    print(match)
    except FileNotFoundError:
        print(f'Error: The file "{file_path}" was not found.')
    except Exception as e:
        print(f'An error occurred while searching file "{file_path}": {e}')

def extract_and_search(zip_file_path, search_strings, extraction_root):
    # Check if the file is a valid zip file
    if not zipfile.is_zipfile(zip_file_path):
        print(f'Error: "{zip_file_path}" is not a valid ZIP file.')
        return

    try:
        # Create a directory for extracting the zip contents
        extraction_dir = os.path.join(extraction_root, os.path.basename(zip_file_path) + "_extracted")
        with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
            zip_ref.extractall(extraction_dir)

        # Traverse through extracted files and search in each file
        for root, dirs, files in os.walk(extraction_dir):
            for file in files:
                file_path = os.path.join(root, file)

                # If the extracted file is another zip, extract and search recursively
                if zipfile.is_zipfile(file_path):
                    extract_and_search(file_path, search_strings, extraction_dir)
                else:
                    search_in_file(file_path, search_strings, zip_file_path)

    except Exception as e:
        print(f'An error occurred while extracting the zip file: {e}')

if __name__ == "__main__":
    # Check if enough command line arguments are passed
    if len(sys.argv) < 3:
        print("Usage: python search_in_file.py <zip_file_path> <search_string1> <search_string2> ... <search_stringN>")
        sys.exit(1)

    # ZIP file path is the first argument
    zip_file_path = sys.argv[1]

    # Remaining arguments are search strings
    search_strings = sys.argv[2:]

    # Create a temporary directory for all extractions
    temp_extraction_root = 'temp_extracted_logs'

    if os.path.exists(temp_extraction_root):
        shutil.rmtree(temp_extraction_root)  # Clean up any previous runs
    os.makedirs(temp_extraction_root)

    # Call the function to extract and search, starting with the initial zip file
    extract_and_search(zip_file_path, search_strings, temp_extraction_root)

    # Clean up the extracted files afterward
    shutil.rmtree(temp_extraction_root)
