awk -F $'\a' '
{
    for (i = 1; i <= NF; i++) {
        if (length($i) != lengths[i] && NR > 1) {
            print "Line", NR, "differs at column", i, "length:", length($i), "!=","expected:", lengths[i]
            print $0
        }
        lengths[i] = length($i)
    }
}
' inputfile


Explanation:
-F $'\a': Specifies the delimiter as Ctrl+G.
for (i = 1; i <= NF; i++): Loops through all columns in the current line.
length($i): Gets the length of the current column.
lengths[i]: Stores the length of the column from the first line (or updates it for subsequent lines).
NR > 1: Ensures that comparison starts from the second line.
print: Outputs any line where a column’s length does not match the expected length.
Replace inputfile with the name of your file.
Output:
If a mismatch is found, the command prints the line number, the column number, the mismatched length, and the line content.
