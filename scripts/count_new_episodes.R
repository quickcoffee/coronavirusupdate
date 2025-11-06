# Helper script to count newly added episodes
# Used by GitHub Actions to create informative commit messages

# Read the git status to check for changes
git_status <- system("git status --porcelain data/", intern = TRUE)

if (length(git_status) == 0) {
  cat("NO_CHANGES")
  quit(save = "no", status = 0)
}

# If there are changes, try to count new episodes
tryCatch({
  # Load the new data
  if (file.exists("data/coronavirusupdate_transcripts.rds")) {
    new_data <- readRDS("data/coronavirusupdate_transcripts.rds")

    # Get unique episode count
    total_episodes <- length(unique(new_data$episode_no))

    # Try to get previous episode count from git
    prev_count_cmd <- "git show HEAD:data/coronavirusupdate_transcripts.rds 2>/dev/null"
    prev_exists <- system(prev_count_cmd, ignore.stdout = TRUE, ignore.stderr = TRUE) == 0

    if (prev_exists) {
      # Create temp file for previous version
      temp_file <- tempfile(fileext = ".rds")
      system(paste("git show HEAD:data/coronavirusupdate_transcripts.rds >", temp_file))

      old_data <- readRDS(temp_file)
      old_episodes <- length(unique(old_data$episode_no))

      new_episodes <- total_episodes - old_episodes

      if (new_episodes > 0) {
        cat(sprintf("Added %d new episode%s (total: %d)",
                    new_episodes,
                    ifelse(new_episodes == 1, "", "s"),
                    total_episodes))
      } else {
        cat(sprintf("Updated transcript data (%d episodes)", total_episodes))
      }

      unlink(temp_file)
    } else {
      # First commit
      cat(sprintf("Initial data: %d episodes", total_episodes))
    }
  } else {
    cat("Updated data files")
  }
}, error = function(e) {
  cat("Updated transcript data")
})
