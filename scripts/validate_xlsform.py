"""Convert and validate the XLSForm with pyxform.

The generated XML is written to a temporary directory and is not committed.
This check covers structural conversion. It does not replace preview and logic
testing in KoboToolbox.
"""

from __future__ import annotations

import tempfile
from pathlib import Path

from pyxform.xls2xform import xls2xform_convert

ROOT = Path(__file__).resolve().parents[1]
XLSFORM = ROOT / "survey" / "impact_survey_xlsform.xlsx"


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="impact_xlsform_") as temp_dir:
        xml_path = Path(temp_dir) / "impact_survey_synthetic.xml"
        warnings = xls2xform_convert(
            str(XLSFORM),
            str(xml_path),
            validate=True,
            pretty_print=True,
        )
        if not xml_path.exists() or xml_path.stat().st_size == 0:
            raise RuntimeError("pyxform did not produce a non-empty XML form")
        print(f"pyxform structural validation passed: {XLSFORM}")
        if warnings:
            print("Warnings:")
            for warning in warnings:
                print(f"- {warning}")


if __name__ == "__main__":
    main()
