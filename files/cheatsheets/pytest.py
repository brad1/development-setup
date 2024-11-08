# Basic Test Function
def test_addition():
    assert 1 + 1 == 2                           # Simple assertion

# Running Tests
# Run all tests in the current directory:
# > pytest

# Test Class
class TestMath:
    def test_subtraction(self):
        assert 5 - 3 == 2                       # Class-based test

# Using Fixtures
import pytest

@pytest.fixture
def sample_data():
    return [1, 2, 3]                            # Sample fixture

def test_sum(sample_data):
    assert sum(sample_data) == 6                # Use fixture in test

# Parametrizing Tests
@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 3),
    (3, 4)
])
def test_increment(input, expected):
    assert input + 1 == expected                 # Parametrized test

# Testing Exceptions
def test_zero_division():
    with pytest.raises(ZeroDivisionError):      # Expect exception
        x = 1 / 0

# Running Specific Tests
# Run a specific test file:
# > pytest test_file.py

# Marking Tests
@pytest.mark.slow
def test_sleep():
    import time
    time.sleep(1)                               # Mark slow test

# Skipping Tests
@pytest.mark.skip(reason="not implemented yet")
def test_feature():
    pass                                         # Skipped test

# Running Tests with Coverage
# Install pytest-cov and run:
# > pytest --cov=my_module

# Checking Output
def test_output(capfd):                        # Capture output
    print("Hello, World!")
    captured = capfd.readouterr()              # Read captured output
    assert captured.out == "Hello, World!\n"   # Check output
