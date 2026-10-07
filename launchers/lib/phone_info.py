# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
"""Offline analysis of a phone number with Google's libphonenumber.

Usage: phone_info.py NUMBER OUTPUT.json
Prints a short report and writes every field to OUTPUT.json. No network access.
"""

import json
import sys

import phonenumbers
from phonenumbers import carrier, geocoder, timezone
from phonenumbers.phonenumberutil import NumberParseException, number_type

TYPES = {getattr(phonenumbers.PhoneNumberType, n): n.replace("_", " ").lower()
         for n in dir(phonenumbers.PhoneNumberType) if n.isupper()}


def analyse(raw):
    try:
        n = phonenumbers.parse(raw, None)
    except NumberParseException as e:
        return {"input": raw, "error": f"cannot parse: {e} (use the international format, e.g. +39 06 1234567)"}
    fmt = phonenumbers.PhoneNumberFormat
    return {
        "input": raw,
        "valid": phonenumbers.is_valid_number(n),
        "possible": phonenumbers.is_possible_number(n),
        "e164": phonenumbers.format_number(n, fmt.E164),
        "international": phonenumbers.format_number(n, fmt.INTERNATIONAL),
        "national": phonenumbers.format_number(n, fmt.NATIONAL),
        "country_code": n.country_code,
        "region": phonenumbers.region_code_for_number(n),
        "location": geocoder.description_for_number(n, "en"),
        "original_carrier": carrier.name_for_number(n, "en"),
        "line_type": TYPES.get(number_type(n), "unknown"),
        "time_zones": list(timezone.time_zones_for_number(n)),
        "note": "Carrier is the operator the number range was assigned to; "
                "the number may have been ported since.",
    }


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    result = analyse(sys.argv[1])
    with open(sys.argv[2], "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    for key, value in result.items():
        print(f"{key:17} {value}")
    return 1 if "error" in result else 0


if __name__ == "__main__":
    sys.exit(main())
