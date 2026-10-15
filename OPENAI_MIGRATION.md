# OpenAI migration validation (2026-10-14)

## Implemented on this branch
- OpenAI picker offers gpt-6-luna for economy and gpt-6-sol for a higher capability tier; redundant retired choices removed. Default affirmative/opposition indices remain 0/1; settings do not persist picker indices.
- Only OpenAI requests use reasoning_effort=none and max_completion_tokens=1500. DeepSeek/Groq retain max_tokens=1500. Existing content-delta SSE parser is retained.

## Dependency review
Direct URLSession calls; no OpenAI SDK. RealmSwift is configured against master and Package.resolved pins revision 19b98b381c62d1c8eb9b5e6274869b34f6878b7c; leave dependency versions unchanged for this migration. ResearchService calls Gemini before debate generation, so failures there must be distinguished from OpenAI failures.

## Verification completed
Source scan of all Swift files and project/dependency files. Remote read-back of modified files matches prepared contents. Static checks confirm retired text IDs removed from changed code and provider-specific token parameters retained. No Swift/Xcode compiler or API test credentials were available; these are NOT compilation or live API tests.

## Required before merge/release
- Build Debug and Release in Xcode with existing dependency lockfile.
- Exercise both new OpenAI picker choices on both sides for two rounds; verify incremental content, completed output, language, history, save/reopen/export.
- Regress DeepSeek/Groq request payloads: max_tokens retained, no OpenAI-only reasoning_effort. Distinguish Gemini research errors.
- Regress speech playback independently.
- Inspect actual outbound JSON (without logging API keys), test missing key/model access, 400/401/429, timeout, cancellation, and empty/truncated output.
- Use representative samples to compare quality, latency and actual billed usage before production rollout. Do not infer quality from model names.
- Release the updated app to every device; changing GitHub alone does not update installed binaries.

## Separate audio migration still required
These are outside the October 14 text-model email, but separately deprecated:
- gpt-4o-mini-tts dated snapshots: January 6, 2027; recommended replacement gpt-realtime-2.1-mini. Resolve the unversioned alias with the account Models API. Do not insert the Realtime model into the existing /audio/speech MP3/AAC request without validating its API contract. Implement a separate Realtime audio adapter or use on-device speech where available.


Sources:
- https://developers.openai.com/api/docs/deprecations
- https://developers.openai.com/api/docs/models/gpt-6-luna
- https://developers.openai.com/api/docs/models/gpt-6-sol
- https://developers.openai.com/api/docs/guides/latest-model
- https://developers.openai.com/api/docs/guides/speech-to-text
