#Code for setting and updating GitHub Credentials
#https://happygitwithr.com/https-pat

library(gitcreds)
library(usethis)

#Run this, will show you current credetnials and give you an option to update it
gitcreds_set()

#Run this to check you've stored a token. Should say username: PersonalAccessToken, password: hidden
gitcreds_get()

#This line will open the chrome and the github page to generate a new token
usethis::create_github_token()
