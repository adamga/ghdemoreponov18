import os

# Define the month names
MONTH_NAMES = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
]

def count_albums_by_month(file_path):
    # Initialize the month count array
    month_count = [0] * 12

    # Check if the file exists
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return

    # Open the file and process each line
    with open(file_path, "r") as file:
        for line in file:
            # Parse the line to extract the month of release
            # Assuming the file format matches the COBOL structure:
            # AlbumId (7 chars), Artist (8 chars), Title (20 chars),
            # Year (4 chars), Month (2 chars), Day (2 chars), Genre (10 chars)
            try:
                mo_release = int(line[39:41])  # Extract month (40th and 41st chars, 0-based index)
                if 1 <= mo_release <= 12:
                    month_count[mo_release - 1] += 1
            except ValueError:
                print(f"Skipping invalid line: {line.strip()}")

    # Display the results
    print(f"{'Month':<10} {'AlbumCount':<10}")
    for idx, count in enumerate(month_count):
        print(f"{MONTH_NAMES[idx]:<10} {count:<10}")

# Main function
if __name__ == "__main__":
    # File path to the input file
    file_path = "ALBUMS.DAT"

    # Count albums by month and display the results
    count_albums_by_month(file_path)