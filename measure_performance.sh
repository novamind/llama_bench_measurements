#!/bin/bash


llama_bench_path="$HOME/llama.cpp/llama-bench"
results_file="llama_bench_raw_results.md"
output_csv="llama_bench_aggregated_output.csv"
model_dir="."
ngl=100


if [ ! -f "$llama_bench_path" ]; then
    echo "Error: llama-bench not found at $llama_bench_path"
    exit 1
fi


echo "model_name,size,pp512,tg128" > "$output_csv"


parse_and_append_to_csv() {
    local model_name="$1"
    local output="$2"
    local size="" pp512="" tg128=""


    while IFS= read -r line; do
        [[ $line =~ \|\ *llama.*\ *\|\ *([0-9.]+)\ GiB\ *\|\ *.*\ *\|\ *(pp512|tg128)\ *\|\ *([0-9.]+) ]] && {
            size="${BASH_REMATCH[1]}"
            [[ ${BASH_REMATCH[2]} == "pp512" ]] && pp512="${BASH_REMATCH[3]}" || tg128="${BASH_REMATCH[3]}"
        }
    done <<< "$output"


    echo "$model_name,$size,$pp512,$tg128" >> "$output_csv"
}


find "$model_dir" -name "*.gguf" -print0 | while IFS= read -r -d '' model; do
    model_name=$(basename "$model" .gguf)


    echo "Running llama-bench on $model_name..."
    output=$("$llama_bench_path" -m "$model" -ngl "$ngl")
   
    {
        echo -e "Results for $model_name:\n------------------------\n$output\n\n"
    } >> "$results_file"


    parse_and_append_to_csv "$model_name" "$output"
done


echo "All results have been combined into $results_file"
echo "CSV file has been created at $output_csv."