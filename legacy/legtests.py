import unittest
from unittest.mock import mock_open, patch
from legacy import count_albums_by_month

class TestCountAlbumsByMonth(unittest.TestCase):
    @patch("builtins.open", new_callable=mock_open, read_data="0000001Artist1Title1              20230101Genre1    \n"
                                                             "0000002Artist2Title2              20230201Genre2    \n"
                                                             "0000003Artist3Title3              20230301Genre3    \n")
    @patch("os.path.exists", return_value=True)
    def test_valid_file(self, mock_exists, mock_file):
        # Capture printed output
        with patch("builtins.print") as mock_print:
            count_albums_by_month("dummy_path")
            # Verify output
            mock_print.assert_any_call("Month      AlbumCount")
            mock_print.assert_any_call("January    1         ")
            mock_print.assert_any_call("February   1         ")
            mock_print.assert_any_call("March      1         ")

    @patch("builtins.open", new_callable=mock_open, read_data="0000001Artist1Title1              20230101Genre1    \n"
                                                             "InvalidLineWithoutProperFormat\n"
                                                             "0000003Artist3Title3              20230301Genre3    \n")
    @patch("os.path.exists", return_value=True)
    def test_file_with_invalid_lines(self, mock_exists, mock_file):
        # Capture printed output
        with patch("builtins.print") as mock_print:
            count_albums_by_month("dummy_path")
            # Verify output
            mock_print.assert_any_call("Month      AlbumCount")
            mock_print.assert_any_call("January    1         ")
            mock_print.assert_any_call("March      1         ")
            mock_print.assert_any_call("Skipping invalid line: InvalidLineWithoutProperFormat")

    @patch("builtins.open", new_callable=mock_open, read_data="")
    @patch("os.path.exists", return_value=True)
    def test_empty_file(self, mock_exists, mock_file):
        # Capture printed output
        with patch("builtins.print") as mock_print:
            count_albums_by_month("dummy_path")
            # Verify output
            mock_print.assert_any_call("Month      AlbumCount")
            for month in ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]:
                mock_print.assert_any_call(f"{month:<10} 0         ")

    @patch("os.path.exists", return_value=False)
    def test_non_existent_file(self, mock_exists):
        # Capture printed output
        with patch("builtins.print") as mock_print:
            count_albums_by_month("dummy_path")
            # Verify error message
            mock_print.assert_called_once_with("Error: File 'dummy_path' not found.")

if __name__ == "__main__":
    unittest.main()