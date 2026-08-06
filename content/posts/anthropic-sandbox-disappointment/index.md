---
date: '2026-08-05T12:51:33-07:00'
draft: true
title: 'Anthropic Sandbox Disappointment'
tags: ['anthropic', 'sandbox', 'claude-code']
---

Maybe you are like I was: curious to run Claude Code on your machine, but feeling
hesitant. You suspect that things could [go][3] [terribly][1] [wrong][2].

[1]: https://www.reddit.com/r/ClaudeCode/comments/1sbpfdl/claude_code_deleted_my_entire_202gb_archive_after/
[2]: https://chriscole.substack.com/p/careful-claude-might-know-all-your
[3]: https://news.ycombinator.com/item?id=48916975

> I asked Claude Code to remove the empty volume and let the other one expand to the full 2TB. I explicitly said "do not remove any data."
>
> It ran `diskutil apfs deleteVolume` on the volume WITH my data.

So until recently, I thought it wasn't worth the potential headache.

A few days ago (I know Frontier Friends, I'm behind), I decided it was time to try it anyway. The internet finally convinced me that the coding opportunities are just too promising.


### Don't accidentally my whole system

The obvious solution is to add an isolation layer of some kind. So if Claude Code goes rogue, it
won't cause so much damage.

I figured that Anthropic cares about security, so surely they must have some prebuilt solution.
The often-recommended one is to wrap `claude` inside of
[`srt`](https://github.com/anthropic-experimental/sandbox-runtime/).


### `srt` Disappoints

`srt` offers to limit access to the filesystem (and network), in a configurable way. Then you can
run `srt claude` and Claude won't be able to see the files outside its sandbox. They make [big
promises](https://github.com/anthropic-experimental/sandbox-runtime/#overview):

> It's designed with a **secure-by-default** philosophy tailored for common developer use cases: processes start with minimal access, and you explicitly poke only the holes you need.

So when you say **secure-by-default** do you mean that it doesn't have read access to my files?

```sh
$ cd ~/code
$ srt head -1 ~/Documents/journal.text 
Dear Diary...
```

Oh. :( But surely the dotfiles, especially my keys...

```sh
$ srt head -1 ~/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
```

*facepalm*


### Foolishly, I don't give up yet

You can configure `srt` to block access to these things with `~/.srt-settings.json`. But I don't
want to contemplate what might be private in each folder. I want to block everything and whitelist
the folders that are fine.

I'll skip the boring details of me banging around figuring it out (with the help of Claude). Here is
the gist:

- If you deny access to `/` and add your current project folder, then you can't run any commands.
  The environment can't find `/usr/bin`, for example. Okay, that makes sense. I have a lot of
  whitelisting to do now...
- When a file is blocked, there is no useful output. The official answer is to `strace` the command
  and grep for `EPERM`. Fine, I guess, but am I doing that for a long-running Claude session? No. No, I am not.

### Be the change

Well, maybe I can improve it? `srt` is open source. I have some good ideas.

Unfortunately, the repository doesn't look super responsive to outside requests. I see a lot of open
pull requests and issues that have been around for a while, without comment. Some that seem pretty
[aggravating](https://github.com/anthropic-experimental/sandbox-runtime/issues/139).

It doesn't seem worth my time to try to open a PR.

### A better alternative

In the end I went a very different direction. I'll save that for the next post. (Yes, it's the
direction of Docker containers, but not exactly)

If you're interested in this kind of tool, though, there are
better options. [`nono`](https://github.com/nolabs-ai/nono) does basically what I expected `srt` to
do, with `nono run --profile claude-code --allow-cwd -- claude`. (I'm not affiliated)

See you next time!
