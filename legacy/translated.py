from collections import Counter

MONTH_NAMES = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
]


def extract_month(line: str) -> int:
    # Based on the COBOL layout, month is characters 40-41 in 1-based terms.
    return int(line[39:41].strip())


def main() -> None:
    counts = Counter()

    with open("ALBUMS.DAT", "r", encoding="utf-8") as f:
        for line in f:
            if not line.strip():
                continue

            month = extract_month(line)
            if 1 <= month <= 12:
                counts[month] += 1

    print("Month      AlbumCount")
    for month_number, month_name in enumerate(MONTH_NAMES, start=1):
        print(f"{month_name:<10} {counts[month_number]}")


if __name__ == "__main__":
    main()