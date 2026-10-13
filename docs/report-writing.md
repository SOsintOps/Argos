# Writing the Report with Argos

The rules of the report (bottom line up front, structure, facts versus judgements, estimative language, prose, release checklist) are in [Report Writing](field-notes/report-writing.md), the copy shipped with Argos of the page in the [Intelligence Field Notes](https://github.com/SOsintOps/intelligence-field-notes). This page says which Argos template to use and how to fill it.

## Which Template
`./setup.sh templates` copies the templates to `~/Templates`; the sources are in [`templates/`](../templates/).

| Product | Template | When |
| :--- | :--- | :--- |
| Full report | `Argos_Report_Full.docx` | The complete written product of a case: bottom line, tasking, key findings, subject overview, narrative, analysis, gaps, sources |
| Executive summary | `Argos_Report_Executive.docx` | One or two pages for a decision maker; the full report stays in the case |
| Plain report | `Argos_Report_Plain.md` | A shorter report in Markdown (bottom line, findings, details, sources, method), for Obsidian, VSCodium or a ticketing system |
| Subject profile | `Argos_Subject_Profile.docx` | One person or organisation, attribute by attribute, each with source and confidence |
| Event assessment | `Argos_Event_Assessment.docx` | The risk around an event or a date: bottom line first, then indicators |
| Threat notice | `Argos_Threat_Notice.docx` | A short alert to paste into chat or e-mail: what, where, when, who, grade, recommendation |
| Case cover sheet | `Argos_Case_Cover_Sheet.docx` | The front page of the case, with the chain of custody of the evidence |
| Online investigations policy | `Argos_OSINT_Policy.docx` | The rules your team works under: authorisation, accounts, OPSEC, retention |

## Filling It In
- **Bottom line first, written last.** Draft the findings, then write the three to five sentences that cover them.
- **Findings table:** one finding per row, its confidence (High, Moderate, Low) and the references of its sources (`S1`, `S2`). A finding with no source reference is a judgement: move it to the analysis.
- **Sources table:** one row per source with the URL or origin, the capture time in UTC, the Argos run folder and the SHA-256 from its `SHA256SUMS`, and the **4 x 4 grade** (see [Source Evaluation](field-notes/source-evaluation.md)). Manual captures go in the case's `manual-captures` folder; hash them with `sha256sum` before you cite them.
- **Likelihood words:** only the ICD 203 row printed in the template (almost no chance, very unlikely, unlikely, roughly even chance, likely, very likely, almost certain), and never in the same sentence as a confidence level.
- **Method and limitations:** the Argos version (the first line of any run folder's `command.txt`), the collection window, the research environment, and what you did not search.
- **Annexes:** export Quaesitor or Flowsint charts to PDF and attach them; the chart supports the report, it does not replace it.
- **Before release:** run the checklist in [Report Writing](field-notes/report-writing.md#checklist-before-release), set the handling marking in the header, delete the grey guidance notes.

## Templates Written Before 3.1.2-beta
Templates generated before 3.1.2-beta grade sources on the 6 x 6 scale (A to F, 1 to 6). Copy the new templates with `./setup.sh templates`; to convert grades already written, see [Converting from the 6 x 6 system](field-notes/source-evaluation.md#converting-from-the-6-x-6-admiralty-system).
