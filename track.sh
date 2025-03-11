#!/bin/bash

file="last_write.txt"

while true; do
    # Get memory and CPU usage
    read mem max_mem cpu <<< "$(free -m | awk '/Mem:/ {print $3, $2}') $(mpstat 1 1 | awk '/Average/ {print 100 - $NF}')"

    # Calculate memory percentage, protect against division by zero
    if [ "$max_mem" -eq 0 ]; then
        mem_per=0
    else
        mem_per=$(echo "scale=2; ($mem / $max_mem) * 100" | bc)
    fi

    # Check if CPU usage > 2%
    if (( $(echo "$cpu > 80" | bc -l) )); then
        echo "CPU hit $cpu"

        current_time=$(date +%s.%3N)

        # Load last_write from file, handle empty or nonexistent case
        if [ -s "$file" ]; then
            last_write=$(cat "$file")
        else
            last_write=""
        fi

        log_time=$(date +"%Y-%m-%d %H:%M:%S.%3N")

        # Calculate time_diff and act based on last_write
        if [ -n "$last_write" ]; then
            time_diff=$(echo "$current_time - $last_write" | bc)
            if [ $(echo "$time_diff > 5" | bc) -eq 1 ]; then
                psql -f "./get_cur_query" -o "$log_time.csv" --csv
                echo "Logging to $log_time.csv (time_diff: $time_diff s)"
                echo "$current_time" > "$file"
            else
                echo "Skipping log, time_diff ($time_diff s) <= 5s"
            fi
        else
            # First run, no last_write
            psql -f "./get_cur_query" -o "$log_time.csv" --csv
            echo "First run, logging to $log_time.csv"
            echo "$current_time" > "$file"
        fi
    fi

    # Delay 5 seconds before next iteration
    sleep 1
done