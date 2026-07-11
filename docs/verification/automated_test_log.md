# Automated verification log

All data referenced below is synthetic.

## 10 July 2026 — Initial build verification

Environment observed:

- Windows PowerShell 7.5.8
- Python 3.11.8
- pandas 2.2.2
- NumPy 2.3.1
- openpyxl 3.1.5 in the project virtual environment
- pytest 8.3.5
- pyxform 4.5.0

Commands run from the repository root:

```powershell
.\.venv\Scripts\python.exe scripts\build_xlsform.py
.\.venv\Scripts\python.exe -m pytest
.\.venv\Scripts\python.exe scripts\validate_xlsform.py
```

Observed results:

- XLSForm builder exited with code 0.
- Python tests: `8 passed in 12.69s`.
- pyxform conversion and structural validation exited with code 0.
- pyxform reported no warnings.
- Generated response count: 420.
- Raw CSV SHA-256:
  `f257d16f6138358401bcdf8c653bdd3ac491f1f71537d9d4c26ff0b00ef34373`.

Injected issue records recorded by the generator:

| Issue type | Manifest count |
|---|---:|
| Missing required | 8 |
| Invalid code | 6 |
| Inconsistent date | 6 |
| Out of range | 6 |
| Skip-logic violation | 8 |
| Region/site consistency violation | 4 |
| Duplicate response identifier | 10 |

The byte-reproducibility test generated the dataset twice in separate temporary
directories and compared the resulting CSV bytes. It passed. These injection
counts describe deliberate data generation, not the separate R detection
results recorded in `r_test_log.md`.

## 10 July 2026 — Reproducibility regression check

The XLSForm builder was updated to normalize Excel archive metadata and to build
test workbooks outside the repository. Two consecutive builds produced the same
SHA-256:

```text
fc928a45b1d2ca1a1fb55e664efe84fd880e84509db3bee3963849c654be9f4c
```

The expanded Python suite then passed all nine tests, and pyxform 4.5.0 again
completed structural validation with no reported warnings.

## 11 July 2026 — Publication regression check

The XLSForm and Excel template were rebuilt after a wording review. The final
Python suite passed all 18 tests, and pyxform structural validation completed
without warnings. The current XLSForm SHA-256 is:

```text
71d8bb48d584a7ba369ca559d627f3a48548bd83432e1bb784a7859fe71d8782
```

The same XLSForm was then rechecked in KoboToolbox Preview; results are recorded
in `kobo_test_log.md`.
