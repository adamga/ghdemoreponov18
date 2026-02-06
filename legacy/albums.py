"""
Album Month Counter
Counts the number of albums released in each month and displays the result.
Converted from COBOL legacy code.
"""

def main():
    # Month names table
    months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    # Initialize month counters
    month_count = [0] * 12
    
    try:
        # Open and read the album file
        with open("ALBUMS.DAT", "r") as album_file:
            for line in album_file:
                if not line.strip():
                    continue
                
                # Parse fixed-width fields from COBOL format
                # AlbumId: 7 chars, Artist: 8 chars, Title: 20 chars
                # Year: 4 chars, Month: 2 chars, Day: 2 chars, Genre: 10 chars
                if len(line) >= 41:
                    album_id = line[0:7].strip()
                    artist = line[7:15].strip()
                    title = line[15:35].strip()
                    year = line[35:39].strip()
                    month = line[39:41].strip()
                    day = line[41:43].strip() if len(line) >= 43 else ""
                    genre = line[43:53].strip() if len(line) >= 53 else ""
                    
                    # Increment the counter for the release month
                    if month.isdigit():
                        month_idx = int(month) - 1
                        if 0 <= month_idx < 12:
                            month_count[month_idx] += 1
        
        # Display the results
        print(" Month       AlbumCount")
        print("-" * 23)
        for i in range(12):
            print(f"{months[i]:12} {month_count[i]:3}")
    
    except FileNotFoundError:
        print("Error: ALBUMS.DAT file not found")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
