# audio-transcribe: the two flows

Two diagrams. **Figure 1** is setup, which happens once on a machine. **Figure 2** is a run, which happens every time afterwards.

Neither is a substitute for `INSTALL.md` — the diagrams show the shape, that file says why the shape is that way and what it looks like when a step fails.

---

## Figure 1 — Setting up (one time, ask first)

Setup is a task of its own. Do not start it in the middle of something else, and do not start it without saying what it costs first: an account with a provider, a free tier with a ceiling, and their audio being sent to a named company's servers.

```mermaid
flowchart TD
  A["Person wants this working<br/>on their machine"] --> B{"Which languages<br/>will they actually record?"}

  B -->|"English / Chinese"| G["Groq key needed"]
  B -->|"Khmer"| M["Gemini key needed"]
  B -->|"Both"| BOTH["Both keys<br/>(set up separately)"]

  G --> SAY
  M --> SAY
  BOTH --> SAY

  SAY["🟠 Say these BEFORE running anything:<br/>· their audio goes to a named company's servers<br/>· free tier has a ceiling; you'll ask before spending<br/>· ffmpeg install is a few hundred MB + password"]

  SAY --> ASK{"Do they agree?"}
  ASK -->|"no"| STOP["Stop. This is their decision.<br/>Nothing here is required."]
  ASK -->|"yes"| EXIST{"Key already at<br/>that path?"}

  EXIST -->|"yes"| SHOW["Show path, date, byte length.<br/>NEVER the value.<br/>Ask which one stays."]
  EXIST -->|"no"| RUN

  SHOW --> RUN["Give them this line to run:<br/>bash tools/setup-api-key.sh &lt;provider&gt; &lt;url&gt;"]
  RUN --> WIN["🟠 THEY run it, at their own terminal.<br/>You do not run it and no window opens.<br/>Run it yourself and it exits with an error,<br/>having written nothing.<br/>Hand it over, then wait."]
  WIN --> CONF["They compare length + last four<br/>against what they copied"]
  CONF --> VERIFY["Now prove it works —<br/>Figure 2, on a recording<br/>whose words you already know"]

  classDef gate stroke:#f59e0b,stroke-width:3px;
  class SAY,WIN gate;
```

**The one thing that is not negotiable in this figure:** you never receive the key value. Not pasted to you, not read back for confirmation, not "just the last part to check". `INSTALL.md` §2 says why.

---

## Figure 2 — A run, start to finish

```mermaid
flowchart TD
  IN["bash tools/transcribe.sh &lt;file&gt; &lt;en|zh|km&gt;"] --> CHK{"Language?"}

  CHK -->|"unknown"| REJ["Refused by name.<br/>Does NOT fall back to guessing."]
  CHK -->|"km"| KM["km_transcribe.py"]
  CHK -->|"en / zh"| CLOUD["transcribe-cloud.sh"]

  CLOUD --> SIZE{"over 25 MB?"}
  SIZE -->|"yes"| COMP["ffmpeg → mono 16kHz 32kbps"]
  SIZE -->|"no"| CALL
  COMP --> CALL["one call to Groq<br/>whisper-large-v3-turbo"]

  CALL --> ERR{"response"}
  ERR -->|"401"| E401["the key file's trailing newline,<br/>not the key"]
  ERR -->|"429"| E429["free-tier ceiling.<br/>wait, retry. nothing is broken"]
  ERR -->|"200"| SEG["parse segments<br/>(this is what keeps line breaks)"]

  SEG --> ZH{"zh?"}
  ZH -->|"yes"| S2TW["_s2tw.py<br/>Simplified → Traditional<br/>(dictionary, not a model)"]
  ZH -->|"no"| WRITE
  S2TW --> WRITE

  KM --> SPLIT["ffmpeg → 8-minute chunks"]
  SPLIT --> PAR["parallel calls to Gemini,<br/>language pinned in the prompt,<br/>thinkingBudget = 0"]
  PAR --> STITCH["stitch chunks back together<br/>(failures are named in the file,<br/>not hidden)"]
  STITCH --> WRITE

  WRITE["workspace/transcripts/&lt;date&gt;-&lt;name&gt;.md<br/>status: pending"]
  WRITE --> GLOSS["_glossary.py<br/>known-wrong names → correction table<br/>ABOVE the text. Body untouched.<br/>No glossary or no hits = does nothing."]
  GLOSS --> BUF["audio moves to buffer"]
  BUF --> HUMAN["🟠 Hand over a recap with the file.<br/>A transcript is raw material,<br/>not the thing anyone wanted."]
  HUMAN --> CHECKN["🟠 Before it goes to anyone else:<br/>check names, numbers, dates.<br/>Wrong ones look exactly like right ones."]

  classDef gate stroke:#f59e0b,stroke-width:3px;
  classDef bad stroke:#ef4444,stroke-width:2px;
  class HUMAN,CHECKN gate;
  class REJ,E401,E429 bad;
```

**`status: pending` is doing work.** It means *transcribed, not yet filed anywhere*. A transcript left at `pending` is unfinished business, not a finished job — that field is how you find the ones that got dropped.

---

## What this file does not cover

- **Why Khmer takes a different provider**, and why you should not re-test that → `INSTALL.md` §2.
- **What each silent failure looks like from the outside** → `INSTALL.md` §3, and `QA.md` in the person's own words.
- **How to prove any of this works on this machine** → `VERIFY.md`. A diagram is a claim about the code, not evidence about the machine.
