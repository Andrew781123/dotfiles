# Handoff: A clearer communication layer for the Ponytail skill

## What the user wants

The user uses the **Ponytail** coding-agent skill and is happy with it. Ponytail
makes their code shorter and simpler, and it avoids unnecessary abstraction. The
user wants to keep that behavior.

The problem is Ponytail's **communication style**, not its code style. Ponytail
makes the agent's prose too terse, compressed, and information-dense for the user
to read comfortably. English is the user's second language.

The goal is a communication layer that keeps code concise but makes the
surrounding explanation clearer and easier to understand. It must not optimize
for minimum word count. Specifically, the user asked for these properties:

- Explanations stay clear rather than extremely terse.
- Simple, natural English.
- Complete sentences instead of compressed technical phrases.
- The reasoning behind important decisions is explained.
- When the agent asks a question, it briefly says why the question matters and
  what decision depends on the answer.
- No unnecessary verbosity, but communication is not optimized for minimum word
  count.
- Technical concepts are made understandable without assuming the user already
  knows every term.
- Code stays concise while the surrounding explanation is allowed to be explicit.
- The layer works alongside Ponytail and does not override its code-minimization
  principles.

## Decisions already made

- **Do not build a new communication skill from scratch first.** The prime
  directive is to reuse an existing skill where one fits, and to add only a thin
  always-on layer on top. See "Recommended approach" below.
- **Rejected: `nathanksou/eli5`.** It appears in searches for "explain simply,"
  but it does the opposite of what the user needs. Its first rule is "Short as
  possible. Every word must earn its place." It instructs the agent to cut
  articles, use symbols such as `->` instead of words, and write in fragments.
  This is minimum-word-count optimization and is exactly the style the user finds
  hard to read. Do not install it.

## The mechanism behind the problem

The terseness is not accidental. Ponytail's own `SKILL.md` contains an **Output**
section with this rule:

> "Code first. Then at most three short lines... No essays, no feature tours, no
> design notes. If the explanation is longer than the code, delete the
> explanation."

That rule is what compresses the user's explanations. Ponytail also has an
`ultra` intensity level that pushes answers toward one-liners.

However, Ponytail's **Boundaries** section ends with:

> "Ponytail governs what you build, not how you talk."

This is the hook. Ponytail already declares that its job is code and that
communication is a separate concern. A communication layer can therefore
override the *Output* rules while leaving the *ladder* and the *code* rules
untouched. There is no conflict in principle.

Ponytail's `SKILL.md` is installed at:
`/Users/andrew/.pi/agent/git/github.com/DietrichGebert/ponytail/skills/ponytail/SKILL.md`

The user's active Ponytail mode in the previous session was **full**.

## Research findings (not captured anywhere else yet)

The previous session searched the skills.sh registry with `npx skills find`,
several GitHub repositories, and the user's locally installed skills, then read
the actual `SKILL.md` of each candidate. Note: there is no reliable review corpus
for these skills, so install count, stars, license, and last-commit date were
used as the available signals of adoption and maintenance.

### Top candidates

| Skill | Source | What it does | Code or comms? | Compatible with Ponytail? | Maintained? | Addresses terseness? |
|---|---|---|---|---|---|---|
| `danyuchn/asd-ste100-skill` | https://github.com/danyuchn/asd-ste100-skill (2,039 stars, MIT) | Rewrites dense English into short, single-meaning sentences. Active voice, ≤25 words per sentence, define jargon, preserve every qualifier and hedge. | Communication only. | Yes. Targets clarity, not brevity. | Yes, v0.4.0, last push 2026-09-08. | Yes, explicitly: "Cutting words is not the goal. Removing ambiguity is the goal." |
| `mgifford/accessibility-skills@plain-language` | https://github.com/mgifford/accessibility-skills (133 installs, 44 stars, AGPL-3.0) | Plain-language rules from WCAG work. Targets non-native readers and cognitive load, Grade-8 reading level. | Communication only. | Yes, but scoped to web content, UI copy, and docs, not agent chat. | Yes, last push 2026-09-09. | Mostly, but framed as accessibility compliance. |
| `tamdogood/builder-essential-skills@orwell-writing` | https://github.com/tamdogood/builder-essential-skills (177 installs, 198 stars, MIT) | Orwell's six rules plus an ASD-STE100 baseline. Says "do not make prose crude, false, or flat just to make it short." | Communication only. | Yes, the balance is good. | Yes, last push 2026-08-16. | Partly. Aimed at drafting and editing prose, not at live coding chat. |
| `synapseradio/ai-skills@communicate` | https://github.com/synapseradio/ai-skills (83 installs, 2 stars, EUPL-1.2) | A full writing workflow: diagnose audience, build a rubric, draft, score, revise. Has a reference file for non-native writers. | Communication only. | Weak fit. Heavyweight and not always-on; it would turn every reply into a writing project. | Last push 2026-07-31. | Indirectly. |
| `human-avatar/skills-for-humanity@s4h-writing-audience-calibration` | https://github.com/human-avatar/skills-for-humanity (32 installs, repo 225 stars, MIT) | Calibrates writing for a specific reader: their knowledge, stakes, and relationship to the topic. | Communication only. | Yes, but it is a one-off tool, not a standing style. | Last push 2026-07-15. | Partly. Matches a reader; does not stop constant terseness. |

### Verdict from the research

**Best existing skill: `danyuchn/asd-ste100-skill`.** ASD-STE100 was invented for
aircraft maintenance crews who are mostly non-native English speakers. The skill
uses short sentences, one idea per sentence, plain words, and active voice. It
protects meaning by keeping every condition, number, and qualifier, and it
preserves hedges instead of upgrading them into false certainty. It has two modes:
"Strict" for procedures and error messages, and "STE-flavored" for explanatory
prose. The flavored mode is the register the user wants. It also produces a
before/after rule table when asked to "show the diff" or "explain the changes."

### The one gap in the best candidate

The STE skill is a **rewriter that is invoked on a piece of text**. It is not an
always-on conversational persona. Its own default output is "the rewritten text,
and nothing else," which is deliberately terse. On its own it will not stop
Ponytail from compressing explanations every turn. This is why a small always-on
companion is still needed.

## Recommended approach

1. Install the STE skill:

   ```bash
   npx skills add danyuchn/asd-ste100-skill -g -y
   ```

2. Write one small always-on companion skill (roughly 40 lines of Markdown).
   It must do exactly four things:

   1. Keep Ponytail's ladder and code rules fully active.
   2. Override Ponytail's **Output** section: explanation may be as long as
      clarity requires, and is never compressed for word count.
   3. Apply the STE-flavored register: complete sentences, one idea per sentence,
      active voice, ≤25 words per sentence, no phrasal verbs, define a technical
      term on first use, keep hedges.
   4. When asking the user a question, state **why the question matters and what
      decision depends on the answer.**

   The companion touches communication only, so it cannot break Ponytail's
   code-minimization behavior.

## Open questions that block writing the companion

The user said they cannot decide these yet. Ask them again when they resume.

1. **Scope: coding chat only, or also documents and commit messages?**
   Coding chat only keeps the companion short. Adding artifacts (commits, docs,
   PR descriptions) roughly doubles the file and adds an artifact section.
   This matters because mixing the two is how such a skill becomes a general
   writing style that fights Ponytail where the user never wanted it.

2. **Should technical terms be defined on every first use, or only when
   non-obvious?**
   Defining everything is clearer but longer and can feel condescending. Defining
   only non-obvious terms is shorter but assumes more knowledge. This matters
   because it sets the default reading level and is the biggest lever on answer
   length.

**Suggested default if the user still cannot decide:** scope = coding chat only,
and terms = define on first use. This is the safer choice for a second-language
reader and can be loosened later. State this default and proceed rather than
stalling.

## Useful local context

- The user already has a manual escape hatch installed:
  `/Users/andrew/.agents/skills/wait-what/SKILL.md`. It re-pitches the last
  message in ASD-STE100 Simplified Technical English. It is user-invoked
  (`disable-model-invocation: true`) and is a good safety net, but it is not an
  always-on style.
- The user's dotfiles repo is at `/Users/andrew/.dotfiles`. Bundled skills live
  under `.agents/skills/` and are mirrored to `~/.agents/skills/`. If the
  companion skill should be portable across machines, add it to the dotfiles repo
  and mirror it, following the pattern in `/Users/andrew/.dotfiles/AGENTS.md`.

## Suggested skills for the next agent

- **`ponytail`** — keep active so the code behavior is preserved.
- **`writing-for-agents`** — use when writing the companion `SKILL.md`, so its
  description and structure are built correctly.
- **`write-a-skill`** — use to scaffold the companion skill if a full structure
  is preferred over a minimal file.
- **`find-skills`** — only if the user wants to broaden the search further before
  deciding.

## Next action

Ask the user the two open questions again. If they still cannot decide, apply the
suggested default, install the STE skill, write the companion, and then show the
user a short before/after example of an answer written under the new rules so
they can confirm the style feels right.
