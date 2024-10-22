# CRISPR gRNA Designer

## Overview
An R Shiny application for designing and evaluating CRISPR guide RNAs (gRNAs). This tool supports multiple CRISPR systems (Cas9, Cas12a, and Cas13) and provides comprehensive analysis tools for gRNA design and evaluation.

![CRISPR gRNA Designer Screenshot](screenshots/app_screenshot.png)

## Features
- Support for multiple CRISPR systems (Cas9, Cas12a, Cas13)
- Interactive visualization of gRNA properties
- Off-target analysis with heatmap visualization
- Efficiency and specificity scoring
- Customizable parameters
- Export functionality for further analysis

## Installation

### Prerequisites
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
  - RColorBrewer

### Setup
1. Clone the repository:
```bash
git clone https://github.com/winniecook/crispr-guide-designer-rshiny
cd crispr-grna-designer
```

2. Install required packages:
```R
source("install_dependencies.R")
```

3. Run the application:
```R
shiny::runApp()
```

## Usage
1. Input your DNA sequence
2. Select CRISPR system (Cas9, Cas12a, or Cas13)
3. Adjust parameters as needed:
   - Maximum mismatches
   - PAM sequence
   - Minimum efficiency threshold
4. Click "Design gRNAs" to generate results
5. View results in the data table and visualization tabs

## File Structure
```
crispr-grna-designer/
├── app.R               # Main application file
├── helpers.R           # Helper functions
├── install_dependencies.R  # Package installation script
├── tests/             # Test directory
│   ├── testthat.R    # Test configuration
│   └── testthat/     # Test files
├── www/              # Static assets
└── README.md         # This file
```

## Contributing
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Testing
Run tests using:
```R
testthat::test_dir('tests/testthat')
```

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Authors
* **Your Name** - *Initial work*

## Acknowledgments
* Based on established CRISPR design principles
* Inspired by various CRISPR design tools in the field
