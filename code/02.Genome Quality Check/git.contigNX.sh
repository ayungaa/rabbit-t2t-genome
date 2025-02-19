#!/bin/bash
# Input file containing sequence lengths
INPUT_FILE="NZRB.seqlen"
# Output file to save the results
OUTPUT_FILE="NZRB.Nx"
# Clear the output file if it already exists
> "$OUTPUT_FILE"
# Loop through x values from 1 to 100
for x in $(seq 1 100); do
    # Call the Python script and append the result to the output file
    python Nx.py --input "$INPUT_FILE" -x "$x" >> "$OUTPUT_FILE"
done
echo "All Nx values have been calculated and saved to $OUTPUT_FILE."



#!/bin/bash
# Input file containing sequence lengths
INPUT_FILE="OryCun2.seqlen"
# Output file to save the results
OUTPUT_FILE="OryCun2.Nx"
# Clear the output file if it already exists
> "$OUTPUT_FILE"
# Loop through x values from 1 to 100
for x in $(seq 1 100); do
    # Call the Python script and append the result to the output file
    python Nx.py --input "$INPUT_FILE" -x "$x" >> "$OUTPUT_FILE"
done
echo "All Nx values have been calculated and saved to $OUTPUT_FILE."



#!/bin/bash
# Input file containing sequence lengths
INPUT_FILE="OryCun3.seqlen"
# Output file to save the results
OUTPUT_FILE="OryCun3.Nx"
# Clear the output file if it already exists
> "$OUTPUT_FILE"
# Loop through x values from 1 to 100
for x in $(seq 1 100); do
    # Call the Python script and append the result to the output file
    python Nx.py --input "$INPUT_FILE" -x "$x" >> "$OUTPUT_FILE"
done
echo "All Nx values have been calculated and saved to $OUTPUT_FILE."



#!/bin/bash
# Input file containing sequence lengths
INPUT_FILE="UMNZW1.seqlen"
# Output file to save the results
OUTPUT_FILE="UMNZW1.Nx"
# Clear the output file if it already exists
> "$OUTPUT_FILE"
# Loop through x values from 1 to 100
for x in $(seq 1 100); do
    # Call the Python script and append the result to the output file
    python Nx.py --input "$INPUT_FILE" -x "$x" >> "$OUTPUT_FILE"
done
echo "All Nx values have been calculated and saved to $OUTPUT_FILE."



#!/bin/bash
# Input file containing sequence lengths
INPUT_FILE="mOryCun1.1.seqlen"
# Output file to save the results
OUTPUT_FILE="mOryCun1.Nx"
# Clear the output file if it already exists
> "$OUTPUT_FILE"
# Loop through x values from 1 to 100
for x in $(seq 1 100); do
    # Call the Python script and append the result to the output file
    python Nx.py --input "$INPUT_FILE" -x "$x" >> "$OUTPUT_FILE"
    done
echo "All Nx values have been calculated and saved to $OUTPUT_FILE."




