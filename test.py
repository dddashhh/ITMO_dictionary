from subprocess import PIPE, Popen
from unittest import TestCase


def run_test(input_data, expected_error):
    out, err = Popen(["./main"], stdin=PIPE, stdout=PIPE, stderr=PIPE).communicate(input=input_data.encode())
    if err.decode().strip() != expected_error:
        return False, err, out
    return True, None, None

inputs = ["pu-pu-pu", "seconddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd", "third_word"]
exp_err = ["Well, well, well. There is no such key", "Well, well, well. Your input is incorrect", ""]
errors = []

passed=True
for i in range(len(inputs)):
    result, err, out = run_test(inputs[i], exp_err[i])
    if not result:
        passed = False
        print("Error in test ", i)

if passed:
    print("Hurray! Your code has passed all the tests !!!")