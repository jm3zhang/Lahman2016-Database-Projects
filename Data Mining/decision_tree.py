import pandas
import numpy
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score,classification_report,f1_score
from sklearn.externals.six import StringIO 
from sklearn.tree import export_graphviz
import pydot
import csv

def import_csv(path):
    data = pandas.read_csv(path, sep=',', header = 0).fillna(0)
    # print("Dataset: ",data.head())
    return data

file_path = 'res.csv'
data = import_csv(file_path)

def split_train_test_set(data):
    matrix = data.values[:, 1:len(data.columns) - 1].astype('int')
    target = data.values[:, len(data.columns) - 1].astype('int')
    return train_test_split(matrix, target, test_size = 0.2)

def modeling_with_gini():
    return DecisionTreeClassifier(criterion="gini")

def modeling_with_entropy():
    return DecisionTreeClassifier(criterion="entropy")

def write_csv(data, name):
    # group 3
    output = []
    output.append(("Dataset number", "Accuracy"))  
    # print(len(data[1][1]))
    for i in range(5):
        # for i in len(data[i][1]):
        output.append((i, data[i][0]))  

    with open("g3_DT_" + name + "_accuracy.csv", "w") as f:
        writer = csv.writer(f)
        writer.writerows(output)

    output = []
    output.append(("Iteration", "Classification", 'Predictions'))  

    for a in range(5):
        for b in range(len(data[a][1])):
            output.append((a, data[a][1][b], data[a][2][b]))  

    with open("g3_DT_" + name + "_Predictions.csv", "w") as f:
        writer = csv.writer(f)
        writer.writerows(output)    

    return

def draw_decision_tree(model, name):
    dot_data = StringIO()
    export_graphviz(
        model, 
        out_file=dot_data, 
        filled= True, 
        rounded=True,  
        special_characters=True,
        feature_names=data.columns[1:-1],
        class_names=["Yes","No"])
    graph = pydot.graph_from_dot_data(dot_data.getvalue())  
    graph[0].write_png(name)
    return

def main():
    result_gini = []
    
    # gini modeling first 
    # create gini model 
    X_train, X_test, Y_train, Y_test = split_train_test_set(data)
    classifier_gini = modeling_with_gini() 
    classifier_gini.fit(X_train, Y_train)

    # feature_selected = []
    # feature_selection = pandas.Series(classifier_gini.feature_importances_).sort_values()
    # print("FeatureID Weight")
    # for feature_index, importance in feature_selection.iteritems():
    #     print(data.columns[1:-1][feature_index], importance)
    #     if importance > 0:
    #         feature_selected.append(data.columns[1:-1][feature_index])

    # print("feature_selected", feature_selected)

    # plot the decision tree
    draw_decision_tree(classifier_gini, "Gini_Decision_tree.png")

    # test the gini model using the X_test to see the threshold of this model
    print("First tiral's dataset for gini: ")
    Y_predict = classifier_gini.predict(X_test)
    accuracy = accuracy_score(Y_test, Y_predict)

    print("Accuracy of the first gini trial dataset is ", accuracy)
    print("f1-score: of the first gini trial dataset is ", f1_score(Y_test, Y_predict))
    for i in range(5):
        print("Gini iterations:", i)
        _, X_test, _, Y_test = split_train_test_set(data)
        Y_predict = classifier_gini.predict(X_test)
        print("f1-score: ", f1_score(Y_test, Y_predict))
        accuracy = accuracy_score(Y_test, Y_predict)
        print("Accuracy: ", accuracy)
        # push accuracy and prediction into the result
        result_gini.append((accuracy, Y_test, Y_predict))

    write_csv(result_gini, 'gini')

    result_entropy = []

    # entropy modeling 
    # create entropy model 
    X_train, X_test, Y_train, Y_test = split_train_test_set(data)
    classifier_entropy = modeling_with_entropy() 
    classifier_entropy.fit(X_train, Y_train)

    # plot the decision tree
    draw_decision_tree(classifier_entropy, "Entropy_Decision_tree.png")

    # test the entropy model using the X_test to see the threshold of this model
    print("First tiral's dataset for entropy: ")
    Y_predict = classifier_entropy.predict(X_test)
    accuracy = accuracy_score(Y_test, Y_predict)

    print("Accuracy of the first trial entropy dataset is ", accuracy)
    print("f1-score: of the first entropy trial dataset is ", f1_score(Y_test, Y_predict))
    for i in range(5):
        print("Entropy iterations:", i)
        _, X_test, _, Y_test = split_train_test_set(data)
        Y_predict = classifier_entropy.predict(X_test)
        print("f1-score: ", f1_score(Y_test, Y_predict))
        accuracy = accuracy_score(Y_test, Y_predict)
        print("Accuracy: ", accuracy)
        # push accuracy and prediction into the result
        result_entropy.append((accuracy, Y_test, Y_predict))

    write_csv(result_entropy, 'entropy')


    # feature_selected = []
    # feature_selection = pandas.Series(classifier_gini.feature_importances_).sort_values()
    # print("FeatureID Weight")
    # for feature_index, importance in feature_selection.iteritems():
    #     print(data.columns[1:-1][feature_index], importance)
    #     if importance > 0:
    #         feature_selected.append(data.columns[1:-1][feature_index])

    # print("feature_selected", feature_selected)


if __name__=="__main__": 
    main() 


# mysql -u root  lahman2016 -B < ~/Desktop/lab4.sql | tr '\t' ',' > lab4_data.csv