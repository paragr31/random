import pandas as pd

# Input data dictionary
recon_data = {
    'sybase_iqa_counts': {
        'orders': {
            '2024-01-02': 2343,
            '2024-01-03': 2345
        },
        'transactions': {
            '2024-01-02': 2343,
            '2024-01-03': 2345
        }
    },
    'sybase_iq_counts': {
        'orders': {
            ' 2024-01-02': 2343,
            ' 2024-01-03': 2345,
            ' 2024-12-01': 1223
        },
        'transactions': {
            '2024-01-02': 2343,
            '2024-01-05': 2345
        }
    }
}

# Helper function to convert dictionary to DataFrame
def dict_to_dataframe(data):
    rows = []
    for category, dates in data.items():
        for date, count in dates.items():
            rows.append({'Category': category, 'Date': date.strip(), 'Count': count})
    return pd.DataFrame(rows)

# Convert sections to DataFrames
iqa_df = dict_to_dataframe(recon_data['sybase_iqa_counts'])
iq_df = dict_to_dataframe(recon_data['sybase_iq_counts'])

# Perform an outer merge to find mismatches
merged_df = pd.merge(
    iqa_df,
    iq_df,
    on=['Category', 'Date'],
    how='outer',
    suffixes=('_iqa', '_iq'),
    indicator=True
)

# Replace NaN with NULL
merged_df.fillna('NULL', inplace=True)

# Add a column to indicate mismatches
merged_df['Mismatch'] = (merged_df['_merge'] != 'both') | (merged_df['Count_iqa'] != merged_df['Count_iq'])

# Select relevant columns for display
highlighted_df = merged_df[['Category', 'Date', 'Count_iqa', 'Count_iq', 'Mismatch']]

# Export to HTML with mismatches highlighted
def style_table(df):
    def highlight_row(row):
        if row['Mismatch']:
            return ['background-color: red'] * len(row)
        return ['background-color: lightgreen'] * len(row)
    
    return df.style.apply(highlight_row, axis=1).to_html()

# Generate styled HTML and save to file
html_output = style_table(highlighted_df)
html_file_path = "recon_diff.html"

with open(html_file_path, "w") as file:
    file.write(html_output)

print(f"Comparison results saved to {html_file_path}")
