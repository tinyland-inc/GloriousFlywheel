# Changelog

All notable changes to the GloriousFlywheel upstream infrastructure project.

## [Unreleased]

### Bug Fixes

- **runner**: Upgrade chart to 0.78.0, switch to attach strategy, fix runner API([8c86bb2](https://github.com/Jesssullivan/GloriousFlywheel/commit/8c86bb2de59d89aa1be8da00d6be302b2b83e08f))
- **dashboard**: Set NODE_EXTRA_CA_CERTS for in-cluster K8s API calls (#20)([10bd98e](https://github.com/Jesssullivan/GloriousFlywheel/commit/10bd98ec66710a34b5ef1e9c59d3d56deb4d6c36))
- **auth**: Revoke GitLab OAuth token on logout (#18)([758d85c](https://github.com/Jesssullivan/GloriousFlywheel/commit/758d85cca72e472e2bd238d6b3af5c2ef31220ee))
- **auth**: Prevent logout-to-reauth loop via landing page (#17)([4eaae95](https://github.com/Jesssullivan/GloriousFlywheel/commit/4eaae9587e20ad10509d992af861777c65e7e536))
- **auth**: Force full-page navigation on logout link([4c2b1c8](https://github.com/Jesssullivan/GloriousFlywheel/commit/4c2b1c8f3ceca36065c940064284f2d7156d1b5c))
- **auth**: Match cookie attributes on delete so logout clears session([0dd2d45](https://github.com/Jesssullivan/GloriousFlywheel/commit/0dd2d4512bd4db2d09bfacc826c50f80c203eea8))
- **app**: Rename rune files to .svelte.ts for SSR compilation (#12)([35514a1](https://github.com/Jesssullivan/GloriousFlywheel/commit/35514a1e64229f5030897543673d94901619f6b9))
- **app**: Fix container build for pnpm workspace structure([d5aa5a8](https://github.com/Jesssullivan/GloriousFlywheel/commit/d5aa5a89a34fd7b499ed8f63e1cbf1fac2e1904c))
- **runner**: Replace pod_spec with environment list for job env vars([03bcdc2](https://github.com/Jesssullivan/GloriousFlywheel/commit/03bcdc299d8d1d82e03c64cec8239aeda891c498))
- **runner**: Use flat TOML keys for kubernetes resource limits([012a91f](https://github.com/Jesssullivan/GloriousFlywheel/commit/012a91f2791faeef270f037d4386734349d97333))
- **envrc**: Genericize fallback values([c5e04bf](https://github.com/Jesssullivan/GloriousFlywheel/commit/c5e04bf31511fa50c4d86cdb91f0b8f42d937f10))
- **tofu**: Relax cluster_context validation for local dev([7b71c4a](https://github.com/Jesssullivan/GloriousFlywheel/commit/7b71c4a0b85e6a14eb52cb463bda88298095d9fd))
- **ci**: Resolve runners:plan:beehive K8s context and GitLab 401 errors([56db362](https://github.com/Jesssullivan/GloriousFlywheel/commit/56db36221f06c01b3b3c056bd9f5389f13934cb1))
- **minio**: Replace mc ilm import with mc ilm rule add([a6bb0ac](https://github.com/Jesssullivan/GloriousFlywheel/commit/a6bb0ac19de4850818ed63be1b22877988341bec))
- **ci**: Disable rigel runner jobs until beehive is validated([2794ef1](https://github.com/Jesssullivan/GloriousFlywheel/commit/2794ef12598e9dd66c6742ece0111bcb6df44219))
- **ci**: Wire KUBE_CONTEXT into runners-deploy and run Attic in monolithic mode([da58f5d](https://github.com/Jesssullivan/GloriousFlywheel/commit/da58f5ddedb20cf30cb2af6d29dcb05eba2c2b3f))
- **infra**: Add SOCKS proxy for Bates network and urlencode DB passwords([4a2cc3c](https://github.com/Jesssullivan/GloriousFlywheel/commit/4a2cc3ce3dec8f691020bde144e76bc03da1a372))
- **bazel**: Make config_validation test work in Bazel sandbox([40673c6](https://github.com/Jesssullivan/GloriousFlywheel/commit/40673c6ec50b3597c885a2e22f1e389a9a300c98))
- **ci**: Add python3 to bazel image for rules_pkg build_tar([f542c68](https://github.com/Jesssullivan/GloriousFlywheel/commit/f542c68a94bb42d1c468dc447b901e1e6a450db9))
- **bazel**: Allow rules_python to run as root in CI containers([e8c29dc](https://github.com/Jesssullivan/GloriousFlywheel/commit/e8c29dcddf0371abbc1c8d78b769b0bf426eef9c))
- **ci**: Clean stale namespace instead of importing individual resources([9989f90](https://github.com/Jesssullivan/GloriousFlywheel/commit/9989f907caacf3932fb40389165fde885fff901f))
- **ci**: Add pnpm onlyBuiltDependencies and fix tofu import detection([eb0817c](https://github.com/Jesssullivan/GloriousFlywheel/commit/eb0817c482f8eba3f532e4c46c5d2780aee059b7))
- **ci**: Switch bazel to debian for glibc, add tofu import for review state([3cbf75a](https://github.com/Jesssullivan/GloriousFlywheel/commit/3cbf75af778008a60fad969c6a3d38a65715caef))
- **ci**: Simplify pipeline rules and fix YAML parsing errors([01b49ba](https://github.com/Jesssullivan/GloriousFlywheel/commit/01b49ba0379d35d63571dab211f5f189ddab8051))
- Use root endpoint for staging/production health checks([8479eba](https://github.com/Jesssullivan/GloriousFlywheel/commit/8479ebaaf705698e3f6760095239d5fca3d13a3f))
- Configure bazel-cache S3 via environment variables only([0160922](https://github.com/Jesssullivan/GloriousFlywheel/commit/01609224bf89f63d38a8bfaec049e96e7ab98dac))
- Use dynamic ingress hostname for review environments([cb1835f](https://github.com/Jesssullivan/GloriousFlywheel/commit/cb1835fc9e7475c876256098b770b1133c53e05c))
- Add s3.auth_method to bazel-cache CLI args([1e0b26a](https://github.com/Jesssullivan/GloriousFlywheel/commit/1e0b26a3cf558b792c931fefe224e027adf7a218))
- Resolve bazel-cache S3 auth and MinIO lifecycle issues([2bcf2c0](https://github.com/Jesssullivan/GloriousFlywheel/commit/2bcf2c07083bebcfd8b4005504028846b0e85839))
- **attic,bazel**: Add JWT secret and fix config formats([e42f395](https://github.com/Jesssullivan/GloriousFlywheel/commit/e42f395448629440504a25b95a0aa12b5ae9bebd))
- **bazel-cache**: Strip scheme from S3 endpoint([7b7ca9d](https://github.com/Jesssullivan/GloriousFlywheel/commit/7b7ca9d4adc68d9ac937eb9263896c5a1ef81e83))
- **minio**: Add writable volume for mc client config([15ecfe7](https://github.com/Jesssullivan/GloriousFlywheel/commit/15ecfe7d29c4dbfd980239fd2bddfeec72ddf6e9))
- **attic**: Add database URL to server.toml configuration([602f24b](https://github.com/Jesssullivan/GloriousFlywheel/commit/602f24b9cb6768f08762619397279fdde771fb4c))
- **ci**: Improve container log capture for CrashLoopBackOff pods([c20e014](https://github.com/Jesssullivan/GloriousFlywheel/commit/c20e01440a5ce4a97bebb261d9ee8e6198b839a1))
- Add wait_for_rollout=false to attic_gc deployment([4a35e35](https://github.com/Jesssullivan/GloriousFlywheel/commit/4a35e35dd86866eb81cf9def7599b9bb5b210793))
- Add init containers to wait for dependencies([ef579ec](https://github.com/Jesssullivan/GloriousFlywheel/commit/ef579ec1077d7ed31d76ba7889e5c9dc42d2617c))
- Load var-file before var flags so CI can override namespace([a8b5810](https://github.com/Jesssullivan/GloriousFlywheel/commit/a8b5810e1d55496a16a37f95727e0ed83c08f2e9))
- Use correct storage class (trident-expandable-delete)([caf3dbc](https://github.com/Jesssullivan/GloriousFlywheel/commit/caf3dbc1ffbf1ff47671d911967df702a901426b))
- Correct YAML structure for debug:cluster and debug:auto jobs([ff11415](https://github.com/Jesssullivan/GloriousFlywheel/commit/ff114152d3bc4a363e4ae12a19378c8db942f408))
- Resolve nix:format and nix:flake-check CI failures([40d63a3](https://github.com/Jesssullivan/GloriousFlywheel/commit/40d63a3bcb0cb1c55460aea0a75f9d41e476a9f3))
- Make rollout status check non-blocking([053081d](https://github.com/Jesssullivan/GloriousFlywheel/commit/053081d472f97c327d57223ee8eb9a0a8d7a7bce))
- Add wait_for_rollout option to avoid deployment timeout([8c796be](https://github.com/Jesssullivan/GloriousFlywheel/commit/8c796be69a5c591c26ee3cd42f12ea311130e6d6))
- Add create_namespace variables for operators([a40d4c1](https://github.com/Jesssullivan/GloriousFlywheel/commit/a40d4c1614d3e053eb255a13b5f627914568ac1b))
- Improve kubectl download reliability with retry loop([1c00f8e](https://github.com/Jesssullivan/GloriousFlywheel/commit/1c00f8e3ee5f2529455fa79babb1a11bf5f57780))
- Enable operator installs - CRDs not available on beehive([d803ab5](https://github.com/Jesssullivan/GloriousFlywheel/commit/d803ab53844690e4d63fe1b70e9cb053bf9bf1be))
- Add kubectl download timeouts and skip CNPG operator install([8bf0a45](https://github.com/Jesssullivan/GloriousFlywheel/commit/8bf0a45890de5d70781c6f01a1202c583ad88f3e))
- Skip MinIO operator install on beehive (already exists)([b142700](https://github.com/Jesssullivan/GloriousFlywheel/commit/b142700f50a6d92cb4948972cd9f338be472c099))
- Remove build job dependencies from tofu:apply jobs([cc58bf4](https://github.com/Jesssullivan/GloriousFlywheel/commit/cc58bf479c2e471e89660e41cbf3d8f2d3370959))
- Use lighter template for tofu:validate, don't need kubectl([087f248](https://github.com/Jesssullivan/GloriousFlywheel/commit/087f2481ee0deaafcb809ae007e9aff9dcaae5e3))
- Add allow_failure to Nix build jobs to unblock deploys([3b01f8f](https://github.com/Jesssullivan/GloriousFlywheel/commit/3b01f8f9705aafcc94bbc7559f699e23fb7195fd))
- Disable Prometheus monitoring on rigel (CRD not installed)([63b1e6e](https://github.com/Jesssullivan/GloriousFlywheel/commit/63b1e6e5660308987b645e0416062e1401f287fd))
- Pass KUBECONFIG path to OpenTofu for GitLab K8s Agent([ead19df](https://github.com/Jesssullivan/GloriousFlywheel/commit/ead19df9eec060a550e807d0185e5bc078fb2855))
- Rebuild copy-to script in push job([03838bf](https://github.com/Jesssullivan/GloriousFlywheel/commit/03838bf769b900d4d3cbf1c5d73cfb980b6516cb))
- Increase nix build timeout to 90 minutes([0720f78](https://github.com/Jesssullivan/GloriousFlywheel/commit/0720f788184c59a6435c0c4a91c7c57cbef8b1e3))
- Fix /nix permissions before Nix installer([7303414](https://github.com/Jesssullivan/GloriousFlywheel/commit/7303414c4d79fe171f6fe3b7a63917966cdde73a))
- Use Alpine + DeterminateSystems Nix installer for CI([666ed6c](https://github.com/Jesssullivan/GloriousFlywheel/commit/666ed6c524dff1963106e2bcef0d3c709ac515ce))
- Use lnl7/nix image for GitLab CI shell compatibility([5666f51](https://github.com/Jesssullivan/GloriousFlywheel/commit/5666f511ca27f46bec2b1daef3ff696ba22c81e0))
- Use nixpkgs/nix image with shell support for GitLab CI([49ce80e](https://github.com/Jesssullivan/GloriousFlywheel/commit/49ce80e32c56100db644e18fc1775e8fe9e53752))
- Use nixos/nix:2.24.9 image with proper shell support([4e2583d](https://github.com/Jesssullivan/GloriousFlywheel/commit/4e2583d81fc6c708a1012ff39ef83ee5c9b80531))
- GitLab Runner module helm values merging and provider config([a4c46ee](https://github.com/Jesssullivan/GloriousFlywheel/commit/a4c46ee9fff4e68efb0af07debaa751292fe0ada))
- Add test stage for SAST template compatibility([6199d3a](https://github.com/Jesssullivan/GloriousFlywheel/commit/6199d3ae44f7b0a9c03d43f7c077e75934fbda30))

### CI/CD

- Add auto-triggered debug job to diagnose cluster state([38bfc66](https://github.com/Jesssullivan/GloriousFlywheel/commit/38bfc664cfa4529fe7624b0927a5a9a877d02e08))
- Allow nix:flake-check to fail until Attic cache is deployed([d712d40](https://github.com/Jesssullivan/GloriousFlywheel/commit/d712d4010d18047db47c865dff4e5c34552dbf86))

### Documentation

- Generalize upstream docs, add deployment guides, improve docs site (#11)([1b76d1d](https://github.com/Jesssullivan/GloriousFlywheel/commit/1b76d1d3d4b709b36532bfbafdb4de04113d4b1a))
- Update CONTRIBUTING scope, generate llms.txt dynamically (#10)([577f83d](https://github.com/Jesssullivan/GloriousFlywheel/commit/577f83d29e91e48a34456f74f30485607ec1ade2))
- Prepare upstream documentation for Tinyland.dev project([aa49a4e](https://github.com/Jesssullivan/GloriousFlywheel/commit/aa49a4ef376f77a475ef5bc2d6e40ca2b1c77b9f))
- Create comprehensive upstream documentation (Phase 5)([db4f842](https://github.com/Jesssullivan/GloriousFlywheel/commit/db4f84225afd2e186b2d6e52be3224ee10a27e40))
- **runners**: Add runbook, migration guide, rigel config, and deployment pipeline([0c80d66](https://github.com/Jesssullivan/GloriousFlywheel/commit/0c80d66c0fa3294faf6057c0905f43d9554c0224))
- Add Bazel dogfooding and GitLab runners sections([5d7e229](https://github.com/Jesssullivan/GloriousFlywheel/commit/5d7e22913fbae29814853db60a3e579163c0476e))

### Features

- **dashboard**: Live data, config persistence, and link fixes (#19)([793bdb3](https://github.com/Jesssullivan/GloriousFlywheel/commit/793bdb3f443cf12d111549167d1f742fc7016a28))
- Add nav footer with commit SHAs, repo links, and docs branding (#16)([582c040](https://github.com/Jesssullivan/GloriousFlywheel/commit/582c040927e76b99ebd75fdcb35555336ce8e1d1))
- **bazel**: Integrate vitest with Bazel test cache and apply greedy CI pattern([fa8ea7c](https://github.com/Jesssullivan/GloriousFlywheel/commit/fa8ea7ce45bc0706c3866b7e618d9d718e5ec529))
- GloriousFlywheel documentation overhaul and docs site (#9)([4e7ab1e](https://github.com/Jesssullivan/GloriousFlywheel/commit/4e7ab1ebbcca5af40143d1865172193f2d90fb18))
- **runners**: Add kubernetes tag and document recursive dogfooding (#8)([3456f1b](https://github.com/Jesssullivan/GloriousFlywheel/commit/3456f1be4913208bbfa19e777661f86b34b7f7fc))
- Add GHCR auth, runtime config, and rules_img container builds (#7)([58672f7](https://github.com/Jesssullivan/GloriousFlywheel/commit/58672f7868211e26f9ed3ff1b194a6115c437268))
- Generic upstream module for multi-org deployment([fed86f1](https://github.com/Jesssullivan/GloriousFlywheel/commit/fed86f1ac4fdb840d9a06aff97765b77d26a45ae))
- **upstream**: Genericize all org-specific references for multi-tenant use([1b74946](https://github.com/Jesssullivan/GloriousFlywheel/commit/1b74946ba3efdb1cac60d2ec10bd7debe2576d36))
- **bzlmod**: Rename module to attic-iac, strip org-specific config([de99055](https://github.com/Jesssullivan/GloriousFlywheel/commit/de990553fa84367da1701d1b1d657953195d8c54))
- **upstream**: Prepare repository for upstream publication([448eaf2](https://github.com/Jesssullivan/GloriousFlywheel/commit/448eaf29c4d632ed5909a9a30b8844f11e6d6f9f))
- **app**: Generate environment config from organization.yaml([5b77a02](https://github.com/Jesssullivan/GloriousFlywheel/commit/5b77a02008e303e6920673842a994dd729439e14))
- **abstraction**: Add organization config abstraction layer([f891b3e](https://github.com/Jesssullivan/GloriousFlywheel/commit/f891b3e76d87728a2599c56fcb4cfad61a550a95))
- **dev**: Add local .env setup and validation([7231a6c](https://github.com/Jesssullivan/GloriousFlywheel/commit/7231a6c08792e0f6d2560888d9ba31d8cd592b30))
- **attic**: Add JWT-based cache auto-initialization and token tooling([6f8a9a5](https://github.com/Jesssullivan/GloriousFlywheel/commit/6f8a9a5b02d0c792890e04ccbc5bba74f083be19))
- **ci**: Incremental cache push via attic watch-store([a38c839](https://github.com/Jesssullivan/GloriousFlywheel/commit/a38c839976c47425c3dfe57fa64c9b1381e7784c))
- **ci**: Dogfood Attic cache as nix substituter in CI([cddf829](https://github.com/Jesssullivan/GloriousFlywheel/commit/cddf8298c61bce8edb9f2efe5de019b2c2924907))
- **runners**: Wire Bazel remote cache and Attic into runner pool([86a13ef](https://github.com/Jesssullivan/GloriousFlywheel/commit/86a13ef71e2a38489822efe91b6f3424b70f1ccf))
- **runners**: Add enrollment alerts, recording rules, and dashboard metrics([09c932e](https://github.com/Jesssullivan/GloriousFlywheel/commit/09c932e7c93323b679d38458222794650ee50b31))
- **runners**: Publish CI/CD component templates for self-service runner access([9e91d0e](https://github.com/Jesssullivan/GloriousFlywheel/commit/9e91d0e3aa3b4f8b54c8969e2cd60b4e77db8b1d))
- **runners**: Add namespace_per_job, PSA, NetworkPolicy, ResourceQuota for untrusted jobs([a953495](https://github.com/Jesssullivan/GloriousFlywheel/commit/a9534957a1a78ad27601d9010f32c982a4ed1091))
- **runners**: Configure GitLab Agent ci_access with ci_job impersonation([7df2469](https://github.com/Jesssullivan/GloriousFlywheel/commit/7df246968f1e3c9ed5dd588e8a6899f73e347043))
- **runners**: Automate runner token lifecycle via gitlab_user_runner([62ca155](https://github.com/Jesssullivan/GloriousFlywheel/commit/62ca1550656345ccbe8938e8c45aa4fb3fe6f04e))
- **runners**: Enable Prometheus monitoring and right-size for HPA scale-out([c6eabad](https://github.com/Jesssullivan/GloriousFlywheel/commit/c6eabada14f6bcf27290343a93f5022a5bb22c75))
- **runner-dashboard**: Full SvelteKit GitOps platform for runner fleet management([fae8ee7](https://github.com/Jesssullivan/GloriousFlywheel/commit/fae8ee720ce4db9794eb787200162fdda4eac732))
- **bazel**: Add OpenTofu module validation rules and dogfooding infrastructure([c18ec1e](https://github.com/Jesssullivan/GloriousFlywheel/commit/c18ec1e99cf56fbe6a06eb571b8f341e135aa9c4))
- **bazel-cache**: Add bazel-remote cache module for Bazel action caching([5d0f248](https://github.com/Jesssullivan/GloriousFlywheel/commit/5d0f248bcee8b2f36cc7f3ce5dbdcffe86b8ebff))
- **ci**: Add security hooks, secret detection, and improved health checks([6095846](https://github.com/Jesssullivan/GloriousFlywheel/commit/60958463a98ec57adbda6120f4fae019a6e2e4e7))
- Add debug:cluster:beehive diagnostic job([7a09039](https://github.com/Jesssullivan/GloriousFlywheel/commit/7a09039cc66b82d672c19475ee0c79d7ce722f4a))
- GitLab IaC integration with Bazel and Justfile([d40abfe](https://github.com/Jesssullivan/GloriousFlywheel/commit/d40abfe667cd0a239d0bc1ebe28b21399bea6755))
- Add GitLab Runner module and cleanup deprecated code([5fb4db9](https://github.com/Jesssullivan/GloriousFlywheel/commit/5fb4db995b0d6c26cf4b40dcb1f72a6880e343dc))
- Bates ILS infrastructure with GitLab Kubernetes Agent([e9f0ca9](https://github.com/Jesssullivan/GloriousFlywheel/commit/e9f0ca969388b754ba12f95a9b398cecc7d3142f))
- Attic IaC - GitLab infrastructure patterns([a73e1ee](https://github.com/Jesssullivan/GloriousFlywheel/commit/a73e1ee8b7a68ec7acad181860a8354f6c653141))

### Miscellaneous

- Now dynamically generated @ pages & dashboard([e9df103](https://github.com/Jesssullivan/GloriousFlywheel/commit/e9df103709322ae2c41c94f8a9fe650eb62b31f0))
- Transhuman intent([3b077a4](https://github.com/Jesssullivan/GloriousFlywheel/commit/3b077a464607e9191c0622fec9450281dc4d635e))

### Refactoring

- Complete Phase 7 cleanup and standardization([5e00b87](https://github.com/Jesssullivan/GloriousFlywheel/commit/5e00b872685140fc687fc361a1b0c0df540f5535))
- Consolidate Justfiles and enhance direnv support([4ca2034](https://github.com/Jesssullivan/GloriousFlywheel/commit/4ca2034f086fde9b28855d009df24e86bd8203b2))
- Phase 5/7/8 cleanup, runner module, and documentation([93c21b8](https://github.com/Jesssullivan/GloriousFlywheel/commit/93c21b8c20f7b129b339df67e695a6cdc25259f0))

### Styling

- **scripts**: Apply nix fmt (treefmt) formatting([784810b](https://github.com/Jesssullivan/GloriousFlywheel/commit/784810bcf119ad738e0242e055dcf7ca6fae4d77))
- **scripts**: Apply shfmt formatting to generate-attic-token.sh([c6d9a42](https://github.com/Jesssullivan/GloriousFlywheel/commit/c6d9a42c7c6061f9eded347aed80081743af8ddd))
- Remove redundant quotes in [[ ]] test (shfmt)([4d427a7](https://github.com/Jesssullivan/GloriousFlywheel/commit/4d427a7949ce0e72adca662cecc1342c82123c24))
- Fix buildifier and shfmt formatting([7f85204](https://github.com/Jesssullivan/GloriousFlywheel/commit/7f85204b24f1a27b8a203faa4be9bb8b8de50012))
- **bazel**: Fix buildifier formatting([e8a1710](https://github.com/Jesssullivan/GloriousFlywheel/commit/e8a17106477a9cc66269b57834a05e544760c1ff))
- **runners**: Normalize formatting and harden pre-commit hooks([862c80b](https://github.com/Jesssullivan/GloriousFlywheel/commit/862c80b42a9546793a5b4c214810d3ddec7fbb54))
- **runners**: Apply formatter to drift endpoint([0434834](https://github.com/Jesssullivan/GloriousFlywheel/commit/0434834b561d037983e8f81e199cc5db254a0e13))
- **runner-dashboard**: Normalize formatting to 2-space indent and double quotes([738413d](https://github.com/Jesssullivan/GloriousFlywheel/commit/738413d31874c450043be34b3f82e0b243753ff2))
- Fix shell script formatting (shfmt)([2a85450](https://github.com/Jesssullivan/GloriousFlywheel/commit/2a8545087fff87cd15872747d0e263540658d65f))
- Fix markdown table formatting (prettier)([686919f](https://github.com/Jesssullivan/GloriousFlywheel/commit/686919fbd29db606f0c3668b8dfaa69f18c7d7de))
- Apply treefmt formatting fixes([8e5a35f](https://github.com/Jesssullivan/GloriousFlywheel/commit/8e5a35fca2e10dd7a61ec3630cb28013467f10bb))

### Testing

- **runners**: Add smoke tests, integration tests, and coverage gate([c13d4a5](https://github.com/Jesssullivan/GloriousFlywheel/commit/c13d4a54a15e497904d59653d39951a7abfa5e58))

### Debug

- Add container log capture to debug job([c4bbeec](https://github.com/Jesssullivan/GloriousFlywheel/commit/c4bbeec72f2a23dbdfba8a2563838cfd194efbd6))

