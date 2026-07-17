"""Unit tests for good_example.py — gives the 'good' commit real coverage."""

import pytest

from tests.quality_samples.good_example import (
    average,
    celsius_to_fahrenheit,
    safe_divide,
)


def test_celsius_to_fahrenheit_freezing():
    assert celsius_to_fahrenheit(0) == 32


def test_celsius_to_fahrenheit_boiling():
    assert celsius_to_fahrenheit(100) == 212


def test_average_typical():
    assert average([1, 2, 3, 4]) == 2.5


def test_average_empty_raises():
    with pytest.raises(ValueError):
        average([])


def test_safe_divide_normal():
    assert safe_divide(10, 2) == 5


def test_safe_divide_by_zero_returns_none():
    assert safe_divide(10, 0) is None
