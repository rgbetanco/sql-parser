from sklearn.feature_extraction.text import CountVectorizer
import pickle

def vectorizer(statement, folder_name):
    pickle_file = folder_name + "/python_AI/count_vectorizer.pk"

    loaded_vec = CountVectorizer(vocabulary=pickle.load(open(pickle_file, "rb")))
    feature = loaded_vec.transform([statement]).toarray().tolist()

    # print("the value return from python is : ", feature[0])

    return feature[0]

if __name__ == '__main__':
    vectorizer("select users from name;", "./")