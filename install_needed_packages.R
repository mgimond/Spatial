# Installs packages needed to build this Quarto document

# Find all QMD files in the project
qmd_files <- list.files(
  path = ".",
  pattern = "\\.qmd$",
  recursive = TRUE,
  full.names = TRUE
)

if (length(qmd_files) == 0) {
  stop("No .qmd files found.")
}

cat("Found", length(qmd_files), "QMD files\n")

# Read all files into a single character vector
contents <- unlist(lapply(qmd_files, readLines, warn = FALSE))

# Extract package names from library(), require(), requireNamespace()
pkg_patterns <- c(
  "(?<=library\\()[A-Za-z0-9._]+",
  "(?<=require\\()[A-Za-z0-9._]+",
  "(?<=requireNamespace\\()[\"']?[A-Za-z0-9._]+"
)

pkgs <- character()

for (pat in pkg_patterns) {
  matches <- regmatches(
    contents,
    gregexpr(pat, contents, perl = TRUE)
  )
  pkgs <- c(pkgs, unlist(matches))
}

# Extract package names from pkg::fun and pkg:::fun
namespace_matches <- regmatches(
  contents,
  gregexpr("[A-Za-z][A-Za-z0-9._]*(?=:::?)",
           contents,
           perl = TRUE)
)

pkgs <- c(pkgs, unlist(namespace_matches))

# Clean package names
pkgs <- gsub("['\"]", "", pkgs)
pkgs <- unique(pkgs[nzchar(pkgs)])

# Remove common false positives if needed
pkgs <- sort(pkgs)

cat("\nPackages detected:\n")
print(pkgs)

# Determine which are missing
installed <- rownames(installed.packages())
missing_pkgs <- setdiff(pkgs, installed)

cat("\nMissing packages:\n")
print(missing_pkgs)

# Install missing packages
if (length(missing_pkgs) > 0) {
  install.packages(missing_pkgs, dependencies = TRUE)
} else {
  cat("\nAll detected packages are already installed.\n")
}

# Optional: check for Quarto-related packages commonly needed
recommended <- c(
  "quarto",
  "knitr",
  "rmarkdown",
  "bookdown"
)

missing_recommended <- setdiff(recommended, rownames(installed.packages()))

if (length(missing_recommended) > 0) {
  cat("\nInstalling recommended Quarto packages:\n")
  print(missing_recommended)
  install.packages(missing_recommended, dependencies = TRUE)
}

cat("\nDependency scan complete.\n")