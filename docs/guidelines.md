# Analysis Guidelines

How the analytic method applies to a case run on Argos. The method itself (analytic standards, OSINT methodology, analytic techniques, estimative language, source evaluation and report writing) is kept in one place for all the SOsintOps tools, the [Intelligence Field Notes](https://github.com/SOsintOps/intelligence-field-notes): personal notes, shared for convenience and with no claim to be exhaustive. A copy for offline use is in [`docs/field-notes/`](field-notes/README.md). This page covers only what is specific to Argos; its sister project [Speculator](https://github.com/SOsintOps/Speculator-Project) follows the same rules on Debian 13.

## The Common Method
| Read | For |
| :--- | :--- |
| [Analytic Standards](field-notes/analytic-standards.md) | The intelligence cycle and the [ICD 203](https://www.dni.gov/files/documents/ICD/ICD-203.pdf) standards every product must meet |
| [OSINT Methodology](field-notes/osint-methodology.md) | The OSINT cycle, the 5W1H method, collection discipline and OPSEC |
| [Analytic Techniques](field-notes/analytic-techniques.md) | Biases, key assumptions check, ACH, deception |
| [Estimative Language](field-notes/estimative-language.md) | Likelihood terms and confidence levels, and how not to mix them |
| [Source Evaluation](field-notes/source-evaluation.md) | The [UNODC](https://www.unodc.org/documents/organized-crime/Law-Enforcement/Criminal_Intelligence_for_Analysts.pdf) 4 x 4 grading used in the Argos templates |
| [Report Writing](field-notes/report-writing.md) | BLUF, structure, prose, checklist; see also [Writing the report with Argos](report-writing.md) |

## The Standards in an Argos Case
Argos does the record-keeping that the standards require; the judgement stays with the analyst.

| Standard | Where Argos helps |
| :--- | :--- |
| Describe the quality of sources and method (tradecraft 1) | Every run folder holds `command.txt` (tool, version, exact command, UTC times, operator) and `SHA256SUMS`. The source table of every template has a column for the run folder, the SHA-256 and the 4 x 4 grade. |
| Express uncertainty (tradecraft 2) | The templates print the confidence levels and the likelihood row to use, so that the wording is the same in every report. |
| Separate information from judgement (tradecraft 3) | Run folders are raw captures, never edited. Notes, leads and draft judgements go in the CherryTree case notebook (`Argos_Case_Notebook.ctd`); the report keeps findings and judgements in separate sections. |
| Analysis of alternatives (tradecraft 4) | Add a "Hypotheses" node to the case notebook and keep the ACH matrix there; Quaesitor draws hypothesised links dashed, apart from confirmed ones. |
| Explain change (tradecraft 7) | Reports carry a reference and a date; a later report quotes the reference it updates. |
| Visual information (tradecraft 9) | Quaesitor and Flowsint for link charts, Google Earth Pro for places. A chart is an annex of the written report, never a substitute. |
| Based on all available sources | The research log (`Argos_Research_Log.csv`) records every search, including those that found nothing, so the gaps are visible. |

## Tool Output Is a Lead, Not a Source
Most Argos launchers return pointers, not facts. Grade what the pointer leads to, after you have opened and captured it:
- **Username tools** (Maigret, Sherlock, Blackbird, User Scanner, Socialscan): a "found" is a page that answered; it says nothing about who owns the account. Open the profile, capture it, then decide whether it is the same person and with what confidence.
- **Breach and lookup services** (Hudson Rock and similar): third-party claims about a leak. Grade the service as the source and the data as information it does not know personally (`4` unless corroborated).
- **Domain and infrastructure tools** (theHarvester, Amass, Shodan, WHOIS): records from registries and scanners. The registry is usually a reliable source; what a registrant declared about themselves is their claim.
- **Media and metadata** (yt-dlp, Instaloader, ExifTool): the file is first-hand, its metadata can be stripped or forged. Corroborate dates and places from metadata before using them.

## OPSEC on the Argos Virtual Machine
The general rules are in [OSINT Methodology](field-notes/osint-methodology.md#operational-security-opsec-best-practices). On Argos in particular:
- Take a clean snapshot of the virtual machine after installation and return to it between unrelated cases.
- Use the Firefox research profile only with research accounts; Instaloader and the "use my Firefox session" options borrow its cookies.
- Options that send the target to a third party are off by default and name the service when they ask; read the name before saying yes.
- Options that may alert the target (User Scanner "loud" checks, Amass active checks) warn first: treat the warning as a decision point, not a formality.
- Keep `~/Documents/Argos` on an encrypted disk and the credentials in KeePassXC.

## Further Reading
The full list, with a link for every text, is the [Reading List](field-notes/reading-list.md). The essentials:
- **"Psychology of Intelligence Analysis"** by Richards J. Heuer Jr. (CIA, 1999). [PDF](https://www.cia.gov/resources/csi/static/Pyschology-of-Intelligence-Analysis.pdf)
- **"ICD 203: Analytic Standards"** (ODNI). [PDF](https://www.dni.gov/files/documents/ICD/ICD-203.pdf)
- **"Criminal Intelligence: Manual for Analysts"** by Howard Atkin (UNODC, 2011). [PDF](https://www.unodc.org/documents/organized-crime/Law-Enforcement/Criminal_Intelligence_for_Analysts.pdf)
- **"Structured Analytic Techniques for Intelligence Analysis"** by Randolph H. Pherson and Richards J. Heuer Jr. (CQ Press / SAGE). [SAGE](https://www.sagepub.com/en-us/cab/structured-analytic-techniques-for-intelligence-analysis/book255432)
- **"OSINT Techniques"** (11th edition) by Michael Bazzell and Jason Edison. [IntelTechniques](https://inteltechniques.com/book1.html)
- **"Extreme Privacy"** (5th edition) by Michael Bazzell. [IntelTechniques](https://inteltechniques.com/book7.html)
- **"Deep Dive: Exploring the Real-World Value of Open Source Intelligence"** by Rae L. Baker (Wiley, 2023). [Wiley](https://www.wiley.com/en-us/Deep+Dive%3A+Exploring+the+Real+world+Value+of+Open+Source+Intelligence-p-9781119933243)
