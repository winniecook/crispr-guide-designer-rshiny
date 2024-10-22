# CRISPR gRNA Designer Pro Documentation

## Overview

This R Shiny application is designed to help researchers design and evaluate guide RNAs (gRNAs) for CRISPR-based genome editing. It supports multiple CRISPR systems (Cas9, Cas12a, and Cas13) and provides comprehensive analysis tools for gRNA design and evaluation.

## Features

### 1. gRNA Design
- Support for multiple CRISPR systems:
  - Cas9 (NGG PAM)
  - Cas12a/Cpf1 (TTTV PAM)
  - Cas13 (PAM-independent)
- Customizable parameters:
  - Maximum mismatches allowed
  - Custom PAM sequences
  - Minimum efficiency threshold
- Advanced scoring system incorporating:
  - GC content optimization
  - Secondary structure prediction
  - Homopolymer avoidance
  - Off-target potential

### 2. Analysis Tools
- Interactive data visualization:
  - Efficiency score distribution
  - Off-target analysis heatmap
  - Efficiency vs. Specificity scatter plots
- Sortable and filterable results table
- Export options for further analysis

### 3. Score Calculations

#### Efficiency Score (0-100)
- Based on:
  - Optimal GC content (30-70%)
  - Absence of homopolymer runs
  - Position-specific nucleotide preferences
  - Secondary structure prediction

#### Specificity Score (0-100)
- Calculated using:
  - Genome-wide off-target search
  - Mismatch tolerance analysis
  - Position-weighted scoring

## Usage Instructions

1. **Input Sequence**
   - Paste your DNA sequence in the text area
   - Ensure the sequence contains only valid nucleotides (A, T, G, C)

2. **Configure Parameters**
   - Select CRISPR system
   - Set maximum allowed mismatches
   - Specify PAM sequence (if applicable)
   - Adjust minimum efficiency threshold

3. **Analyze Results**
   - Review the data table for detailed gRNA information
   - Explore visualizations in the Analysis tab
   - Export results for further analysis

## Technical Details

### Scoring Algorithm

The total score for each gRNA is calculated as:
```
Total Score = (Efficiency Score × 0.6) + (Specificity Score × 0.4)
```

### File Structure
```
crispr-grna-designer/
├── app.R           # Main application file
├── helpers.R       # Helper functions
├── docs.md         # Documentation
├── www/           # Static assets
└── data/          # Reference data
```

## Requirements

- R version 4.0.0 or higher
- Required R packages:
  - shiny
  - shinydashboard
  - Biostrings
  - tidyverse
  - plotly
  - DT
  - shinyjs
  - shinycssloaders

## Installation

1. Clone the repository
2. Install required packages:
```R
install.packages(c("shiny", "shinydashboard", "Biostrings", "tidyverse", 
                  "plotly", "DT", "shinyjs", "shinycssloaders"))
```
3. Run the application:
```R
shiny::runApp()
```