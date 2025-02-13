using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;
using static PMDG_NG3_CDU_Test.PMDG_NG3_SDK;

namespace PMDG_NG3_CDU_Test
{
    public class CDURenderer
    {
        private const int CELL_WIDTH = 30;
        private const int CELL_HEIGHT = 45;
        private readonly Canvas canvas;

        public CDURenderer(Canvas canvas)
        {
            this.canvas = canvas;
        }

        public void Render(PMDG_NG3_CDU_Screen screen)
        {
            canvas.Children.Clear();

            for (int x = 0; x < PMDG_NG3_SDK.CDU_COLUMNS; x++)
            {
                for (int y = 0; y < PMDG_NG3_SDK.CDU_ROWS; y++)
                {
                    var cell = screen.Cells[y * PMDG_NG3_SDK.CDU_COLUMNS + x];
                    RenderCell(cell, x, y);
                }
            }
        }

        private void RenderCell(PMDG_NG3_CDU_Cell cell, int x, int y)
        {
            // Draw cell background
            var rect = new Rectangle
            {
                Width = CELL_WIDTH,
                Height = CELL_HEIGHT,
                Fill = (cell.Flags & PMDG_NG3_CDU_FLAG.REVERSE) != 0 
                    ? Brushes.Gray 
                    : Brushes.Black
            };
            Canvas.SetLeft(rect, x * CELL_WIDTH);
            Canvas.SetTop(rect, y * CELL_HEIGHT);
            canvas.Children.Add(rect);

            // Draw cell content
            var textBlock = new TextBlock
            {
                Text = ((char)cell.Symbol).ToString(),
                FontFamily = new FontFamily("Microsoft Sans Serif"),
                FontSize = (cell.Flags & PMDG_NG3_CDU_FLAG.SMALL_FONT) != 0 ? 32 : 42,
                FontWeight = FontWeights.Bold,
                Foreground = GetBrush(cell),
                TextAlignment = TextAlignment.Center
            };

            Canvas.SetLeft(textBlock, x * CELL_WIDTH);
            Canvas.SetTop(textBlock, y * CELL_HEIGHT);
            canvas.Children.Add(textBlock);
        }

        private static Brush GetBrush(PMDG_NG3_CDU_Cell cell)
        {
            if ((cell.Flags & PMDG_NG3_CDU_FLAG.UNUSED) != 0)
                return Brushes.Gray;

            return cell.Color switch
            {
                PMDG_NG3_CDU_COLOR.WHITE => Brushes.White,
                PMDG_NG3_CDU_COLOR.GREEN => Brushes.LightGreen,
                PMDG_NG3_CDU_COLOR.CYAN => Brushes.Cyan,
                PMDG_NG3_CDU_COLOR.MAGENTA => Brushes.Magenta,
                PMDG_NG3_CDU_COLOR.AMBER => Brushes.Orange,
                PMDG_NG3_CDU_COLOR.RED => Brushes.Red,
                _ => Brushes.White
            };
        }
    }
}