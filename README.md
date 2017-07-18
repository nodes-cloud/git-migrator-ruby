# Git Migrator

**Requirements:**
ruby 2.3

Installation
Pull Code

`git pull`

Install Gems

`gem install tty-prompt colorize inquirer`

Add token from https://git.nodescloud.com/profile/personal_access_tokens

Replace @token = "<git.nodescloud.com token>" with your access token.

`vim .git_migrator`

`cp -rp ./git_migrator.rb /usr/bin/git_migrator`
`chmod +x /usr/bin/git_migrator`

ruby 2.3

If PATH spec fails, execute with `ruby ./git_migrator.rb`
