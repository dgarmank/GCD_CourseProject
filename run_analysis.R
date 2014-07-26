# DataScience - GettingCleaningData
# CourseProject

# don't use read.fwf on "large" datasets!
# Early in this assignment, I was unable to read the large datasets using
# read.fwf due to astronomical memory utilization, and developed an
# alternative method that reads the complete file as a character string and
# parses it into a matrix of numerics.  I have since replaced reading the
# large datasets (only) with read.table(), but still not the smaller ones
# due to time constraints.
faster <- 1     # set 0 for slower, original file input for large datasets
agg    <- 1     # set 0 for slower, original calculation of the means
TRAIN  <- 1     # constant
TEST   <- 2     # constant

# STEP 1a: read in measurement names for train and test datasets
features <- read.csv("UCI HAR Dataset\\features.txt",
                    sep = " ",
                    header = FALSE,
                    col.names = c("varID","var_label"),
                    colClasses = c("integer","character"),
                    stringsAsFactors = FALSE)

# STEP 1b: measurement names contain special characters that
# are not allowed in column variable names for dataframes.
# Hyphens, single and consecutive parentheses, commas, will be replaced
# or deleted as follows.  Furthermore, the names are left as-is otherwise.
# There is no demotion to all lowercase for this project because it makes
# the interpretation more difficult.
features$var_label <- gsub("-","_",features$var_label)              # replace
features$var_label <- gsub("\\(\\)","",features$var_label)          # remove
features$var_label <- gsub(",","_",features$var_label)              # replace
features$var_label <- gsub("angle\\(","angle_",features$var_label)  # replace 
features$var_label <- gsub("ean\\)","ean",features$var_label)       # remove
features$var_label <- gsub("ravity\\)","ravity",features$var_label) # remove

# STEP 1c: get training data
system.time(
if(faster != 0)
    train.dat <- read.table("UCI HAR Dataset\\train\\X_train.txt",
                    header = FALSE,
                    sep = "",
                    stringsAsFactors = FALSE,
                    colClasses = "numeric")
else {
    # read entire file, split by spaces, convert to vector
    # first line below uses more memory than I would like :(
    train.dat <- unlist(strsplit(readLines("UCI HAR Dataset\\train\\X_train.txt"), " "))
    train.dat <- as.numeric(train.dat[train.dat != ""])    # remove "" elements, cvt to numeric
    train.dat <- as.data.frame(matrix(train.dat,ncol=561,byrow=TRUE)) # a data.frame
    }
)
object.size(train.dat)  # watch the size

# STEP 1d: construct 3 vectors: TRAIN/TEST, subjectID, subject activity
# label the subjects in the training data as TRAIN(1) or TEST(2)
train.type <- c(rep(TRAIN,nrow(train.dat)))

# read entire file, split by spaces, convert to vector
train.ID <- unlist(strsplit(readLines("UCI HAR Dataset\\train\\subject_train.txt"), " "))
train.ID <- as.integer(train.ID[train.ID != ""])    # remove "" elements, cvt to integer

# read entire file, split by spaces, convert to vector
train.act <- unlist(strsplit(readLines("UCI HAR Dataset\\train\\y_train.txt"), " "))
train.act <- as.integer(train.act[train.act != ""])    # remove "" elements, cvt to integer

# STEP 4a: label the training variables with descriptive names
colnames(train.dat) <- features$var_label

# join the subjectID with activityID and the data
train.dat <- data.frame(type  = train.type,
                        subID = train.ID,
                        actID = train.act,
                        train.dat)
# remember subjects in training data
training_subjects <- unique(train.dat$subID)

# STEP 1e: get test data
system.time(
if(faster != 0)
    test.dat <- read.table("UCI HAR Dataset\\test\\X_test.txt",
                        header = FALSE,
                        sep = "",
                        stringsAsFactors = FALSE,
                        colClasses = "numeric")
else {
    # read entire file, split by spaces, convert to vector
    # first line below uses more memory than I would like :(
    test.dat <- unlist(strsplit(readLines("UCI HAR Dataset\\test\\X_test.txt"), " "))
    test.dat <- as.numeric(test.dat[test.dat != ""])    # remove "" elements, cvt to numeric
    test.dat <- as.data.frame(matrix(test.dat,ncol=561,byrow=TRUE)) # a data.frame
    }
)
object.size(test.dat)  # watch the size

# STEP 1f: construct 3 vectors: TRAIN/TEST, subjectID, subject activity
# label the subjects in the training data as TRAIN(1) or TEST(2)
test.type <- c(rep(TEST,nrow(test.dat)))

# read entire file, split by spaces, convert to vector
test.ID <- unlist(strsplit(readLines("UCI HAR Dataset\\test\\subject_test.txt"), " "))
test.ID <- as.integer(test.ID[test.ID != ""])    # remove "" elements, cvt to integer

# read entire file, split by spaces, convert to vector
test.act <- unlist(strsplit(readLines("UCI HAR Dataset\\test\\y_test.txt"), " "))
test.act <- as.integer(test.act[test.act != ""])    # remove "" elements, cvt to integer

# STEP 4b: label the test variables with descriptive names
colnames(test.dat) <- features$var_label

# join the subjectID with activityID and the data
test.dat <- data.frame(type  = test.type,
                       subID = test.ID,
                       actID = test.act,
                       test.dat)
# remember subjects in training data
test_subjects <- unique(test.dat$subID)

# STEP 1g: concatenate test data to train data
combined <- rbind(train.dat,test.dat)
object.size(combined)  # watch the size

rm(train.dat)   # no longer needed
rm(test.dat)    # no longer needed

# STEP 3a: change actID column to factors representing the activity
activities <- read.csv("UCI HAR Dataset\\activity_labels.txt",
                        sep = " ",
                        header = FALSE,
                        col.names = c("actID","type"),
                        colClasses = c("integer","character"),
                        stringsAsFactors = FALSE)
combined$actID <- factor(combined$actID, labels = activities$type)

# STEP 3b: change type column to factors representing "TRAIN" or "TEST"
combined$type <- factor(combined$type, labels = c("TRAIN","TEST"))

# STEP 2: identify column names containing "mean" or "std", for retention
extract_cols <- grep("mean",colnames(combined))
extract_cols <- c(1,2,3,extract_cols,grep("std",colnames(combined)))
extract_cols <- sort(extract_cols)
length(extract_cols)
extracted <- combined[,extract_cols]
object.size(extracted)  # watch the size

# STEP 5a: create an independent tidy dataset [from the combined dataset]
# that records the average of every measurement per subject and per activity
system.time(
if(agg == 1)    # much faster
    tidy_dataset <- aggregate(. ~ actID+subID, data=combined, mean)
else {
    single_row <- data.frame(combined[1,])  # init with all columns
    tidy_dataset <- data.frame()            # build this up
    # subjects*activities = 30*6 = 180 rows, each with 3+561 columns
    totrows <- length(unique(combined$subID)) * nrow(activities)
    row <- 0
    for (subj in unique(combined$subID)) {
        for (activity in sort(unique(as.integer(combined$actID)))) {
            single_row$type <- TRAIN    # assume TRAIN, then override
            if(subj %in% test_subjects) single_row$type <- TEST    # TEST
            single_row$subID <- subj
            single_row$actID <- activity
            qrows <- which(combined$subID == subj & 
                as.integer(combined$actID) == activities$actID[activity])
            for (measure in c(4:ncol(combined))) {
                single_row[1,measure] <- mean(combined[qrows,measure])
            }
            tidy_dataset <- rbind(tidy_dataset,single_row)
            row <- row + 1
            cat("row:", row," of", totrows, "  subj: ", subj, "-",
                c("TRAIN","TEST")[single_row$type],
                "  activity: ", activities$type[activity], "\n")
        }
    }
    tidy_dataset$actID <- factor(tidy_dataset$actID, labels = activities$type)
}
)
tidy_dataset$type <- factor(tidy_dataset$type, labels = c("TRAIN","TEST"))

# STEP 5b: create a csv file for tidy_dataset
write.csv(tidy_dataset, "tidy_dataset.csv", row.names = FALSE)

# now read it back
getit <- read.csv("tidy_dataset.csv", stringsAsFactors = TRUE)

# show object memory usage
object.size(combined)
object.size(extracted)
object.size(tidy_dataset)
object.size(getit)

#sort( sapply(ls(),function(x){object.size(get(x))}))
#memory.size()
#memory.profile()
