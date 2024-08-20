# this script runs the random forest classifier for one chromosome (test chromosome: 18)

# input: chromosome number (ex: "chr18"), file for saving model stats
args <- commandArgs(trailingOnly=TRUE)
input_chr <- args[1]
print(input_chr)

output_file <- args[2]

# define the data directory
data_dir <- "/data/Phillippy2/projects/belluck_dmr/test_classifier/"

library(dplyr)
library(tidyr)
library(readr)
library(randomForest)
library(caret)

# read in the data
combined_data <- read.table(paste0(data_dir, input_chr, "_combined_data.tsv"), header = TRUE, sep = "\t")

# remove the Sample column from the combined data frame
data <- combined_data[, -1]

labels <- data[, 1]
features <- data[, -1]
labels <- as.factor(labels)

# Create a data frame for the caret package
data_for_caret <- data.frame(features, label = labels)

# Create an index for splitting the data into training and testing sets
train_index <- createDataPartition(data_for_caret$label, p = 0.8, list = FALSE)

# Split data into training and testing sets
train_data <- data_for_caret[train_index, ]
test_data <- data_for_caret[-train_index, ]


# train the model for 5 different random seeds
num_seeds <- 5
seeds <- 1:num_seeds

# Define the grid of mtry values to test
mtry_values <- c(5, 10, 50, 100, 200, 500)

# Initialize lists to store predictions, number of features, and model accuracies
predictions_list <- vector("list", num_seeds)
features_used_list <- vector("list", num_seeds)
accuracies_list <- vector("list", num_seeds)

# Train the random forest model using multiple random seeds and collect predictions and accuracies
for (i in seq_along(seeds)) {
  set.seed(seeds[i])
  print(paste("Training model with seed", seeds[i], "..."))
  
  train_control <- trainControl(method = "cv", number = 5)
  
  # Train the random forest model with tuning of mtry
  rf_model <- train(label ~ ., data = train_data, method = "rf", 
                    trControl = train_control, ntree = 100,
                    tuneGrid = expand.grid(mtry = mtry_values))
  
  # Print model details
  print(rf_model)
  
  # Print number of features used in the model
  features_used <- length(rf_model$finalModel$importance)
  #features_used_list[[i]] <- features_used
  #print(paste("Number of features used:", features_used))

  # Extract feature importance
  importance_df <- rf_model$finalModel$importance
  # Get the importance scores
  importance_scores <- importance_df[, "MeanDecreaseGini"]
  # Count features with nonzero importance
  nonzero_importance_count <- sum(importance_scores > 0)
  # Print the result
  cat("Number of features with nonzero importance:", nonzero_importance_count, "\n")
  features_used_list[[i]] <- nonzero_importance_count

  # Predict on the testing set
  print(paste("Making predictions with seed", seeds[i], "..."))
  data_for_prediction <- test_data %>% select(-label)
  predictions <- predict(rf_model, newdata = data_for_prediction)
  
  # Store predictions
  predictions_list[[i]] <- predictions
  
  # Calculate and store accuracy
  conf_matrix <- confusionMatrix(predictions, test_data$label)
  accuracies_list[[i]] <- conf_matrix$overall['Accuracy']
  print(paste("Accuracy:", conf_matrix$overall['Accuracy']))
}

# Combine predictions from all seeds into a data frame
predictions_df <- as.data.frame(predictions_list)

# Determine the majority vote for each test sample
majority_vote <- function(x) {
  if (length(x) == 0) return(NA)
  tbl <- table(x)
  return(names(tbl)[which.max(tbl)])
}

final_predictions <- apply(predictions_df, 1, majority_vote)

# Create a confusion matrix to evaluate final aggregated predictions
print("Confusion matrix for aggregated predictions")
final_conf_matrix <- confusionMatrix(factor(final_predictions, levels = levels(test_data$label)), test_data$label)
print(final_conf_matrix)

# Calculate and print accuracy for aggregated predictions
print("Calculating accuracy for aggregated predictions...")
final_accuracy <- final_conf_matrix$overall['Accuracy']
cat("Final Accuracy:", final_accuracy, "\n")

# Calculate average number of features across all models
average_features <- mean(unlist(features_used_list))

# Calculate the total number of features in the input file
input_features <- ncol(combined_data) - 2

# Prepare the output line as a single string
output_line <- paste(
  input_chr,
  final_accuracy,
  paste(unlist(accuracies_list), collapse = ","),
  input_features,
  average_features,
  paste(unlist(features_used_list), collapse = ","),
  sep = "\t"
)

# Append to a tab-separated file
cat(output_line, file = output_file, append = TRUE, sep = "\n")

print(paste("Summary appended to", output_file))


