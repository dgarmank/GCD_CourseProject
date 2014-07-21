### Details for `run_analysis.R` processing steps, in order:

STEP 1a: read in measurement names for train and test datasets from file `UCI HAR Dataset\\features.txt`

STEP 1b: remove or replace special characters in measurement names before assigning to column names for any data.frame.  Without this procedure, the special characters are replaced by periods and look “untidy” when the column names are assigned to the data.frames.  The code is copied below.

`features$var_label <- gsub("-","_",features$var_label)`

`features$var_label <- gsub("\\(\\)","",features$var_label)`

`features$var_label <- gsub(",","_",features$var_label)`

`features$var_label <- gsub("angle\\(","angle_",features$var_label)`

`features$var_label <- gsub("ean\\)","ean",features$var_label)`

`features$var_label <- gsub("ravity\\)","ravity",features$var_label)`

STEP 1c: get training data into `train.dat`; no manipulations were performed.

STEP 1d: augment `train.dat` with 3 new columns:

1.	type = TRAIN
2.	subID = integer read from file `UCI HAR Dataset\\train\\subject_train.txt`
3.	actID = integer read from file `UCI HAR Dataset\\train\\y_train.txt`

STEP 4a: label `train.dat` columns with descriptive names from STEP 1b.

STEP 1e: get test data into `test.dat`; no manipulations were performed.

STEP 1f: augment `test.dat` with 3 new columns:

1.	type = TEST
2.	subID = integer read from file `UCI HAR Dataset\\test\\subject_test.txt`
3.	actID = integer read from file `UCI HAR Dataset\\test\\y_test.txt`

STEP 4b: label `test.dat` columns with descriptive names from STEP 1b.

STEP 1g: concatenate `train.dat` with `test.dat` into data.frame `combined` with rbind().

STEP 3a: get activity labels from file `UCI HAR Dataset\\activity_labels.txt` and change actID column to factors representing the activity.

STEP 3b: change type column to factors representing "TRAIN" or "TEST".

STEP 2: identify column names containing substrings "mean" or "std".  Create new data.frame `extracted` with these columns only (plus the 3 columns in STEP 1d/1f).

STEP 5a: create an independent tidy dataset `tidy_dataset` [from `combined`, not `extracted`] that records the average of every measurement per subject and per activity.  180 rows are generated.  Console output status occurs for each row generated.

STEP 5b: create a csv file for `tidy_dataset`.

To read this csv file from R, run the following code snippet:

`getit <- read.csv("tidy_dataset.csv", stringsAsFactors = TRUE)`


### Dataset structure

`> str(tidy_dataset)`

`'data.frame':	180 obs. of  564 variables:`

` $ type                               : <b>Factor</b> w/ 2 levels "TRAIN","TEST": 1 1 1 1 1 1 1 1 1 1 ...`

` $ subID                              : <b>int</b>  1 1 1 1 1 1 3 3 3 3 ...`

` $ actID                              : <b>Factor</b> w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 1 2 3 4 5 6 1 2 3 4 ...`

` $ tBodyAcc_mean_X                    : <b>num</b>  0.277 0.255 0.289 0.261 0.279 ...`

` $ tBodyAcc_mean_Y                    : <b>num</b>  -0.01738 -0.02395 -0.00992 -0.00131 -0.01614 ...`

` $ tBodyAcc_mean_Z  `

