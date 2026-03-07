#!/bin/zsh

OUTPUT_FILE="coding_tools/templates_dump.txt"

echo "=== TEMPLATE DUMP ===" > $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

for file in coding_tools/ai_prompt_templates/*; do
  echo "----------------------------------------" >> $OUTPUT_FILE
  echo "FILE: $file" >> $OUTPUT_FILE
  echo "----------------------------------------" >> $OUTPUT_FILE
  cat "$file" >> $OUTPUT_FILE
  echo "" >> $OUTPUT_FILE
done

echo "Templates wurden zusammengefasst in:"
echo "$OUTPUT_FILE"