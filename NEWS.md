# coronavirusupdate 0.0.1.9000 (Development version)

## Major Improvements

### Code Quality & Reliability
* Added comprehensive error handling to all scraping functions with informative error messages
* Implemented input validation across all functions
* Added graceful handling of NULL inputs and empty results
* Scraping functions now provide detailed warnings when extraction fails

### Documentation
* Added complete roxygen2 documentation to all functions
* Improved function descriptions with parameter details and return values
* Added usage examples and implementation details
* All internal functions now properly documented with @keywords internal

### Testing
* Set up testthat testing framework
* Added unit tests for all extraction functions
* Added data validation tests to ensure data quality
* Added input validation tests for main scraping function
* Created test suite for edge cases and error handling

### GitHub Actions & Automation
* Updated all GitHub Actions to latest versions (checkout@v4, cache@v3, setup-r@v2)
* Improved workflow to skip commits when no new data is available
* Enhanced commit messages to show number of new episodes added
* Added helper script to count new episodes for informative commit messages

### Package Infrastructure
* Updated .gitignore with standard R package exclusions
* Added NEWS.md for tracking package changes
* Updated DESCRIPTION with testthat dependency
* Improved RoxygenNote to version 7.2.3

### Data Quality
* Maintained existing speaker name normalization
* Preserved incremental scraping functionality
* Kept multi-format output support (RDS, RDA, Parquet)

## Bug Fixes
* Fixed potential crashes from NULL HTML responses
* Improved handling of malformed or changed website structure
* Better error messages for debugging scraping failures

---

# coronavirusupdate 0.0.1

## Initial Release

* Initial package release
* Scraping functionality for NDR Coronavirus-Update podcast transcripts
* Incremental scraping support (only fetches new episodes)
* Speaker name normalization
* Multiple output formats (RDS, RDA, Parquet)
* Automated weekly updates via GitHub Actions
* Tidy data format with one row per paragraph
