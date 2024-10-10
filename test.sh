#!/bin/bash

# Number of log files to generate
NUM_FILES=500

# Directory to save the log files and subdirectories
LOG_DIR="./logs"
LOG_DIR_ZIP="./logs_zip"

# Create the logs directory if it doesn't exist
mkdir -p "$LOG_DIR"
# Create the logs directory if it doesn't exist
mkdir -p "$LOG_DIR_ZIP"

# Loop to create log files
for i in $(seq 1 $NUM_FILES); do
  LOG_FILE="$LOG_DIR/logfile_$i.log"

  # Create a single log file
  cat <<EOL > "$LOG_FILE"
2024-10-10 08:15:30 [INFO] App started successfully.
2024-10-10 08:15:32 [INFO] Loading configuration from config.yaml
2024-10-10 08:15:32 [DEBUG] Configuration file parsed: { "logging": "info", "retry_attempts": 3 }
2024-10-10 08:15:33 [INFO] Establishing database connection...
2024-10-10 08:15:34 [INFO] Database connection established successfully. Host: db-server-1, Port: 5432
2024-10-10 08:15:36 [WARN] High memory usage detected: 85%. Consider optimizing your queries or upgrading the server.
2024-10-10 08:15:38 [INFO] Starting background task: LogProcessor
2024-10-10 08:15:39 [DEBUG] LogProcessor task initialized with batch_size: 1000, interval: 60s
2024-10-10 08:15:45 [ERROR] Failed to retrieve user data from Redis. Key: user_1234, Error: Connection timeout
2024-10-10 08:15:46 [INFO] Retrying Redis connection... attempt 1 of 3
2024-10-10 08:15:50 [ERROR] Redis connection failed. Attempt 2 of 3. Error: No route to host
2024-10-10 08:15:55 [ERROR] Redis connection failed. Attempt 3 of 3. Error: No route to host
2024-10-10 08:16:00 [FATAL] Unable to connect to Redis after 3 attempts. Shutting down the application.
2024-10-10 08:16:01 [INFO] Gracefully shutting down background tasks...
2024-10-10 08:16:05 [INFO] Background task LogProcessor stopped.
2024-10-10 08:16:06 [ERROR] Error while writing logs to storage: Disk space full.
2024-10-10 08:16:07 [INFO] Database connection closed.
2024-10-10 08:16:08 [INFO] App shutdown completed.

2024-10-10 09:05:10 [INFO] App started successfully.
2024-10-10 09:05:12 [INFO] Loading configuration from config.yaml
2024-10-10 09:05:12 [ERROR] Malformed configuration file: 'retry_attempts' is not a number.
2024-10-10 09:05:13 [FATAL] Application configuration invalid. Exiting.
EOL

  # For some files, create subdirectories with additional log files
  if (( i % 2 == 0 )); then
    SUBDIR="$LOG_DIR/subdir_$i"
    mkdir -p "$SUBDIR"
    
    # Generate additional log files in the subdirectory
    for j in $(seq 1 3); do
      SUB_LOG="$SUBDIR/logfile_sub_$j.log"
      echo "2024-10-10 10:00:00 [INFO] Sub log $j created in subdir_$i" > "$SUB_LOG"
    done
  fi

  # Zip the log file and any subdirectories (if they exist)
  if (( i % 2 == 0 )); then
    zip -r "logfile_$i.zip" "$LOG_FILE" "$SUBDIR"
  else
    zip "logfile_$i.zip" "$LOG_FILE"
  fi

  mv logfile_$i.zip $LOG_DIR_ZIP/

  echo "Generated logfile_$i.zip"
done

# Clean up the log directory
rm -r "$LOG_DIR"

echo "All log files have been zipped and log directory cleaned up."
