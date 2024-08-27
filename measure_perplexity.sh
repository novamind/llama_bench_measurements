#!/bin/bash

llama_perplexity="$HOME/llama.cpp/llama-perplexity"
test_file="pikovaya_dama.txt"
gguf_folder="."
ngl=100
output_file="llama_perplexity_results.csv"
> "$output_file"


for gguf_file in "$gguf_folder"/*.gguf; do
    file_name=$(basename "$gguf_file" .gguf)
    output=$(eval "$llama_perplexity -f $test_file -m $gguf_file -ngl $ngl")
    final_estimate=$(echo "$output" | grep -o 'Final estimate: PPL = [0-9.]*' | sed 's/Final estimate: PPL = //')
    echo "$file_name,$final_estimate" >> "$output_file"
done
