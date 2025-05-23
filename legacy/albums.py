import sys

# Month names for display
MONTH_NAMES = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
]

def main():
    # Initialize album count for each month
    month_count = [0] * 12

    try:
        with open("ALBUMS.DAT", "r") as f:
            for line in f:
                # Example line format: AlbumId Artist Title YORelease MORelease DORelease Genre
                # Adjust the parsing as per your actual file format
                fields = line.strip().split()
                if len(fields) < 7:
                    continue  # Skip malformed lines

                # Extract month of release (assuming it's the 5th field, zero-based index 4)
                try:
                    mo_release = int(fields[4])
                    if 1 <= mo_release <= 12:
                        month_count[mo_release - 1] += 1
                except ValueError:
                    continue  # Skip lines with invalid month

    except FileNotFoundError:
        print("ALBUMS.DAT file not found.")
        sys.exit(1)

    # Print the heading
    print(f"{'Month':<10} {'AlbumCount':>10}")
    for idx, name in enumerate(MONTH_NAMES):
        print(f"{name:<10} {month_count[idx]:>10}")

if __name__ == "__main__":
    main()