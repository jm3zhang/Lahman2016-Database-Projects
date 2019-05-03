read me

1. Use the command “mysql -u <uid> -p -h marmoset04.shoshin.uwaterloo.ca
db356_<uid> -B < lab4.sql | tr '\t' ',' > res.csv” and the corresponding database
password to export the datasets(features) from the database to the current directory
in .csv format. (in this case, it is res.csv)
3. Execute the python decision tree with the command "python3 decision_tree.py" in 
the current directory. The Python Decision Tree will output the report for the first 
trial for both gini and entropy and then the accuracy and predictions for the rest 5 
iteration of trials.