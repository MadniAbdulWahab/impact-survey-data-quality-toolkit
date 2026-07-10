# Data-flow and control points

All records shown in this flow are synthetic. Raw data is immutable; interim
data is disposable; processed data is reproducible and analysis-ready.

```mermaid
flowchart LR
    A[XLSForm source CSVs] --> B[Kobo-ready XLSForm]
    B -. manual preview and logic test .-> C[KoboToolbox test project]
    D[Fixed-seed Python generator] --> E[(Raw synthetic CSV)]
    D --> F[Injected-issue truth manifest]
    E --> G[R import and type parsing]
    G --> H[(Interim typed data)]
    H --> I[Validation and cleaning rules]
    F --> J[Automated rule tests]
    I --> J
    I --> K[(Processed CSV and SQLite)]
    I --> L[Record-level QC report]
    K --> M[Quarto HTML report]
    E --> N[Excel Power Query]
    N --> O[Excel QC flags, pivots, summary]
    O -. manual macro test .-> P[Excel QC export]
```

## Control points

1. The generator fixes the random seed, dates, row count, and output order.
2. Raw files are checksummed and never edited by R or Excel.
3. The truth manifest is used for tests, not as an input to analytical results.
4. R validation produces record-level flags before exclusion or correction.
5. Excel independently exposes operational QC views from the raw extract.
6. Kobo, R/Quarto, and Excel receive separate verification logs; passing one
   checkpoint does not imply that another component works.

