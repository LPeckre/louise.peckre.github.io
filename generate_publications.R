## ============================================================
##  generate_publications.R
##  Generates publications.json for your academic website.
##
##  Sources supported (use whichever fits your workflow):
##    A. Manual list in this script         → always works
##    B. BibTeX file (.bib)                 → needs {bib2df} or {RefManageR}
##    C. Google Scholar (automatic scrape)  → needs {scholar}
##    D. ORCID API                          → needs {rorcid}
##
##  Run this script, then copy publications.json next to index.html
## ============================================================

# ── 0. Install/load required packages ────────────────────────────
pkgs <- c("jsonlite", "dplyr", "stringr")
# Uncomment the source(s) you want:
# pkgs <- c(pkgs, "bib2df")       # for BibTeX
# pkgs <- c(pkgs, "scholar")      # for Google Scholar
# pkgs <- c(pkgs, "rorcid")       # for ORCID

installed <- rownames(installed.packages())
for (p in pkgs) if (!p %in% installed) install.packages(p)
invisible(lapply(pkgs, library, character.only = TRUE))


# ╔══════════════════════════════════════════════════════════════╗
# ║  SOURCE A — Manual list (always available, edit freely)     ║
# ╚══════════════════════════════════════════════════════════════╝

pubs_manual <- list(
  list(
    title   = "Doubly Robust Estimation under High-Dimensional Confounding",
    authors = "Doe, J., Martin, A., & Leblanc, C.",
    year    = 2024L,
    venue   = "Annals of Statistics, 52(3), 1124–1158",
    type    = "Journal",
    doi     = "10.1214/24-AOS2401",   # replace with real DOI
    preprint= "https://arxiv.org/abs/2401.00001",
    code    = "https://github.com/janedoe/drml",
    keywords= c("causal inference", "high-dimensional", "semiparametric")
  ),
  list(
    title   = "Survival Analysis with Latent Heterogeneity",
    authors = "Doe, J. & Nguyen, T.",
    year    = 2023L,
    venue   = "Journal of the Royal Statistical Society (B), 85(2), 412–436",
    type    = "Journal",
    doi     = "10.1111/rssb.12500",
    preprint= "https://arxiv.org/abs/2301.00002",
    keywords= c("survival analysis", "latent variables", "EM algorithm")
  ),
  list(
    title   = "Fast Inference for Causal Effects in Randomised Trials",
    authors = "Doe, J., Petit, R., & Garcia, M.",
    year    = 2023L,
    venue   = "NeurIPS 2023",
    type    = "Conference",
    preprint= "https://arxiv.org/abs/2306.00003",
    code    = "https://github.com/janedoe/fast-rct",
    keywords= c("randomised trials", "efficiency", "machine learning")
  ),
  list(
    title   = "Nonparametric Testing for Treatment Effect Heterogeneity",
    authors = "Doe, J.",
    year    = 2022L,
    venue   = "Electronic Journal of Statistics, 16(1), 230–275",
    type    = "Journal",
    doi     = "10.1214/22-EJS2000",
    keywords= c("heterogeneous treatment effects", "hypothesis testing")
  ),
  list(
    title   = "Scalable Causal Discovery via Sparse Regularisation",
    authors = "Doe, J. & Chen, L.",
    year    = 2024L,
    venue   = "arXiv preprint",
    type    = "Preprint",
    preprint= "https://arxiv.org/abs/2404.00004",
    keywords= c("causal discovery", "LASSO", "DAGs")
  )
)


# ╔══════════════════════════════════════════════════════════════╗
# ║  SOURCE B — BibTeX file                                     ║
# ╚══════════════════════════════════════════════════════════════╝
# Uncomment and set the path to your .bib file.

# library(bib2df)
# bib_path <- "myrefs.bib"   # <-- change this
#
# pubs_bib <- bib2df(bib_path) |>
#   mutate(
#     title    = TITLE,
#     authors  = map_chr(AUTHOR, ~ paste(.x, collapse = ", ")),
#     year     = as.integer(YEAR),
#     venue    = coalesce(JOURNAL, BOOKTITLE, PUBLISHER, NA_character_),
#     type     = case_when(
#       CATEGORY == "ARTICLE"        ~ "Journal",
#       CATEGORY == "INPROCEEDINGS"  ~ "Conference",
#       CATEGORY == "MISC"           ~ "Preprint",
#       TRUE                         ~ CATEGORY
#     ),
#     doi      = DOI,
#     preprint = URL,
#     keywords = map(KEYWORDS, ~ str_split(.x, "[,;]\\s*")[[1]])
#   ) |>
#   select(title, authors, year, venue, type, doi, preprint, keywords) |>
#   purrr::transpose()


# ╔══════════════════════════════════════════════════════════════╗
# ║  SOURCE C — Google Scholar (automatic)                      ║
# ╚══════════════════════════════════════════════════════════════╝
# Replace YOUR_SCHOLAR_ID with your Google Scholar user ID.
# Find it in your Scholar profile URL: ?user=XXXXXXXX

# library(scholar)
# scholar_id <- "XXXXXXXX"   # <-- change this
#
# pubs_scholar <- get_publications(scholar_id) |>
#   mutate(
#     title    = title,
#     authors  = author,
#     year     = as.integer(year),
#     venue    = journal,
#     type     = "Journal",
#     doi      = NA_character_,
#     preprint = NA_character_,
#     keywords = list(character(0))
#   ) |>
#   select(title, authors, year, venue, type, doi, preprint, keywords) |>
#   purrr::transpose()


# ╔══════════════════════════════════════════════════════════════╗
# ║  SOURCE D — ORCID API                                       ║
# ╚══════════════════════════════════════════════════════════════╝
# Set your ORCID and, if needed, an access token in your .Renviron:
#   ORCID_TOKEN=your_token

# library(rorcid)
# orcid_id <- "0000-0000-0000-0000"   # <-- change this
#
# works_raw <- works(orcid(orcid_id))[[1]]$works
# pubs_orcid <- works_raw |>
#   mutate(
#     title    = map_chr(`work-summary`, ~ .x$title$title$value %||% NA_character_),
#     year     = map_int(`work-summary`,
#                  ~ as.integer(.x$`publication-date`$year$value %||% NA)),
#     venue    = map_chr(`work-summary`,
#                  ~ .x$`journal-title`$value %||% NA_character_),
#     type     = map_chr(`work-summary`,
#                  ~ .x$type %||% "Other"),
#     doi      = map_chr(`work-summary`, ~ {
#                  ids <- .x$`external-ids`$`external-id`
#                  doi_row <- Filter(function(i) i$`external-id-type` == "doi", ids)
#                  if (length(doi_row)) doi_row[[1]]$`external-id-value` else NA_character_
#                }),
#     authors  = NA_character_,
#     preprint = NA_character_,
#     keywords = list(character(0))
#   ) |>
#   select(title, authors, year, venue, type, doi, preprint, keywords) |>
#   purrr::transpose()


# ── Combine all sources ───────────────────────────────────────────
all_pubs <- c(
  pubs_manual
  # , pubs_bib
  # , pubs_scholar
  # , pubs_orcid
)

# ── Deduplicate by title ──────────────────────────────────────────
titles_seen <- character(0)
all_pubs_dedup <- Filter(function(p) {
  key <- str_to_lower(str_squish(p$title))
  if (key %in% titles_seen) return(FALSE)
  titles_seen <<- c(titles_seen, key)
  TRUE
}, all_pubs)

# ── Sort by year (descending) ─────────────────────────────────────
all_pubs_sorted <- all_pubs_dedup[order(
  sapply(all_pubs_dedup, function(p) -(p$year %||% 0L))
)]

# ── Write JSON ────────────────────────────────────────────────────
out_path <- "publications.json"   # place next to index.html

jsonlite::write_json(
  all_pubs_sorted,
  path       = out_path,
  auto_unbox = TRUE,   # scalars as JSON scalars, not arrays
  pretty     = TRUE,
  null       = "null"
)

message("✓ Wrote ", length(all_pubs_sorted), " publications to: ", out_path)
message("  Copy ", out_path, " to your website folder.")
