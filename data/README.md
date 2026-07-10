# Data folders

**All data in this repository is synthetic and represents no real person,
household, programme, or organisation.**

- `raw/` contains immutable generator outputs. Downstream scripts read but do
  not edit these files.
- `interim/` contains disposable working data and is ignored by Git except for
  its explanatory README.
- `processed/` will contain validated, analysis-ready extracts and QC outputs
  produced by the R pipeline.
- `data_dictionary.csv` defines variables, valid values, and conditional
  requirements.

Regenerate raw data from the repository root with:

```powershell
python scripts/generate_synthetic_data.py
```

