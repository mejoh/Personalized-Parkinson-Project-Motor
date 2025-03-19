# mod_97_10.py - functions for performing the ISO 7064 Mod 97, 10 algorithm
#
# Copyright (C) 2010-2017 Arthur de Jong
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 USA

"""The ISO 7064 Mod 97, 10 algorithm.

The Mod 97, 10 algorithm evaluates the whole number as an integer which is
valid if the number modulo 97 is 1. As such it has two check digits.
"""


def _to_base10(number):
    """Prepare the number to its base10 representation."""
    try:
        return ''.join(str(int(x, 36)) for x in number)
    except Exception:
        raise InvalidFormat()


def checksum(number):
    """Calculate the checksum. A valid number should have a checksum of 1."""
    return int(_to_base10(number)) % 97


def validate(number):
    """Check whether the check digit is valid."""
    try:
        valid = checksum(number) == 1
    except Exception:
        return InvalidFormat().message

    if not valid:
        return InvalidChecksum().message

    return None


def is_valid(number):
    """Check whether the check digit is valid."""
    try:
        return bool(validate(number))
    except ValidationError:
        return False


class ValidationError(Exception):
    """Top-level error for validating numbers.

    This exception should normally not be raised, only subclasses of this
    exception."""

    def __str__(self):
        """Return the exception message."""
        return ''.join(self.args[:1]) or getattr(self, 'message', '')


class InvalidFormat(ValidationError):
    """Something is wrong with the format of the number.

    This generally means characters or delimiters that are not allowed are
    part of the number or required parts are missing."""

    message = 'The PEP-number has an invalid format'


class InvalidChecksum(ValidationError):
    """The number's internal checksum or check digit does not match."""

    message = "The PEP-number's checksum or check digit is invalid"
