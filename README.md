TBD

Empirical study of impact of inter-test dependency on test parallization

Experiment 1 : Follow these steps -

1. Put the collections of projects inside a folder named `projects` and put this folder (`projects`) inside Experiment1/ folder.

2. Run the `./experiment_1.sh` inside Experiment1 folder.

3. If the `projects` folder contains a lot of projects it can be splitted into five batches. Run `./create_batch.sh projects`. This will create five batches in the same directory as the script -- `BATCH-1`, `BATCH-2`, `BATCH-3`, `BATCH-4`, `BATCH-5`. Place the contents of each batch one by one inside the `projects` folder and run the experiment by `./experiment_1.sh`

4. The logs of the experiment will be placed inside `LOG` folder. The summary of the experiment will be appended incrementally in the `SUMMARY.csv` file inside the `LOG` folder. 