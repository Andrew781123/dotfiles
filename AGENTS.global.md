# Global agent instructions

## Technical decision-making

Weight long-term codebase health over development cost. Your estimates are anchored
to human timelines, but you write code far faster than a human, so they overstate the
effort of the robust option. Assume implementation cost is low; when the cheap option
is only cheaper short-term, pick robust.

YAGNI governs **scope**: the least code that *fully* solves the problem. Reach for the
standard library before adding a dependency. It never governs **quality**: robustness,
correctness, input validation at trust boundaries, and error handling that prevents
data loss are not traded away for a smaller diff.

## Questions vs. actions

If a prompt asks a question, or it is ambiguous whether it wants advice or action,
answer in text first and stop — a clarifying answer is cheaper than reverting an
unwanted edit. Edit code only when the prompt also unambiguously asks for work; if it
does both, do the work, then answer.

## Shell

Pass the shell tool's `workdir` instead of prefixing a command with `cd`. Inside one
command, `cd` moves the directory for everything after it, so a later path on the same
line resolves from the new directory.

## Communication

English is not my first language. Optimize for being understood over being brief.
This takes precedence over any terseness rule, including skill output formats and
ponytail.

- Define technical terms and metaphors on first use, and state the sense you mean when
  reusing a term in a narrower or shifted sense. Applies to docs, ADRs and code
  comments, not just chat.
- Show the reasoning, not just the conclusion.
- State assumptions explicitly rather than silently choosing one.
- Prefer short, literal sentences over dense or figurative ones.

When running a grilling skill, keep the method exactly as defined — change only the
wording, never the questions asked or their order — and express each question in plain
words: what it is asking, and why it matters.
