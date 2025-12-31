# run_analysis.R

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zip_file <- "UCI_HAR_Dataset.zip"
data_dir <- "UCI HAR Dataset"

if (!file.exists(zip_file)) download.file(url, zip_file, mode = "wb")
if (!dir.exists(data_dir)) unzip(zip_file)

features <- read.table(file.path(data_dir, "features.txt"), stringsAsFactors = FALSE)
activity_labels <- read.table(file.path(data_dir, "activity_labels.txt"), stringsAsFactors = FALSE)

x_train <- read.table(file.path(data_dir, "train", "X_train.txt"))
y_train <- read.table(file.path(data_dir, "train", "y_train.txt"))
s_train <- read.table(file.path(data_dir, "train", "subject_train.txt"))

x_test  <- read.table(file.path(data_dir, "test", "X_test.txt"))
y_test  <- read.table(file.path(data_dir, "test", "y_test.txt"))
s_test  <- read.table(file.path(data_dir, "test", "subject_test.txt"))

colnames(x_train) <- features$V2
colnames(x_test)  <- features$V2
colnames(y_train) <- "activity"
colnames(y_test)  <- "activity"
colnames(s_train) <- "subject"
colnames(s_test)  <- "subject"

train <- cbind(s_train, y_train, x_train)
test  <- cbind(s_test,  y_test,  x_test)
all_data <- rbind(train, test)

keep <- grepl("mean\\(\\)|std\\(\\)", names(all_data))
keep[1:2] <- TRUE
all_data <- all_data[, keep]

all_data$activity <- activity_labels$V2[all_data$activity]

names(all_data) <- names(all_data) |>
  gsub("^t", "Time", x = _) |>
  gsub("^f", "Freq", x = _) |>
  gsub("Acc", "Accel", x = _) |>
  gsub("Gyro", "Gyro", x = _) |>
  gsub("Mag", "Mag", x = _) |>
  gsub("BodyBody", "Body", x = _) |>
  gsub("\\(\\)", "", x = _) |>
  gsub("-", "_", x = _)

tidy_avg <- aggregate(. ~ subject + activity, data = all_data, FUN = mean)

write.table(tidy_avg, "tidy_averages.txt", row.names = FALSE)
