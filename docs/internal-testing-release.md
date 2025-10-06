# Internal Testing Release Branch

This branch was created to prepare the current development build for internal testing and now automatically publishes internal builds when changes land on `master`.

## Purpose
- Merge the latest changes from the `dev` branch.
- Prepare the build for distribution through internal App Store / TestFlight channels.
- Ensure that any public release increments the application version before being merged into `master`.

## Next Steps
1. Review and merge any outstanding changes from `dev` into this branch.
2. Push changes that are ready for internal testing to `master`; the GitHub Actions publish pipeline will automatically ship the build to the Google Play internal testing track using a temporary build number that stays below the eventual public release.
3. To prepare a public release, bump the app version (including the build number component after the `+` in `pubspec.yaml`), merge the changes into the `release` branch, and allow the pipeline to publish to production on the Google Play Store with the highest build number for that version so internal testers can upgrade.
4. The workflow uses concurrency controls so that only the latest push to each branch continues running, preventing conflicting uploads when several commits land quickly.
