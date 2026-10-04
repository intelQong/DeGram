# Contributing

This document describes how you can contribute to DeGram Desktop.

**Table of Contents**

* [What contributions are accepted](#what-contributions-are-accepted)
* [Build instructions](#build-instructions)
* [Pull upstream changes into your fork regularly](#pull-upstream-changes-into-your-fork-regularly)
* [How to get your pull request accepted](#how-to-get-your-pull-request-accepted)
  * [Keep your pull requests limited to a single issue](#keep-your-pull-requests-limited-to-a-single-issue)
    * [Squash your commits to a single commit](#squash-your-commits-to-a-single-commit)
  * [Don't mix code changes with whitespace cleanup](#dont-mix-code-changes-with-whitespace-cleanup)
  * [Keep your code simple!](#keep-your-code-simple)
  * [Test your changes!](#test-your-changes)
  * [Write a good commit message](#write-a-good-commit-message)

## What contributions are accepted

We highly appreciate your contributions in fixing bugs, improving portability, and optimizing the DeGram Desktop source code and its documentation. Please push to your fork and [submit a pull request][pr].

## Build instructions

See [folder with instructions][build_instructions] for details on the various build environments.

## Pull upstream changes into your fork regularly

DeGram Desktop is continuously evolving. It is recommended that you pull upstream changes into your fork on a regular basis:

    git remote add upstream https://github.com/intelQong/DeGram.git
    git fetch upstream main
    git rebase upstream/main

For more info, see [GitHub Help][help_fork_repo].

## How to get your pull request accepted

We want to improve DeGram Desktop with your contributions while ensuring high stability and privacy for our users.

### Keep your pull requests limited to a single issue

Pull requests should be as small/atomic as possible. Large, wide-sweeping changes in a single pull request are harder to review.

### Don't mix code changes with whitespace cleanup

Keep formatting changes separated from functional code changes.

### Test your changes!

Before you submit a pull request, please test your changes. Verify that DeGram Desktop compiles and runs cleanly in portable mode.

### Write a good commit message

* Clearly summarize what was changed and why.

[//]: # (LINKS)
[telegram]: https://telegram.org/
[help_fork_repo]: https://help.github.com/articles/fork-a-repo/
[commit_message]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[pr]: https://github.com/intelQong/DeGram/compare
[build_instructions]: https://github.com/intelQong/DeGram/blob/main/docs
