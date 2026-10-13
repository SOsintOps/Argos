# Writing the Report with Argos

The rules of the report (bottom line up front, structure, facts versus judgements, estimative language, prose, release checklist) are in [Report Writing](field-notes/report-writing.md), the copy shipped with Argos of the page in the [Intelligence Field Notes](https://github.com/SOsintOps/intelligence-field-notes). This page says which Argos template to use and how to fill it.

## Which Template
`./setup.sh templates` copies the templates to `~/Templates`; the sources are in [`templates/`](../templates/).

| Product | Template | When |
| :--- | :--- | :--- |
| Full report | `Argos_Report_Full.docx` | The complete written product of a case, in numbered sections: header with version and handling, bottom line, tasking, key judgements, findings, subject overview, narrative, timeline, analysis, gaps and next steps, recommendations (only if requested), sources, method and limitations, annexes |
| Executive summary | `Argos_Report_Executive.docx` | One or two pages for a decision maker (bottom line, key judgements, key findings, recommended action only if requested, sources); the full report stays in the case |
| Plain report | `Argos_Report_Plain.md` | A shorter report in Markdown (bottom line, key judgements, findings, details, analysis, gaps and next steps, sources, method), for Obsidian, VSCodium or a ticketing system |
| Subject profile | `Argos_Subject_Profile.docx` | One person or organisation, attribute by attribute, each with source and confidence |
| Event assessment | `Argos_Event_Assessment.docx` | The risk around an event or a date: bottom line first, then indicators |
| Threat notice | `Argos_Threat_Notice.docx` | A short alert to paste into chat or email: what, where, when, who, grade, recommendation |
| Case cover sheet | `Argos_Case_Cover_Sheet.docx` | The front page of the case, with the chain of custody of the evidence |
| Online investigations policy | `Argos_OSINT_Policy.docx` | The rules your team works under: authorisation, accounts, OPSEC, retention |

## Filling It In
- **Bottom line first, written last.** Draft the findings and the judgements, then write the three to five sentences that cover them.
- **Key judgements:** numbered, one sentence each, each with either a likelihood word or a confidence level (High, Moderate, Low) and the findings or sources it rests on.
- **Findings table:** one fact per row, with the references of its sources (`S1`, `S2`) and their 4 x 4 grades. Facts take no likelihood word and no confidence level. A statement you cannot source is a judgement: move it to the key judgements or the analysis.
- **Sources table:** one row per source with the URL or origin, the capture time in UTC, the Argos run folder and the SHA-256 from its `SHA256SUMS`, and the **4 x 4 grade** (see [Source Evaluation](field-notes/source-evaluation.md)). Manual captures go in the case's `manual-captures` folder; hash them with `sha256sum` before you cite them.
- **Likelihood words:** only the [ICD 203](https://www.dni.gov/files/documents/ICD/ICD-203.pdf) row printed in the template (almost no chance, very unlikely, unlikely, roughly even chance, likely, very likely, almost certain), and never in the same sentence as a confidence level.
- **Analysis, gaps and next steps:** the alternatives you considered and why you rejected them, the key assumptions, what you could not establish and what would close each gap.
- **Recommendations:** only if the requester asked for them, and nowhere else in the report; otherwise delete the section.
- **Method and limitations:** the Argos version (the first line of any run folder's `command.txt`, `Argos: <version>`), the collection window, the research environment, and what you did not search.
- **Annexes:** export Quaesitor or Flowsint charts to PDF and attach them; the chart supports the report, it does not replace it.
- **Before release:** run the checklist in [Report Writing](field-notes/report-writing.md#checklist-before-release), set the handling marking in the header, delete the grey guidance notes.

## Older Templates
Templates from before 3.1.3-beta have no key judgements, gaps or annexes sections and put a confidence column in the findings table; templates from before 3.1.2-beta grade sources on the 6 x 6 scale (A to F, 1 to 6). Copy the new templates with `./setup.sh templates`; to convert grades already written, see [Converting from the 6 x 6 system](field-notes/source-evaluation.md#converting-from-the-6-x-6-admiralty-system).
