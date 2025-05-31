import numpy as np

def calculate(list):
    if len(list) != 9:
        raise ValueError("List must contain nine numbers.")
    if not all(isinstance(item, (int, float)) for item in list):
        raise ValueError("List must contain only numbers.")
# chuyển về matrix 3x3
    list_1 = np.array(list)
    list_1 = list_1.reshape(3,3)
#axis = 0
    mean_1 = np.mean(list_1, axis=0)
    variance_1 = np.var(list_1, axis=0)
    standard_deviation_1 = np.std(list_1, axis=0)
    max_1 = np.max(list_1, axis=0)
    min_1 = np.min(list_1, axis=0)
    sum_1 = np.sum(list_1, axis=0)
#axis = 1
    mean_2 = np.mean(list_1, axis=1)
    variance_2 = np.var(list_1, axis=1)
    standard_deviation_2 = np.std(list_1, axis=1)
    max_2 = np.max(list_1, axis=1)
    min_2 = np.min(list_1, axis=1)
    sum_2 = np.sum(list_1, axis=1)
#flattend
    mean_3 = np.mean(list)
    variance_3 = np.var(list)
    standard_deviation_3 = np.std(list)
    max_3 = np.max(list)
    min_3 = np.min(list)
    sum_3 = np.sum(list)
    mean_var_std = {
        'mean': [mean_1, mean_2, mean_3],
        'variance': [variance_1, variance_2, variance_3],
        'standard deviation': [standard_deviation_1, standard_deviation_2, standard_deviation_3],
        'max': [max_1, max_2, max_3],
        'min': [min_1, min_2, min_3],
        'sum': [sum_1, sum_2, sum_3]
    }

    return mean_var_std

print(calculate([0,1,2,3,4,5,6,7,8]))