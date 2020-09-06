# module for factorial
def factorial(x):
    product = 1
    for i in range(x):
        product *= i+1
    return product