
from lib import factorial
import math
import sys
import traceback

try:
    assert factorial(1) == math.factorial(1)
    assert factorial(2) == math.factorial(2)
    assert factorial(5) == math.factorial(5)
    assert factorial(10) == math.factorial(10)
    assert factorial(0) == math.factorial(0)

except AssertionError as e:
    formatted_lines = traceback.format_exc().splitlines()
    sys.stderr.write(f"Test failed\n")
    sys.stderr.write(f"{formatted_lines[-2]}")

