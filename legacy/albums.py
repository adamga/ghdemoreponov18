# Define the month names
MONTH_NAMES = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
]

def count_albums_by_month(file_path):
    # Initialize a dictionary to store the count of albums for each month
    month_count = {month: 0 for month in MONTH_NAMES}

    try:
        # Open the file and process each line
        with open(file_path, 'r') as file:
            for line in file:
                # Parse the line to extract the month of release
                # Assuming the file format is: AlbumId,Artist,Title,Year,Month,Day,Genre
                fields = line.strip().split(',')
                if len(fields) < 6:
                    continue  # Skip invalid lines
                month_index = int(fields[4]) - 1  # Convert month to zero-based index
                if 0 <= month_index < 12:
                    month_name = MONTH_NAMES[month_index]
                    month_count[month_name] += 1
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        return
    except Exception as e:
        print(f"Error: {e}")
        return

    # Display the results
    print(f"{'Month':<10} {'AlbumCount':<10}")
    for month, count in month_count.items():
        print(f"{month:<10} {count:<10}")

# Main program
if __name__ == "__main__":
    # Replace 'ALBUMS.DAT' with the path to your input file
    count_albums_by_month("ALBUMS.DAT")