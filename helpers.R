# helpers.R

library(Biostrings)
library(tidyverse)
library(DT)
library(plotly)
library(RColorBrewer)

#' Validate DNA sequence
#' @param sequence Character string of DNA sequence
#' @return DNAString object if valid, stops with error if invalid
validate_sequence <- function(sequence) {
  # Remove any whitespace and convert to uppercase
  sequence <- gsub("\\s+", "", toupper(sequence))
  
  # Check if sequence contains only valid DNA characters
  if (!grepl("^[ATCGN]+$", sequence)) {
    stop("Invalid DNA sequence. Sequence must contain only A, T, C, G, or N.")
  }
  
  # Create DNAString object
  tryCatch({
    return(DNAString(sequence))
  }, error = function(e) {
    stop("Error creating DNAString object: ", e$message)
  })
}

#' Calculate GC content of a sequence
#' @param seq DNAString object
#' @return GC content percentage
calculate_gc_content <- function(seq) {
  tryCatch({
    gc <- letterFrequency(seq, letters = "GC", as.prob = TRUE)[1] * 100
    round(gc, 1)
  }, error = function(e) {
    warning("Error calculating GC content: ", e$message)
    return(NA)
  })
}

#' Find PAM sites for Cas9
#' @param dna_seq DNAString object
#' @param pam_sequence PAM sequence to search for
#' @return Vector of PAM site positions
find_pam_sites_cas9 <- function(dna_seq, pam_sequence) {
  tryCatch({
    # Convert PAM to pattern
    pam_pattern <- DNAString(pam_sequence)
    
    # Find all PAM sites
    pam_sites <- start(matchPattern(pam_pattern, dna_seq, fixed = FALSE))
    
    # Validate PAM sites are within sequence bounds
    valid_sites <- pam_sites[pam_sites >= 21 & 
                            pam_sites <= (length(dna_seq) - nchar(pam_sequence))]
    
    if (length(valid_sites) == 0) {
      return(numeric(0))
    }
    return(valid_sites)
  }, error = function(e) {
    warning("Error finding PAM sites: ", e$message)
    return(numeric(0))
  })
}

#' Find PAM sites for Cas12a
#' @param dna_seq DNAString object
#' @param pam_sequence PAM sequence to search for
#' @return Vector of PAM site positions
find_pam_sites_cas12a <- function(dna_seq, pam_sequence = "TTTV") {
  tryCatch({
    # Convert PAM to pattern
    pam_pattern <- DNAString(pam_sequence)
    
    # Find all PAM sites
    pam_sites <- start(matchPattern(pam_pattern, dna_seq, fixed = FALSE))
    
    # Validate PAM sites are within sequence bounds
    valid_sites <- pam_sites[pam_sites >= 24 & 
                            pam_sites <= (length(dna_seq) - nchar(pam_sequence))]
    
    if (length(valid_sites) == 0) {
      return(numeric(0))
    }
    return(valid_sites)
  }, error = function(e) {
    warning("Error finding Cas12a PAM sites: ", e$message)
    return(numeric(0))
  })
}

#' Generate gRNA sequence for a given PAM site
#' @param dna_seq DNAString object
#' @param pam_site PAM site position
#' @param crispr_system Type of CRISPR system
#' @return DataFrame with gRNA sequence and position
generate_grna <- function(dna_seq, pam_site, crispr_system) {
  tryCatch({
    # Set gRNA length based on CRISPR system
    grna_length <- switch(crispr_system,
      "cas9" = 20,
      "cas12a" = 23,
      "cas13" = 22,
      20  # default to Cas9 length
    )
    
    # Calculate sequence positions based on CRISPR system
    if (crispr_system == "cas9") {
      start_pos <- pam_site - grna_length
      end_pos <- pam_site - 1
    } else if (crispr_system == "cas12a") {
      start_pos <- pam_site + 4
      end_pos <- start_pos + grna_length - 1
    } else {
      start_pos <- pam_site
      end_pos <- pam_site + grna_length - 1
    }
    
    # Validate positions
    if (start_pos < 1 || end_pos > length(dna_seq)) {
      return(NULL)
    }
    
    # Extract gRNA sequence
    grna_seq <- subseq(dna_seq, start_pos, end_pos)
    
    # Create result tibble
    tibble(
      sequence = as.character(grna_seq),
      position = pam_site,
      gc_content = calculate_gc_content(grna_seq)
    )
  }, error = function(e) {
    warning("Error generating gRNA: ", e$message)
    return(NULL)
  })
}

#' Calculate efficiency score for a gRNA
#' @param gc_content GC content percentage
#' @return Efficiency score (0-100)
calculate_efficiency_score <- function(gc_content) {
  tryCatch({
    # Basic scoring based on GC content
    base_score <- case_when(
      gc_content >= 30 & gc_content <= 70 ~ 100,
      gc_content < 30 ~ gc_content * 2,
      gc_content > 70 ~ (100 - (gc_content - 70) * 2)
    )
    
    # Ensure score is between 0 and 100
    pmax(0, pmin(100, base_score))
  }, error = function(e) {
    warning("Error calculating efficiency score: ", e$message)
    return(NA)
  })
}

#' Calculate specificity score based on potential off-targets
#' @param sequence gRNA sequence
#' @param dna_seq Full DNA sequence
#' @param max_mismatches Maximum allowed mismatches
#' @return Specificity score (0-100)
calculate_specificity_score <- function(sequence, dna_seq, max_mismatches) {
  tryCatch({
    # Find similar sequences allowing for mismatches
    pattern <- DNAString(sequence)
    matches <- countPattern(pattern, dna_seq, max.mismatch = max_mismatches, 
                          with.indels = TRUE)
    
    # Calculate specificity score
    score <- 100 / (1 + log1p(matches - 1))
    round(score, 1)
  }, error = function(e) {
    warning("Error calculating specificity score: ", e$message)
    return(NA)
  })
}

#' Generate off-target analysis heatmap
#' @param grna_data DataFrame of gRNA results
#' @return Plotly heatmap object
plot_offtarget_heatmap <- function(grna_data) {
  # Skip if no data
  if (nrow(grna_data) == 0) {
    return(NULL)
  }
  
  # Create matrix of simulated off-target counts at different mismatch levels
  mismatches <- 0:3
  n_grnas <- nrow(grna_data)
  
  # Generate simulated off-target data
  # In a real application, this would come from actual off-target analysis
  off_targets <- matrix(
    data = NA,
    nrow = n_grnas,
    ncol = length(mismatches)
  )
  
  # Fill matrix with simulated data based on specificity scores
  for (i in 1:n_grnas) {
    base_score <- grna_data$specificity[i]
    off_targets[i,] <- c(
      100,  # Perfect match
      base_score * 0.7 * runif(1, 0.8, 1.2),  # 1 mismatch
      base_score * 0.4 * runif(1, 0.8, 1.2),  # 2 mismatches
      base_score * 0.1 * runif(1, 0.8, 1.2)   # 3 mismatches
    )
  }
  
  # Create the heatmap using plotly
  plot_ly(
    x = mismatches,
    y = grna_data$sequence,
    z = off_targets,
    type = "heatmap",
    colorscale = "Blues",
    reversescale = TRUE,
    colorbar = list(
      title = "Relative Off-target Activity (%)"
    )
  ) %>%
    layout(
      title = "Off-target Analysis Heatmap",
      xaxis = list(
        title = "Number of Mismatches",
        ticktext = c("0 (On-target)", "1 mismatch", "2 mismatches", "3 mismatches"),
        tickvals = c(0, 1, 2, 3)
      ),
      yaxis = list(
        title = "gRNA Sequence",
        tickfont = list(size = 10)
      ),
      margin = list(l = 150)  # Add margin for sequence labels
    )
}

#' Design gRNAs for a given sequence
#' @param sequence DNA sequence string
#' @param crispr_system Type of CRISPR system
#' @param max_mismatches Maximum allowed mismatches
#' @param pam_sequence PAM sequence
#' @param min_efficiency Minimum efficiency score threshold
#' @return DataFrame with gRNA designs and scores
design_grnas <- function(sequence, crispr_system = "cas9", 
                        max_mismatches = 3, pam_sequence = "NGG",
                        min_efficiency = 50) {
  
  # Create empty result tibble
  empty_result <- tibble(
    sequence = character(0),
    position = integer(0),
    efficiency = numeric(0),
    specificity = numeric(0),
    total_score = numeric(0)
  )
  
  # Validate input sequence
  tryCatch({
    dna_seq <- validate_sequence(sequence)
  }, error = function(e) {
    warning("Sequence validation error: ", e$message)
    return(empty_result)
  })
  
  # Find PAM sites based on CRISPR system
  pam_sites <- switch(crispr_system,
    "cas9" = find_pam_sites_cas9(dna_seq, pam_sequence),
    "cas12a" = find_pam_sites_cas12a(dna_seq, pam_sequence),
    "cas13" = seq(1, length(dna_seq) - 21),
    find_pam_sites_cas9(dna_seq, pam_sequence)  # default to Cas9
  )
  
  if (length(pam_sites) == 0) {
    return(empty_result)
  }
  
  # Generate gRNAs
  grnas <- map_dfr(pam_sites, ~generate_grna(dna_seq, .x, crispr_system))
  
  if (nrow(grnas) == 0) {
    return(empty_result)
  }
  
  # Calculate scores and filter results
  grnas %>%
    filter(!is.na(sequence)) %>%
    mutate(
      efficiency = map_dbl(gc_content, ~calculate_efficiency_score(.x)),
      specificity = map_dbl(sequence, ~calculate_specificity_score(.x, dna_seq, max_mismatches)),
      total_score = (efficiency * 0.6 + specificity * 0.4) %>% round(2)
    ) %>%
    filter(efficiency >= min_efficiency) %>%
    arrange(desc(total_score)) %>%
    select(sequence, position, efficiency, specificity, total_score)
}