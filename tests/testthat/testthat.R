# tests/testthat.R

# Load required packages
library(testthat)
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(Biostrings)
library(tidyverse)
library(shinyjs)
library(shinycssloaders)

# Set test reporter
reporter <- MultiReporter$new(
  reporters = list(
    ProgressReporter$new(),
    JunitReporter$new(file = "test-results.xml")
  )
)

# Set test environment variables if needed
Sys.setenv(R_TESTS = "")
Sys.setenv(TESTING = "true")

# Source the application files
source("../app.R")
source("../helpers.R")

# Define test context
test_check("CRISPRgRNADesigner", reporter = reporter)

# Configure test parameters
options(testthat.default.check.interval = 1)
options(testthat.default.stack.trace = TRUE)
options(testthat.default.show.progress = TRUE)

# Error handling for tests
options(warn = 1)  # Show warnings as they occur
options(error = function() {
  cat("Error occurred during testing!\n")
  if (interactive()) recover()
})

# Custom test utilities
get_test_sequence <- function() {
  "GCATGCATGCNGGATATATATNGGCGCGCG"
}

get_test_pam <- function() {
  "NGG"
}

# Helper function to check if we're running in test mode
is_testing <- function() {
  identical(Sys.getenv("TESTING"), "true")
}

# Clean up function to run after tests
cleanup <- function() {
  # Remove any temporary files created during testing
  if (file.exists("test-results.xml")) {
    file.remove("test-results.xml")
  }
  
  # Reset environment variables
  Sys.unsetenv("TESTING")
}

# Register cleanup to run on exit
reg.finalizer(environment(), cleanup, onexit = TRUE)

# Print test configuration information
cat("\nTest Configuration:\n")
cat("R Version:", R.version.string, "\n")
cat("testthat Version:", packageVersion("testthat"), "\n")
cat("Test Directory:", getwd(), "\n")
cat("Reporter:", class(reporter)[1], "\n")
cat("\nStarting tests...\n")