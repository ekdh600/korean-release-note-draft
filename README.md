# Korean Release Note Draft

Review a Korean customer-facing release note in GitHub Actions before publishing it. The sample runs without a key. To generate a draft from your own change list, use the Korean release notes kit and your OpenAI API key.

## Try the sample

The [sample input](sample/intake.md) describes a fictional API's pagination and CSV changes. The [sample note](sample/release-note.md) shows how to present the new default and retain the exact `limit=100` request example. Sample mode copies this prewritten note into a workflow artifact.

```yaml
name: Preview Korean release notes
on: workflow_dispatch
permissions:
  contents: read
jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      - id: note
        uses: ekdh600/korean-release-note-draft@v0.1.0
      - uses: actions/upload-artifact@cf430e030ddbb5b0abf93d22962f4752f3646cd9 # v7
        with:
          name: korean-release-note
          path: ${{ steps.note.outputs.draft }}
          if-no-files-found: error
```

## Draft from your approved changes

1. Get the [Korean release notes kit](https://quote-api.haebow.com/demo/#release-notes-kit). It contains the input form, release note template and Python generator. The page shows the current price and purchase inquiry.
2. On a trusted branch, unpack the kit as `release-notes-kit/` and fill out `release-intake.md` with approved changes. Add `actions/checkout` with `persist-credentials: false` and Python 3.12 before the action. Alternatively, check out the code and prepare the kit in an earlier step of the same job.
3. In your GitHub repository, configure `OPENAI_API_KEY` as an Actions secret. Update the `note` step as shown, keeping the artifact step. OpenAI bills usage to the owner of that key.

```yaml
- id: note
  uses: ekdh600/korean-release-note-draft@v0.1.0
  with:
    mode: draft
    kit-path: release-notes-kit
    source: release-intake.md
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

Draft mode sends the selected intake file to OpenAI. Run it from a trusted checkout with the approved input and kit. Review the resulting Markdown against the source before publishing. Anyone who can read the public repository can download artifacts from its runs, so use a private repository for internal drafts.

한국어 변경사항 정리를 맡기려면 [릴리스 노트 작성 문의](https://quote-api.haebow.com/demo/?lang=ko#release-notes), 양식과 생성기를 쓰려면 [한국어 릴리스 노트 키트](https://quote-api.haebow.com/demo/?lang=ko#release-notes-kit)를 확인하세요.
