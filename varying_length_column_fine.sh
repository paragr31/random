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


awk -F $'\a' '
NR == FNR {
    expected_lengths[FNR] = $1  # Read expected lengths from the length file
    next
}
{
    for (i = 1; i <= NF; i++) {
        if (i > length(expected_lengths)) {
            print "Line", NR, "has more columns than expected."
            print $0
            next
        }
        if (length($i) != expected_lengths[i]) {
            print "Line", NR, "differs at column", i, "length:", length($i), "!= expected:", expected_lengths[i]
            print $0
        }
    }
}
' lengthsfile inputfile

Explanation:
-F $'\a': Sets the field separator to Ctrl+G.
NR == FNR: Differentiates between the two files:
When reading the first file (lengthsfile), it stores the expected lengths in an array expected_lengths.
Each line in lengthsfile corresponds to the expected lengths for each column (one length per line).
length($i) != expected_lengths[i]: Compares the length of each column with the expected value.
print: Outputs lines with mismatched lengths or extra columns.
Input Files:
lengthsfile: This file contains one number per line, where each number specifies the expected length of the corresponding column. For example:

Copy code
1
5
3
(Means column 1 should be length 1, column 2 length 5, column 3 length 3).

inputfile: The file to check, where columns are separated by Ctrl+G.


awk -F $'\a' '{if (length($COLUMN) != EXPECTED_LENGTH) print "Line", NR, "Column", COLUMN, "Length:", length($COLUMN), "!= Expected:", EXPECTED_LENGTH, $0}' COLUMN=2 EXPECTED_LENGTH=5 inputfile


Explanation:
-F $'\a': Sets the field separator to Ctrl+G.
COLUMN=2: Specify the field/column number to check (e.g., column 2).
EXPECTED_LENGTH=5: Specify the expected length of the column (e.g., 5).
length($COLUMN): Calculates the actual length of the specified column.
print: Prints the line number, column number, actual length, expected length, and the line content if the condition fails.
inputfile: Replace this with your actual file name.
Example:
Suppose inputfile contains:

Copy code
123^Ghello^G456
789^Ghi^G12
345^Gworld^G789
(^G is a Ctrl+G character).

Run the command with:

bash
Copy code
awk -F $'\a' '{if (length($COLUMN) != EXPECTED_LENGTH) print "Line", NR, "Column", COLUMN, "Length:", length($COLUMN), "!= Expected:", EXPECTED_LENGTH, $0}' COLUMN=2 EXPECTED_LENGTH=5 inputfile
Output:
mathematica
Copy code
Line 2 Column 2 Length: 2 != Expected: 5 789^Ghi^G12
