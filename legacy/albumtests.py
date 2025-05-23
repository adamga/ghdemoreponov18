import io
import sys
import types
import builtins
import pytest
from legacy import albums

# test_albums.py


def test_count_albums_by_month_normal_case(monkeypatch):
    data = """1 Artist1 Title1 2020 1 15 Rock
2 Artist2 Title2 2021 2 10 Pop
3 Artist3 Title3 2022 1 20 Jazz
4 Artist4 Title4 2023 12 5 Blues
"""
    file_obj = io.StringIO(data)
    result = albums.count_albums_by_month(file_obj)
    expected = [2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
    assert result == expected

def test_count_albums_by_month_malformed_lines():
    data = """1 Artist1 Title1 2020 1 15 Rock
MALFORMED LINE
2 Artist2 Title2 2021 2 10 Pop
3 Artist3 Title3 2022
4 Artist4 Title4 2023 12 5 Blues
"""
    file_obj = io.StringIO(data)
    result = albums.count_albums_by_month(file_obj)
    expected = [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
    assert result == expected

def test_count_albums_by_month_invalid_months():
    data = """1 Artist1 Title1 2020 0 15 Rock
2 Artist2 Title2 2021 13 10 Pop
3 Artist3 Title3 2022 -1 20 Jazz
4 Artist4 Title4 2023 5 5 Blues
5 Artist5 Title5 2024 xx 1 Metal
"""
    file_obj = io.StringIO(data)
    result = albums.count_albums_by_month(file_obj)
    expected = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]
    assert result == expected

def test_count_albums_by_month_empty_file():
    file_obj = io.StringIO("")
    result = albums.count_albums_by_month(file_obj)
    expected = [0] * 12
    assert result == expected

def test_main_prints_correct_output(monkeypatch, capsys):
    data = """1 Artist1 Title1 2020 1 15 Rock
2 Artist2 Title2 2021 2 10 Pop
3 Artist3 Title3 2022 1 20 Jazz
4 Artist4 Title4 2023 12 5 Blues
"""
    # Patch open to return our StringIO
    monkeypatch.setattr(builtins, "open", lambda *a, **k: io.StringIO(data))
    # Patch sys.exit to raise SystemExit
    monkeypatch.setattr(sys, "exit", lambda code=0: (_ for _ in ()).throw(SystemExit(code)))
    albums.main()
    captured = capsys.readouterr()
    assert "January" in captured.out
    assert "February" in captured.out
    assert "December" in captured.out
    assert "2" in captured.out  # January count
    assert "1" in captured.out  # February and December counts

# Add the function to be tested in albums.py:
# def count_albums_by_month(file_obj):
#     month_count = [0] * 12
#     for line in file_obj:
#         fields = line.strip().split()
#         if len(fields) < 7:
#             continue
#         try:
#             mo_release = int(fields[4])
#             if 1 <= mo_release <= 12:
#                 month_count[mo_release - 1] += 1
#         except ValueError:
#             continue
#     return month_count