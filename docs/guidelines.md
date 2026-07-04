# OSINT Analysis Guidelines

## Core Analytic Standards
Adherence to the five Core Analytic Standards is strongly suggested for all intelligence products. 
These standards ensure the rigor and integrity of the analysis.

### The Five Analytic Standards
**Objective:** Analysts must perform their functions with objectivity, be aware of their own assumptions, and employ reasoning techniques to mitigate bias.

**Independent of political consideration:** Analytic assessments must not be distorted by advocacy of a particular audience, agenda, or policy viewpoint.

**Timely:** Analysis must be disseminated in time for it to be actionable by stakeholders.

**Based on all available sources of intelligence information:** Analysis should be informed by all relevant available information and address critical information gaps.

**Implements and exhibits Analytic Tradecraft Standards:** This standard serves as an overarching requirement for the nine standards below.

### The Nine Analytic Tradecraft Standards
1.  Properly describes quality and credibility of underlying sources, data, and methodologies.
2.  Properly expresses and explains uncertainties associated with major analytic judgments. For expressions of likelihood, an analytic product must use standardized sets of terms:

| Almost No Chance | Very Unlikely | Unlikely | Roughly Even Chance | Likely | Very Likely | Almost Certain(ly) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Remote | Highly Improbable | Improbable | Roughly Even Odds | Probable | Highly Probable | Nearly Certain |
| 01-05% | 05-20% | 20-45% | 45-55% | 55-80% | 80-95% | 95-99% |

3.  Properly distinguishes between underlying intelligence information and analysts’ assumptions and judgments.
4.  Incorporates analysis of alternatives by systematically evaluating differing hypotheses.
5.  Demonstrates stakeholder relevance and addresses implications for action.
6.  Uses clear and logical argumentation with a clear main message supported by coherent reasoning.
7.  Explicitly explains change to or consistency of analytic judgments compared to previous analysis.
8.  Makes accurate judgments and assessments based on available information and known gaps.
9.  Incorporates effective visual information where appropriate to clarify the analytic message.

## The 5W1H Analytical Method
The 5W1H method (Who, What, When, Where, Why, How) is a cognitive tool that imposes order on chaotic data streams, enhances analytical clarity, and provides a structured pathway for transforming raw open-source information into finished intelligence. It serves as a safeguard against common analytical pitfalls and cognitive biases, such as confirmation bias and tunnel vision.

### The Six Components
#### Who: Identifying Actors and Networks
This component focuses on identifying all individuals, companies, or entities connected to the investigation. It moves beyond simple identification to focus on the relationships, motivations, and structures of the individuals and groups involved.
- **Guiding Question:** Who are the primary and secondary actors (individuals, groups, organizations)?
- **Guiding Question:** Who are the key nodes and influencers within the network?
- **Guiding Question:** Who provides financial, logistical, or ideological support?

#### What: Defining the Event and Assets
This element involves understanding the core incident or event and setting the focus of the investigation. It seeks to clearly define the nature of the event, action, or capability being investigated.
- **Guiding Question:** What specific event or activity is under investigation?
- **Guiding Question:** What capabilities or TTPs (Tactics, Techniques, and Procedures) were demonstrated?
- **Guiding Question:** What specific vulnerability was exploited?

#### When: Establishing the Temporal Dimension
This dimension addresses timeline matters and temporal context. It is the foundation of timeline analysis, placing events in a chronological context to reveal patterns, triggers, and sequences.
- **Guiding Question:** What is the precise start and end date/time of the event?
- **Guiding Question:** What is the full timeline of significant actions?
- **Guiding Question:** Is there a discernible pattern related to time-of-day, day-of-week, or season?

#### Where: Pinpointing Location and Jurisdiction
This component encompasses both physical and digital locations relevant to the investigation. It is crucial for understanding the operational environment and applicable constraints.
- **Guiding Question:** Where is the physical location (country, city, address, coordinates)?
- **Guiding Question:** Where is the digital location (website, IP address, social platform, forum)?
- **Guiding Question:** What legal or administrative jurisdictions apply to the location?

#### Why: Assessing Intent and Motivation
This is often the most critical and challenging question, as it seeks to uncover the underlying purpose or motive behind an action. Answering "Why" is essential for assessing threats and predicting future behavior.
- **Guiding Question:** What is the stated or inferred motive (e.g., financial, political, ideological, personal)?
- **Guiding Question:** Why was this specific target, timing, or method chosen over others?
- **Guiding Question:** What is the root cause of the problem or event?

#### How: Detailing the Modus Operandi
This question focuses on the operational mechanics: the methods, tools, and procedures used to carry out an action, often referred to as Tactics, Techniques, and Procedures (TTPs).
- **Guiding Question:** How were the actions executed (step-by-step process)?
- **Guiding Question:** What specific tools, software, or hardware were used?
- **Guiding Question:** How was detection avoided or security circumvented?

## Operational Security (OPSEC) Best Practices
Effective OPSEC is not optional. It is a core discipline required to protect yourself, your investigations, and the organization from exposure and adversarial counter-intelligence. Conduct all activities with the highest ethical standards and in accordance with all applicable laws.
- **Identity Segregation:** Never use personal accounts or equipment for investigative activities. Create and use dedicated, non-attributable online accounts and personas for your work. Do not link these personas to each other or to your real identity.
- **Secure Infrastructure:** Always use a trusted, no-log Virtual Private Network (VPN) to mask your true IP address. For sensitive investigations, conduct your work from within a dedicated Virtual Machine (VM) to sandbox your activities from your host machine. Consider using the Tor Browser for enhanced anonymization.
- **Sterile Browse Environment:** Use a dedicated web browser with separate profiles for each digital persona. Install privacy-enhancing extensions (e.g., ad blockers, script blockers, anti-tracking tools). Regularly clear cookies, cache, and history.
- **Disciplined Online Conduct:** Be aware of your digital footprint. Avoid providing unnecessary personal information when registering for services. Use unique, strong passwords and email addresses for each persona. Be cautious about the information you "like," share, or post, as it can be used to profile your persona.
- **Secure Data Handling:** All information collected during an investigation must be stored securely. Use encrypted storage for your case files. Establish a clear data retention and destruction policy to securely delete information that is no longer needed.

## Further Reading
For a more in-depth analysis of the methodologies and practices discussed, the following foundational texts are recommended:
- **"Psychology of Intelligence Analysis"** by Richards J. Heuer Jr. - A crucial text for understanding and mitigating the cognitive biases that affect analytical judgment.
- **"Criminal Intelligence: Manual for Analysts"** by Howard Atkin (UNODC, 2011) - A UNODC reference manual covering the full intelligence process: source evaluation, link analysis, event charting, flow analysis, and telephone analysis. Equips practitioners to develop inferences and present analytical results.
- **"Structured Analytic Techniques for Intelligence Analysis"** by Richards J. Heuer Jr. and Randolph H. Pherson - A reference manual that presents dozens of structured analytical techniques to improve the rigor and quality of analysis.
- **"Extreme Privacy: What It Takes to Disappear"** by Michael Bazzell - An extensive guide on digital security and maintaining anonymity, which directly supports the OPSEC principles discussed.
- **"Open Source Intelligence Techniques"** by Michael Bazzell - A comprehensive, practical guide to the tools and techniques for gathering information from open sources.
- **"Deep Dive: Exploring the Real-World Value of Open Source Intelligence"** by Rae L. Baker - Real-world case studies demonstrating the practical application and value of OSINT across various sectors.