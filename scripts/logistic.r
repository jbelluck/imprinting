# Load necessary library
library(dplyr)
library(tidyr)
library(readr)

# input: chromosome number (ex: "chr18"), file for saving model stats
args <- commandArgs(trailingOnly=TRUE)
input_chr <- args[1]
print(input_chr)

output_file <- args[2]

# define the data directory
data_dir <- "/data/Phillippy2/projects/belluck_dmr/test_classifier/"

print("Reading in data...")
# read in the data
combined_data <- read.table(paste0(data_dir, input_chr, "_combined_data.tsv"), header = TRUE, sep = "\t")

# Extract the first 7 characters of the sample names
data <- combined_data %>% mutate(Sample = substr(Sample, 1, 7))

# Verify the changes
write_tsv(data, "datatest.tsv")

print("Identifying samples...")
# Identify the unique samples based on the shortened names
samples <- unique(data$Sample)

# Shuffle the samples to ensure randomness
set.seed(42)  # For reproducibility
samples <- sample(samples)

print("Splitting into training and testing...")
# Split the samples into training and testing sets
train_samples <- samples[1:floor(0.8 * length(samples))]
test_samples <- samples[(floor(0.8 * length(samples)) + 1):length(samples)]

# Filter the data for training and testing sets
train_data <- data %>% filter(Sample %in% train_samples)
test_data <- data %>% filter(Sample %in% test_samples)

write_tsv(train_data, "trainwithsamples.tsv")
write_tsv(test_data, "testwithsamples.tsv")

# Remove the original Sample_Name and Sample_Name_Short columns for modeling
train_data <- train_data %>% select(-Sample)
test_data <- test_data %>% select(-Sample)

write_tsv(test_data, "test_data.tsv")
write_tsv(train_data, "train_data.tsv")

# Load necessary library
library(caret)

print("Training model...")
# Train a logistic regression model
model <- train(Label ~ ., data = train_data, method = "glm", family = "binomial")

# Print the model summary
print(model)

print("Making predictions...")
# Make predictions on the test set
predictions <- predict(model, newdata = test_data)

print("Calculating confusion matrix...")
# Calculate performance metrics
confusionMatrix(predictions, test_data$Label)
