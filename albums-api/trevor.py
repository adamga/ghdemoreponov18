# I need to convert the code below into python
# public int CountRs(string word)
# {
#     int count = 0;
#     foreach (char c in word)
#     {
#         if (c == 'r')
#         {
#             count++;
#         }
#     }
#     return count;
# }
def count_rs(word):
    count = 0
    for c in word:
        if c == 'r':
            count += 1
    return count
# Test the function