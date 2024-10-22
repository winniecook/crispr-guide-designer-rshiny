# tests/testthat/test_helpers.R
library(testthat)
library(Biostrings)

source("../../helpers.R")

test_that("GC content calculation works correctly", {
  seq <- DNAString("GCGCATATGC")
  expect_equal(calculate_gc_content(seq), 50)
  
  seq <- DNAString("GCGCGC")
  expect_equal(calculate_gc_content(seq), 100)
  
  seq <- DNAString("ATATAT")
  expect_equal(calculate_gc_content(seq), 0)
})

test_that("PAM site finding works for different CRISPR systems", {
  dna_seq <- DNAString("GCATGCATGCNGGATATATATNGGCGCGCG")
  
  # Test Cas9 PAM finding
  cas9_pams <- find_pam_sites_cas9(dna_seq, "NGG")
  expect_gt(length(cas9_pams), 0)
  
  # Test Cas12a PAM finding
  cas12a_pams <- find_pam_sites_cas12a(dna_seq, "TTTV")
  expect_type(cas12a_pams, "integer")
})

test_that("gRNA generation produces valid sequences", {
  dna_seq <- DNAString("GCATGCATGCNGGATATATATNGGCGCGCG")
  pam_site <- 10
  
  # Test Cas9 gRNA generation
  cas9_grna <- generate_grna(dna_seq, pam_site, "cas9")
  expect_equal(nchar(cas9_grna$sequence), 20)
  
  # Test Cas12a gRNA generation
  cas12a_grna <- generate_grna(dna_seq, pam_site, "cas12a")
  expect_equal(nchar(cas12a_grna$sequence), 23)
})

test_that("Scoring functions return valid values", {
  # Test efficiency score
  efficiency <- calculate_efficiency_score("GCATGCATGCATGCATGCAT", 50)
  expect_gte(efficiency, 0)
  expect_lte(efficiency, 100)
  
  # Test specificity score
  dna_seq <- DNAString("GCATGCATGCNGGATATATATNGGCGCGCG")
  specificity <- calculate_specificity_score("GCATGCATGC", dna_seq, 3)
  expect_gte(specificity, 0)
  expect_lte(specificity, 100)
})

test_that("Full gRNA design pipeline works", {
  sequence <- "GCATGCATGCNGGATATATATNGGCGCGCG"
  results <- design_grnas(
    sequence = sequence,
    crispr_system = "cas9",
    max_mismatches = 3,
    pam_sequence = "NGG",
    min_efficiency = 50
  )
  
  expect_s3_class(results, "data.frame")
  expect_true(all(c("sequence", "efficiency", "specificity", "total_score") %in% 
                  colnames(results)))
})