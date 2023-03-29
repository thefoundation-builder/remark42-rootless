remark42 with webmentiond rootless with Pingback and MailHog


* will use a git repository under /srv to save everything
* 

## endpoints

| Type | protected | URL |
|---|---|---|

| Webmentions (RECEIVE) | N |  /webmentions/receive |
| PingBack (RECEIVE) | N |  /webmentions/pingback |
| Ping | N |  /ping |
| Mailhog | Y |  /mail |



## parameters
| Name | Type | example |
|---|---|---|
| GIT_REPO_SYNC   | git URL | `git@gitlab.generic.lan:the-foundation/my-comments-store` | 
| GIT_REPO_KEY    | `LS0tLS` ..long base64 text.. `LS0tLS0K` |
| GIT_REPO_PUBKEY | `c3NoLXJzY` ..long base64 text.. `bi1UUDIzCg==` | 

For the  other parameters:

* refer to https://remark42.com/docs/configuration/parameters/
* check https://github.com/zerok/webmentiond/blob/main/docs/getting-started.md



---

<h3>A project of the foundation</h3>
<a href="https://the-foundation.gitlab.io/"><div><img src="https://hcxi2.2ix.ch/gitlab/the-foundation/remark42-rootless/README.md/logo.jpg" width="480" height="270"/></div></a>


## Todo
- [ ] MORE DOCUMENTATION
- [ ] [Invite team members and collaborators](https://docs.gitlab.com/ee/user/project/members/)
- [ ] [Create a new merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html)
- [ ] [Automatically close issues from merge requests](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#closing-issues-automatically)
- [ ] [Enable merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
- [ ] [Automatically merge when pipeline succeeds](https://docs.gitlab.com/ee/user/project/merge_requests/merge_when_pipeline_succeeds.html)


